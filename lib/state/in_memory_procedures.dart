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
  final List<FormFieldDraft> formSchema;
  final List<ApprovalLevelDraft> approvalLevels;
  final ProcedureVisibility visibility;

  ProcedureDraft({
    required this.title,
    required this.formSchema,
    required this.approvalLevels,
    required this.visibility,
  });
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
}

// visibility button

enum ProcedureVisibility { user, faculty, all }

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
      "desc": "",

      "visibility": visibility == ProcedureVisibility.all
          ? ["user", "faculty"]
          : [visibility.name],

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
