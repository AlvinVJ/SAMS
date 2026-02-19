import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/admin_service.dart';
import 'department_faculty_dialog.dart';
import 'batch_classes_dialog.dart';

class AcademicStructureScreen extends StatefulWidget {
  const AcademicStructureScreen({super.key});

  @override
  State<AcademicStructureScreen> createState() =>
      _AcademicStructureScreenState();
}

class _AcademicStructureScreenState extends State<AcademicStructureScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _departments = [];
  List<dynamic> _batches = [];
  List<dynamic> _roles = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminService.getDepartments(),
        _adminService.getBatches(),
        _adminService.getRoles(),
      ]);
      setState(() {
        _departments = results[0];
        _batches = results[1];
        _roles = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/academic-structure',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 24),
                  _sectionTitle('Departments'),
                  _entityGrid(_departments, 'department'),
                  const SizedBox(height: 32),
                  _sectionTitle('Batches'),
                  _entityGrid(_batches, 'batch'),
                  const SizedBox(height: 32),
                  _sectionTitle('Roles'),
                  _entityGrid(_roles, 'role'),
                ],
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Structure',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage the foundational organization of the institution.',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    String singular = title == 'Roles'
        ? 'Role'
        : (title.endsWith('es')
              ? title.substring(0, title.length - 2)
              : title.substring(0, title.length - 1));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),

            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(singular.toLowerCase()),
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add $singular'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showCSVFormatDialog(String type) {
    List<List<String>> rows = [];
    if (type == 'department') {
      rows = [
        ['type', 'Yes', '"department"'],
        ['dept_id', 'Yes', 'Numeric Department ID'],
        ['dept_name', 'Yes', 'Name of Department'],
      ];
    } else if (type == 'batch') {
      rows = [
        ['type', 'Yes', '"batch"'],
        ['batch_id', 'Yes', 'Numeric Batch ID'],
        ['batch', 'Yes', 'Batch Name (e.g. 2021)'],
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${type[0].toUpperCase()}${type.substring(1)} CSV Format'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'When using bulk import, ensure your CSV columns match the following keys:',
                style: TextStyle(fontSize: 14, color: AppTheme.textLight),
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: Colors.grey.shade200),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    children: ['Key', 'Required', 'Description']
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  ...rows.map(
                    (row) => TableRow(
                      children: row
                          .map(
                            (cell) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                cell,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _entityGrid(List<dynamic> data, String type) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return InkWell(
          onTap: type == 'department'
              ? () => _showDepartmentFacultyDialog(item)
              : type == 'batch'
                  ? () => _showBatchClassesDialog(item)
                  : () => _showEditDialog(item, type), // Roles can be edited by tap or icon
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  type == 'department'
                      ? Icons.business
                      : type == 'batch'
                      ? Icons.calendar_today
                      : Icons.person_outline,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type == 'department'
                            ? item['dept_name']
                            : type == 'batch'
                            ? item['batch']
                            : item['role_tag'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Edit Icon
                IconButton(
                  icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                  onPressed: () => _showEditDialog(item, type),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                // Delete Icon
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  onPressed: () => _handleDelete(item, type),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDepartmentFacultyDialog(dynamic department) {
    showDialog(
      context: context,
      builder: (context) => DepartmentFacultyDialog(department: department),
    ).then((_) => _fetchData());
  }

  void _showBatchClassesDialog(dynamic batch) {
    showDialog(
      context: context,
      builder: (context) => BatchClassesDialog(batch: batch),
    ).then((_) => _fetchData());
  }

  void _showAddDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descController = TextEditingController();

        return AlertDialog(
          title: Text('Add New $type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: type == 'role' ? 'Role Tag' : 'Name / Title',
                    hintText: type == 'role' ? 'e.g. PRINCIPAL' : 'e.g. IT',
                  ),
                ),
                if (type == 'role')
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g. Institution Principal',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final name = nameController.text;

                  if (name.isEmpty) {
                    throw Exception("Please fill all required fields");
                  }

                  if (type == 'department') {
                    await _adminService.createDepartment(name);
                  } else if (type == 'batch') {
                    await _adminService.createBatch(name);
                  } else if (type == 'role') {
                    await _adminService.createRole(name, descController.text);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(dynamic item, String type) {
    final nameController = TextEditingController(
      text: type == 'department'
          ? item['dept_name']
          : type == 'batch'
              ? item['batch']
              : item['role_tag'],
    );
    final descController = TextEditingController(
      text: type == 'role' ? item['role_desc'] ?? '' : '',
    );
    bool isActive = item['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${type[0].toUpperCase()}${type.substring(1)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: type == 'department'
                      ? 'Department Name'
                      : type == 'batch'
                          ? 'Batch Year'
                          : 'Role Tag',
                ),
              ),
              if (type == 'role') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                value: isActive,
                onChanged: (val) => setDialogState(() => isActive = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (type == 'department') {
                    await _adminService.updateDepartment({
                      'dept_id': item['dept_id'],
                      'dept_name': nameController.text,
                      'is_active': isActive,
                    });
                  } else if (type == 'batch') {
                    await _adminService.updateBatch({
                      'batch_id': item['batch_id'],
                      'batch': nameController.text,
                      'is_active': isActive,
                    });
                  } else if (type == 'role') {
                    await _adminService.updateRole({
                      'role_id': item['role_id'],
                      'role_tag': nameController.text,
                      'role_desc': descController.text,
                      'is_active': isActive,
                    });
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    _fetchData();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(dynamic item, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (type == 'department') {
                  await _adminService.deleteDepartment(item['dept_id']);
                } else if (type == 'batch') {
                  await _adminService.deleteBatch(item['batch_id']);
                } else if (type == 'role') {
                  await _adminService.deleteRole(item['role_id']);
                }
                if (mounted) {
                  Navigator.pop(context);
                  _fetchData();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
