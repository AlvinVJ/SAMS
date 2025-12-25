import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../state/in_memory_procedures.dart';

class AdminCreateProcedureScreen extends StatefulWidget {
  const AdminCreateProcedureScreen({super.key});

  @override
  State<AdminCreateProcedureScreen> createState() =>
      _AdminCreateProcedureScreenState();
}

class _AdminCreateProcedureScreenState
    extends State<AdminCreateProcedureScreen> {
  final TextEditingController _titleController = TextEditingController();

  // Local UI state for form builder
  bool _hasForm = false;
  final List<FormFieldDraft> _formFields = [];
  final _formKey = GlobalKey<FormState>();

  /// Local UI state for workflow steps
  final List<WorkflowStepDraft> _steps = [];

  // ───────────────── Add Steps ─────────────────

  void _onFormBuilderClick() {
    setState(() {
      _hasForm = true;
    });
  }

  void _addField() {
    setState(() {
      _formFields.add(
        FormFieldDraft(
          fieldId: 'field_${_formFields.length + 1}',
          label: '',
          type: FormFieldType.text,
          required: false,
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      _formFields.removeAt(index);
    });
  }

  void _addApprovalStep() {
    setState(() {
      _steps.add(WorkflowStepDraft(approvers: []));
    });
  }

  void _removeStep(int index) {
    setState(() => _steps.removeAt(index));
  }

  // ───────────────── Helper for field Id ─────────────────
  String _generateFieldId(String label) {
    return label
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  // ───────────────── Save to In-Memory Store ─────────────────

  void _saveProcedure() {
    if (!_hasForm) {
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        const SnackBar(
          content: Text('Create a form before saving the procedure'),
        ),
      );
      return;
    }
    if (_hasForm && _formFields.isEmpty) {
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        const SnackBar(content: Text('Add at least one form field')),
      );
    }
    if (!_formKey.currentState!.validate()) return;
    if (_titleController.text.trim().isEmpty) return;
    if (_steps.isEmpty) return;

    InMemoryProcedures.addProcedure(
      ProcedureDraft(
        title: _titleController.text.trim(),
        steps: List.from(_steps),
        formSchema: List.from(_formFields),
      ),
    );

    Navigator.pop(context); // only allowed exit
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      disableSidebar: true, // prevent sidebar navigation
      activeRoute: '/admin/procedures',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────────── Back Button ─────────────────
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Procedures'),
          ),

          const SizedBox(height: 12),

          // ───────────────── Header ─────────────────
          Text(
            'Create New Procedure',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Build your approval workflow step by step',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
          ),

          const SizedBox(height: 24),

          // ───────────────── Title Input ─────────────────
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Procedure Title',
              hintText: 'Eg: Leave Application',
            ),
          ),

          const SizedBox(height: 32),

          // ───────────────── Workflow Canvas ─────────────────
          if (_hasForm)
            SizedBox(
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: FormBuilderSection(
                  fields: _formFields,
                  onAdd: _addField,
                  onChanged: () => setState(() {}),
                  onRemove: _removeField,
                  generateFieldId: _generateFieldId,
                ),
              ),
            ),
          Column(
            children: List.generate(
              _steps.length,
              (index) => _WorkflowStepCard(
                index: index,
                step: _steps[index],
                onRemove: () => _removeStep(index),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ───────────────── Add Step Section ─────────────────
          Text(
            'Add workflow step',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _AddStepButton(
                icon: Icons.description,
                color: Colors.blue,
                title: 'Form Builder',
                subtitle: 'Collect request data',
                onTap: _onFormBuilderClick,
              ),
              _AddStepButton(
                icon: Icons.how_to_reg,
                color: Colors.green,
                title: 'Approval Step',
                subtitle: 'Review & sign-off',
                onTap: _addApprovalStep,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ───────────────── Footer ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _saveProcedure,
                icon: const Icon(Icons.save),
                label: const Text('Save Procedure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ───────────────── Workflow Step Card ─────────────────
/// Represents ONE workflow level
class _WorkflowStepCard extends StatelessWidget {
  final int index;
  final WorkflowStepDraft step;
  final VoidCallback onRemove;

  const _WorkflowStepCard({
    required this.index,
    required this.step,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${index + 1} • Approval Step',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Configure approvers for this level.',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}

class FormBuilderSection extends StatelessWidget {
  final List<FormFieldDraft> fields;
  final VoidCallback onAdd;
  final VoidCallback onChanged;
  final void Function(int index) onRemove;
  final String Function(String label) generateFieldId;

  const FormBuilderSection({
    super.key,
    required this.fields,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
    required this.generateFieldId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Form Builder',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (fields.isEmpty)
            const Text(
              'No fields added yet.',
              style: TextStyle(color: AppTheme.textLight),
            )
          else
            // ...List.generate(
            //   fields.length,
            //   (index) => Padding(
            //     padding: const EdgeInsets.only(bottom: 8),
            //     child: Text(
            //       '• ${fields[index].label}',
            //       style: const TextStyle(fontSize: 14),
            //     ),
            //   ),
            // ),
            ...List.generate(fields.length, (index) {
              final field = fields[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: field.label,
                            decoration: const InputDecoration(
                              labelText: 'Field Label',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Label is required';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              field.label = val;
                              field.fieldId = generateFieldId(val);
                              onChanged();
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${field.fieldId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Type
                    DropdownButton<FormFieldType>(
                      value: field.type,
                      items: const [
                        DropdownMenuItem(
                          value: FormFieldType.text,
                          child: Text('Text'),
                        ),
                        DropdownMenuItem(
                          value: FormFieldType.file,
                          child: Text('File'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          field.type = val;
                          onChanged();
                        }
                      },
                    ),

                    const SizedBox(width: 12),

                    // Required
                    Checkbox(
                      value: field.required,
                      onChanged: (val) {
                        field.required = val ?? false;
                        onChanged();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onRemove(index),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: onAdd, // <-- empty for now
            icon: const Icon(Icons.add),
            label: const Text('Add Field'),
          ),
        ],
      ),
    );
  }
}

/// ───────────────── Add Step Button ─────────────────
class _AddStepButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AddStepButton({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: _cardBox(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ───────────────── Styling Helper ─────────────────
BoxDecoration _cardBox() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.grey.shade200),
);
