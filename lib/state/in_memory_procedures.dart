import 'package:cloud_firestore/cloud_firestore.dart';

class InMemoryProcedures {
  // Singleton-style static storage
  static final List<ProcedureDraft> _procedures = [];

  // Read-only access
  static List<ProcedureDraft> get procedures => List.unmodifiable(_procedures);

  // Add a new procedure
  static void addProcedure(ProcedureDraft procedure) {
    _procedures.add(procedure);
  }
}

/// Represents a procedure created in the UI
class ProcedureDraft {
  final String title;
  final String description;
  final List<FormFieldDraft> formSchema;
  final List<ApprovalLevelDraft> approvalLevels;
  final Set<ProcedureVisibility> visibility;

  ProcedureDraft({
    required this.title,
    required this.description,
    required this.formSchema,
    required this.approvalLevels,
    required this.visibility,
  });

  factory ProcedureDraft.fromJson(Map<String, dynamic> json) {
    return ProcedureDraft(
      title: json['title'] as String? ?? 'Untitled',
      description: json['desc'] as String? ?? '',
      formSchema:
          (json['formBuilder'] as List<dynamic>?)
              ?.map((e) => FormFieldDraft.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      approvalLevels:
          (json['approvalLevels'] as List<dynamic>?)
              ?.map(
                (e) => ApprovalLevelDraft.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      visibility:
          (json['visibility'] as List<dynamic>?)
              ?.map(
                (e) => ProcedureVisibility.values.firstWhere(
                  (v) => v.name == e,
                  orElse: () => ProcedureVisibility.all,
                ),
              )
              .toSet() ??
          {ProcedureVisibility.all},
    );
  }
}

/// Represents ONE workflow step (one level)

class FormFieldDraft {
  String fieldId;
  String label;
  FormFieldType type;
  bool required;
  List<String>? options; // for choice based fields

  FormFieldDraft({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.required,
    this.options,
  });

  factory FormFieldDraft.fromJson(Map<String, dynamic> json) {
    return FormFieldDraft(
      fieldId: json['fieldId'] as String,
      label: json['label'] as String,
      type: FormFieldType.values.firstWhere((e) => e.name == json['type']),
      required: json['required'] as bool,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
    );
  }
}

enum FormFieldType { text, file, singleChoice, multipleChoice, date }

class ApprovalLevelDraft {
  List<Map<String, String>> roles;
  int minApprovals;
  bool allMustApprove;

  ApprovalLevelDraft({
    required this.roles,
    required this.minApprovals,
    required this.allMustApprove,
  });

  factory ApprovalLevelDraft.fromJson(Map<String, dynamic> json) {
    // Determine roles based on roleIds if available
    // NOTE: This is a simplified reconstruction. In a real app,
    // you might need to fetch role names or store them in the JSON.
    List<Map<String, String>> rolesList = [];
    if (json['roleIds'] != null) {
      rolesList = (json['roleIds'] as List).map((id) {
        return {'id': id.toString(), 'name': 'Role $id'};
      }).toList();
    }

    return ApprovalLevelDraft(
      roles: rolesList,
      minApprovals: json['minApprovals'] as int? ?? 1,
      allMustApprove: json['allMustApprove'] as bool? ?? false,
    );
  }
}

// visibility button

enum ProcedureVisibility { user, faculty, guest, all }

extension FormFieldDraftJson on FormFieldDraft {
  Map<String, dynamic> toJson() {
    final json = {
      "fieldId": fieldId,
      "type": type.name,
      "label": label,
      "required": required,
    };

    if (type == FormFieldType.singleChoice ||
        type == FormFieldType.multipleChoice) {
      json["options"] = options ?? [];
    }

    return json;
  }
}

extension ApprovalLevelDraftJson on ApprovalLevelDraft {
  Map<String, dynamic> toJson(int level) {
    return {
      "level": level,
      "approvalType": "ROLE",
      "roleIds": roles.map((r) => r['id']).toList(),
      "userIds": [],
      "minApprovals": minApprovals,
      "allMustApprove": allMustApprove,
    };
  }
}

extension ProcedureDraftJson on ProcedureDraft {
  Map<String, dynamic> toJson({required String adminUid}) {
    return {
      "title": title,
      "desc": description,

      "visibility": visibility.contains(ProcedureVisibility.all)
          ? ["all"]
          : visibility.map((v) => v.name).toList(),

      "requestFormat": 0,
      "priority": "NORMAL",

      "formSchema": formSchema.map((f) => f.toJson()).toList(),

      "approvalLevels": approvalLevels
          .asMap()
          .entries
          .map((e) => e.value.toJson(e.key + 1))
          .toList(),

      "createdBy": adminUid,
      "createdAt": FieldValue.serverTimestamp(),
      "isActive": true,
    };
  }
}
