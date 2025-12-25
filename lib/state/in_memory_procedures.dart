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
  final List<WorkflowStepDraft> steps;

  ProcedureDraft({
    required this.title,
    required this.formSchema,
    required this.steps,
  });
}

/// Represents ONE workflow step (one level)
class WorkflowStepDraft {
  final List<String> approvers; // empty for form steps

  WorkflowStepDraft({this.approvers = const []});
}

enum WorkflowStepType { approval }

class FormFieldDraft {
  String fieldId;
  String label;
  FormFieldType type;
  bool required;

  FormFieldDraft({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.required,
  });
}

enum FormFieldType { text, file }
