import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../state/in_memory_procedures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/firebase_procedure_repository.dart';

const List<Map<String, String>> _dummyRoles = [
  {'id': 'CLASS_ADVISOR_ROLE', 'name': 'Class Advisor'},
  {'id': 'HOD_ROLE', 'name': 'Head of Department'},
  {'id': 'PRINCIPAL_ROLE', 'name': 'Principal'},
  {'id': 'FINANCE_ROLE', 'name': 'Finance Officer'},
];

class AdminCreateProcedureScreen extends StatefulWidget {
  const AdminCreateProcedureScreen({super.key});

  @override
  State<AdminCreateProcedureScreen> createState() =>
      _AdminCreateProcedureScreenState();
}

class _AdminCreateProcedureScreenState
    extends State<AdminCreateProcedureScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Firebase details
  // final FirebaseProcedureRepository _procedureRepo =
  //     FirebaseProcedureRepository();

  // api call variable
  final ApiProcedureRepository _procedureRepo = ApiProcedureRepository(
    "http://localhost:3000",
  );
  // Visibility toggle variable
  ProcedureVisibility _visibility = ProcedureVisibility.all;

  // Local UI state for form builder
  bool _hasForm = false;
  final List<FormFieldDraft> _formFields = [];
  final _formKey = GlobalKey<FormState>();

  // Local UI state for approval steps
  final List<ApprovalLevelDraft> _approvalLevels = [];

  // ─────────────────Form builder functions ─────────────────

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

  // ───────────────── Helper for field Id ─────────────────
  String _generateFieldId(String label) {
    return label
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  void _removeFormBuilder() {
    setState(() {
      _hasForm = false;
      _formFields.clear();
      _formKey.currentState?.reset();
    });
  }

  // ───────────────── Approval steps functions ─────────────────

  void _addApprovalLevel() {
    setState(() {
      _approvalLevels.add(
        ApprovalLevelDraft(roles: [], minApprovals: 0, allMustApprove: false),
      );
    });
  }

  void _removeApprovalLevel(int index) {
    setState(() {
      _approvalLevels.removeAt(index);
    });
  }

  void _openAddRoleDialog(int levelIndex) {
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Role to Level ${levelIndex + 1}'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              final filteredRoles = _dummyRoles.where((role) {
                return role['name']!.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              }).toList();

              return SizedBox(
                width: 400, //  important: fixes intrinsic size issue
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search role',
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200, // fixed height for ListView
                      child: ListView.builder(
                        itemCount: filteredRoles.length,
                        itemBuilder: (context, index) {
                          final role = filteredRoles[index];

                          return ListTile(
                            title: Text(role['name']!),
                            trailing: TextButton(
                              child: const Text('Add'),
                              onPressed: () {
                                setState(() {
                                  final level = _approvalLevels[levelIndex];
                                  level.roles.add(role);

                                  if (!level.allMustApprove) {
                                    level.minApprovals = level.roles.length;
                                  }
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ───────────────── Save to In-Memory Store ─────────────────

  Future<void> _saveProcedure() async {
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
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_approvalLevels.isEmpty) {
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        const SnackBar(content: Text('Add at least one approval level')),
      );
      return;
    }
    for (int i = 0; i < _approvalLevels.length; i++) {
      if (_approvalLevels[i].roles.isEmpty) {
        ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
          SnackBar(
            content: Text(
              'Approval level ${i + 1} must have at least one role',
            ),
          ),
        );
        return;
      }
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedure title is required')),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedure description is required')),
      );
      return;
    }

    for (final field in _formFields) {
      if (field.type == FormFieldType.singleChoice ||
          field.type == FormFieldType.multipleChoice) {
        final hasEmptyOption = field.options!.any((opt) => opt.trim().isEmpty);

        if (hasEmptyOption) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Choice fields cannot have empty options'),
            ),
          );
          return;
        }
      }
    }
    // InMemoryProcedures.addProcedure(
    //   ProcedureDraft(
    //     title: _titleController.text.trim(),
    //     formSchema: List.from(_formFields),
    //     approvalLevels: _approvalLevels.map((level) {
    //       return ApprovalLevelDraft(
    //         roles: List.from(level.roles),
    //         minApprovals: level.minApprovals,
    //         allMustApprove: level.allMustApprove,
    //       );
    //     }).toList(),
    //     visibility: _visibility,
    //   ),
    // );
    final adminUid = FirebaseAuth.instance.currentUser!.uid;
    final authToken = await FirebaseAuth.instance.currentUser!.getIdToken();

    final procedure = ProcedureDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      formSchema: List.from(_formFields),
      approvalLevels: _approvalLevels.map((level) {
        return ApprovalLevelDraft(
          roles: List.from(level.roles),
          minApprovals: level.minApprovals,
          allMustApprove: level.allMustApprove,
        );
      }).toList(),
      visibility: _visibility,
    );

    // need try catch here later.
    await _procedureRepo.saveProcedure(
      procedure: procedure,
      adminUid: adminUid,
      authToken: authToken,
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

          // ───────────────── Visibility Section ─────────────────
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Who can create this request type ?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ToggleButtons(
                  isSelected: [
                    _visibility == ProcedureVisibility.user,
                    _visibility == ProcedureVisibility.faculty,
                    _visibility == ProcedureVisibility.all,
                  ],
                  onPressed: (index) {
                    setState(() {
                      _visibility = ProcedureVisibility.values[index];
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('User'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Faculty'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ───────────────── Title Input ─────────────────
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Procedure Title',
                hintText: 'Eg: Leave Application',
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Procedure Description',
                hintText: 'Enter a brief description',
              ),
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
                  onRemoveForm: _removeFormBuilder,
                ),
              ),
            ),

          if (_approvalLevels.isNotEmpty)
            Column(
              children: List.generate(
                _approvalLevels.length,
                (index) => _ApprovalLevelCard(
                  level: index + 1,
                  roles: _approvalLevels[index].roles,
                  minApprovals: _approvalLevels[index].minApprovals,
                  allMustApprove: _approvalLevels[index].allMustApprove,
                  onRemove: () => _removeApprovalLevel(index),
                  onAddRole: () => _openAddRoleDialog(index),
                  onRemoveRole: (role) {
                    setState(() {
                      final level = _approvalLevels[index];
                      level.roles.remove(role);

                      if (!level.allMustApprove) {
                        level.minApprovals = level.roles.length;
                      }
                    });
                  },
                  onToggleAllMustApprove: (checked) {
                    setState(() {
                      final level = _approvalLevels[index];
                      final value = checked ?? false;
                      level.allMustApprove = value;
                      if (value) {
                        level.minApprovals = level.roles.length;
                      }
                    });
                  },
                  onMinApprovalsChanged: (value) {
                    setState(() {
                      final level = _approvalLevels[index];
                      if (value < 1) {
                        level.minApprovals = 1;
                      } else if (value > level.roles.length) {
                        level.minApprovals = level.roles.length;
                      } else {
                        level.minApprovals = value;
                      }
                    });
                  },
                ),
              ),
            ),
          const SizedBox(height: 32),

          // ───────────────── Add Step Section ─────────────────
          Text(
            'Approval Levels',
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
                title: 'Add Approval Level',
                subtitle: 'Add reviewers manually',
                onTap: _addApprovalLevel,
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

// ───────────────── Form Creation Widget ─────────────────

class FormBuilderSection extends StatelessWidget {
  final List<FormFieldDraft> fields;
  final VoidCallback onAdd;
  final VoidCallback onChanged;
  final void Function(int index) onRemove;
  final String Function(String label) generateFieldId;
  final VoidCallback onRemoveForm;

  const FormBuilderSection({
    super.key,
    required this.fields,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
    required this.generateFieldId,
    required this.onRemoveForm,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Form Builder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Remove form',
                onPressed: onRemoveForm,
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (fields.isEmpty)
            const Text(
              'No fields added yet.',
              style: TextStyle(color: AppTheme.textLight),
            )
          else
            ...List.generate(fields.length, (index) {
              final field = fields[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
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
                            DropdownMenuItem(
                              value: FormFieldType.singleChoice,
                              child: Text('Single choice'),
                            ),
                            DropdownMenuItem(
                              value: FormFieldType.multipleChoice,
                              child: Text('Multiple choice'),
                            ),
                            DropdownMenuItem(
                              value: FormFieldType.date,
                              child: Text('Date'),
                            ),
                          ],

                          onChanged: (val) {
                            if (val != null) {
                              field.type = val;

                              if (val == FormFieldType.singleChoice ||
                                  val == FormFieldType.multipleChoice) {
                                field.options ??= [''];
                              } else {
                                field.options = null;
                              }

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
                    if (field.type == FormFieldType.singleChoice ||
                        field.type == FormFieldType.multipleChoice)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Options',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),

                            ...List.generate(field.options!.length, (optIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: field.options![optIndex],
                                        onChanged: (val) {
                                          field.options![optIndex] = val;
                                          onChanged();
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Option ${optIndex + 1}',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: field.options!.length <= 1
                                          ? null
                                          : () {
                                              field.options!.removeAt(optIndex);
                                              onChanged();
                                            },
                                    ),
                                  ],
                                ),
                              );
                            }),

                            TextButton.icon(
                              onPressed: () {
                                field.options!.add(
                                  'Option ${field.options!.length + 1}',
                                );
                                onChanged();
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add option'),
                            ),
                          ],
                        ),
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

class _ApprovalLevelCard extends StatelessWidget {
  final int level;
  final List<Map<String, String>> roles;
  final VoidCallback onRemove;
  final VoidCallback onAddRole;
  final void Function(Map<String, String> role) onRemoveRole;
  final int minApprovals;
  final bool allMustApprove;
  final ValueChanged<bool?> onToggleAllMustApprove;
  final ValueChanged<int> onMinApprovalsChanged;

  const _ApprovalLevelCard({
    required this.level,
    required this.roles,
    required this.minApprovals,
    required this.allMustApprove,
    required this.onRemove,
    required this.onAddRole,
    required this.onRemoveRole,
    required this.onToggleAllMustApprove,
    required this.onMinApprovalsChanged,
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
                'Level $level',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
            ],
          ),

          const SizedBox(height: 8),

          if (roles.isEmpty)
            const Text(
              'No roles added yet',
              style: TextStyle(color: AppTheme.textLight),
            )
          else
            Column(
              children: roles.map((role) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(role['name']!),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => onRemoveRole(role),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Minimum approvals:', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  enabled: !allMustApprove,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: TextEditingController(
                    text: minApprovals.toString(),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      onMinApprovalsChanged(parsed);
                    }
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: allMustApprove,
                onChanged: onToggleAllMustApprove,
              ),
              const Text('All must approve'),
            ],
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: onAddRole, // intentionally empty
            icon: const Icon(Icons.person_add),
            label: const Text('Add User'),
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
