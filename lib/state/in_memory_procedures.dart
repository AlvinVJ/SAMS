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
  final Set<String> visibility;
   final String? systemHook;
  final String? hookTrigger;
  final bool isHosteller;

  ProcedureDraft({
    required this.title,
    required this.description,
    required this.formSchema,
    required this.approvalLevels,
    required this.visibility,
    this.systemHook,
    this.hookTrigger,
    this.isHosteller = false,
  });

  factory ProcedureDraft.fromJson(Map<String, dynamic> json) {
    // Safely parse visibility set
    Set<String> visibilitySet = {"all"};
    if (json['visibility'] != null && json['visibility'] is List) {
      visibilitySet = (json['visibility'] as List)
          .map((e) => e.toString().toLowerCase())
          .toSet();
    }

    return ProcedureDraft(
      title: json['title']?.toString() ?? 'Untitled',
      description:
          json['description']?.toString() ?? json['desc']?.toString() ?? '',
      systemHook: json['system_hook']?.toString(),
      hookTrigger: json['hook_trigger']?.toString(),
      formSchema:
          ((json['formFields'] ??
                      json['formSchema'] ??
                      json['form_fields'] ??
                      json['formBuilder'])
                  as List?)
              ?.map((e) => FormFieldDraft.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      approvalLevels:
          (json['approvalLevels'] as List?)
              ?.map(
                (e) => ApprovalLevelDraft.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      visibility: visibilitySet,
      isHosteller: json['is_hosteller'] == true,
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
      fieldId:
          (json['fieldId'] ?? json['id'] ?? json['field_id'])?.toString() ??
          'unknown_id',
      label:
          (json['label'] ?? json['title'] ?? json['name'])?.toString() ??
          'Untitled Field',
      type: FormFieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FormFieldType.text,
      ),
      required: json['required'] == true,
      options: json['options'] != null
          ? List<String>.from(
              (json['options'] as List).map((e) => e.toString()),
            )
          : null,
    );
  }
}

enum FormFieldType { text, file, csv, singleChoice, multipleChoice, date, time }

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
    List<Map<String, String>> rolesList = [];
    if (json['roleIds'] != null && json['roleIds'] is List) {
      rolesList = (json['roleIds'] as List).map((id) {
        return {
          'id': id.toString(),
          'name': 'Role $id',
          'role_tag': id.toString(),
        };
      }).toList();
    }

    return ApprovalLevelDraft(
      roles: rolesList,
      minApprovals: int.tryParse(json['minApprovals'].toString()) ?? 1,
      allMustApprove: json['allMustApprove'] == true,
    );
  }
}

// visibility button

// visibility button - Deprecated in favor of dynamic role tags
// enum ProcedureVisibility {
//   student,
//   faculty,
//   clubLead,
//   placementCoordinator,
//   all,
// }

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
      "roleIds": roles.map((r) => r['role_tag']).toList(),
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

      "visibility": visibility.contains("all") ? ["all"] : visibility.toList(),

      "requestFormat": 0,
      "priority": "NORMAL",
      "system_hook": systemHook,
      "hook_trigger": hookTrigger,
      "is_hosteller": isHosteller,

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
