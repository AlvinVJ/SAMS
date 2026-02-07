import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../state/in_memory_procedures.dart';

import '../data/firebase_procedure_repository.dart';
import '../services/admin_procedure_service.dart';
import 'admin_workflow_canvas_screen.dart';

class AdminEditProcedureScreen extends StatefulWidget {
  final String procedureId;

  const AdminEditProcedureScreen({super.key, required this.procedureId});

  @override
  State<AdminEditProcedureScreen> createState() =>
      _AdminEditProcedureScreenState();
}

class _AdminEditProcedureScreenState extends State<AdminEditProcedureScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final ApiProcedureRepository _procedureRepo = ApiProcedureRepository(
    "http://localhost:3000",
  );
  final AdminProcedureService _adminService = AdminProcedureService();

  Set<ProcedureVisibility> _visibility = {};
  bool _hasForm = false;
  final List<FormFieldDraft> _formFields = [];
  final _formKey = GlobalKey<FormState>();
  final List<ApprovalLevelDraft> _approvalLevels = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProcedure();
  }

  Future<void> _loadProcedure() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final procedure = await _adminService.fetchProcedureById(
        widget.procedureId,
      );

      setState(() {
        _titleController.text = procedure.title;
        _descriptionController.text = procedure.description;

        // Parse visibility
        _visibility = procedure.visibility.map((v) {
          return ProcedureVisibility.values.firstWhere(
            (pv) => pv.name == v,
            orElse: () => ProcedureVisibility.all,
          );
        }).toSet();

        // Parse form fields
        if (procedure.formFields.isNotEmpty) {
          _hasForm = true;
          _formFields.clear();
          for (var field in procedure.formFields) {
            _formFields.add(FormFieldDraft.fromJson(field));
          }
        }

        // Parse approval levels
        _approvalLevels.clear();
        for (var level in procedure.approvalLevels) {
          _approvalLevels.add(ApprovalLevelDraft.fromJson(level));
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
    List<Map<String, String>> searchResults = [];
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Role to Level ${levelIndex + 1}'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> performSearch() async {
                if (searchQuery.trim().isEmpty) return;

                setDialogState(() {
                  isLoading = true;
                  errorMessage = null;
                  searchResults = [];
                });

                try {
                  final results = await _procedureRepo.fetchRoles(searchQuery);
                  setDialogState(() {
                    searchResults = results;
                    isLoading = false;
                    if (results.isEmpty) {
                      errorMessage = 'No roles found.';
                    }
                  });
                } catch (e) {
                  setDialogState(() {
                    isLoading = false;
                    errorMessage = 'Failed to fetch roles. Please try again.';
                  });
                }
              }

              return SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search role (e.g. HOD, Principal)',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: performSearch,
                          tooltip: 'Search',
                        ),
                      ),
                      onChanged: (value) {
                        searchQuery = value;
                      },
                      onSubmitted: (_) => performSearch(),
                      textInputAction: TextInputAction.search,
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final role = searchResults[index];
                            return ListTile(
                              title: Text(
                                role['role_tag'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(role['name'] ?? ''),
                                  const SizedBox(width: 12),
                                  Text(
                                    role['mits_uid'] ?? '',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: TextButton(
                                child: const Text('Add'),
                                onPressed: () {
                                  setState(() {
                                    final level = _approvalLevels[levelIndex];

                                    final exists = level.roles.any(
                                      (r) => r['role_tag'] == role['role_tag'],
                                    );
                                    if (!exists) {
                                      level.roles.add({
                                        'role_tag': role['role_tag'] ?? '',
                                      });
                                      if (!level.allMustApprove) {
                                        level.minApprovals = level.roles.length;
                                      }
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

  Future<void> _updateProcedure() async {
    if (!_hasForm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a form before updating the procedure'),
        ),
      );
      return;
    }
    if (_hasForm && _formFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one form field')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_approvalLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one approval level')),
      );
      return;
    }
    for (int i = 0; i < _approvalLevels.length; i++) {
      if (_approvalLevels[i].roles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
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

    final procedureData = {
      "title": _titleController.text.trim(),
      "desc": _descriptionController.text.trim(),
      "visibility": _visibility.contains(ProcedureVisibility.all)
          ? ["all"]
          : _visibility.map((v) => v.name).toList(),
      "formBuilder": _formFields.map((f) => f.toJson()).toList(),
      "formFields": _formFields.map((f) => f.toJson()).toList(),
      "approvalLevels": _approvalLevels
          .asMap()
          .entries
          .map((e) => e.value.toJson(e.key + 1))
          .toList(),
    };

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _adminService.updateProcedure(widget.procedureId, procedureData);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Procedure updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate back with success flag
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AdminDashboardLayout(
        disableSidebar: true,
        activeRoute: '/admin/procedures',
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return AdminDashboardLayout(
        disableSidebar: true,
        activeRoute: '/admin/procedures',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading procedure'),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProcedure,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return AdminDashboardLayout(
      disableSidebar: true,
      activeRoute: '/admin/procedures',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Procedures'),
          ),

          const SizedBox(height: 12),

          // Header
          Text(
            'Edit Procedure',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Update your approval workflow',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
          ),

          const SizedBox(height: 24),

          // Visibility Section
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
                    _visibility.contains(ProcedureVisibility.student),
                    _visibility.contains(ProcedureVisibility.faculty),
                    _visibility.contains(ProcedureVisibility.guest),
                    _visibility.contains(ProcedureVisibility.all),
                  ],
                  onPressed: (index) {
                    setState(() {
                      final selected = ProcedureVisibility.values[index];

                      if (_visibility.contains(ProcedureVisibility.all) &&
                          selected != ProcedureVisibility.all) {
                        return;
                      }

                      if (selected == ProcedureVisibility.all) {
                        if (_visibility.contains(ProcedureVisibility.all)) {
                          _visibility.remove(ProcedureVisibility.all);
                        } else {
                          _visibility = {ProcedureVisibility.all};
                        }
                      } else {
                        if (_visibility.contains(selected)) {
                          _visibility.remove(selected);
                        } else {
                          _visibility.add(selected);
                        }
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Student'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Faculty'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Guest'),
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

          // Title Input
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

          // Workflow Canvas - Form Builder
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
                (index) => ApprovalLevelCard(
                  level: index + 1,
                  roles: _approvalLevels[index].roles,
                  minApprovals: _approvalLevels[index].minApprovals,
                  allMustApprove: _approvalLevels[index].allMustApprove,
                  onRemove: () => _removeApprovalLevel(index),
                  onAddRole: () => _openAddRoleDialog(index),
                  onRemoveRole: (role) {
                    setState(() {
                      final level = _approvalLevels[index];
                      level.roles.removeWhere(
                        (r) => r['role_tag'] == role['role_tag'],
                      );

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

          // Add Step Section
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
              if (!_hasForm)
                AddStepButton(
                  icon: Icons.description,
                  color: Colors.blue,
                  title: 'Form Builder',
                  subtitle: 'Collect request data',
                  onTap: _onFormBuilderClick,
                ),
              AddStepButton(
                icon: Icons.how_to_reg,
                color: Colors.green,
                title: 'Add Approval Level',
                subtitle: 'Add reviewers manually',
                onTap: _addApprovalLevel,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _updateProcedure,
                icon: const Icon(Icons.save),
                label: const Text('Update Procedure'),
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
