import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/admin_service.dart';

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
  List<dynamic> _classes = [];

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
        _adminService.getClasses(),
      ]);
      setState(() {
        _departments = results[0];
        _batches = results[1];
        _classes = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                  _sectionTitle('Classes'),
                  _classTable(),
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
    String singular = title.endsWith('es')
        ? title.substring(0, title.length - 2)
        : title.substring(0, title.length - 1);

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
              IconButton(
                onPressed: () => _showCSVFormatDialog(singular.toLowerCase()),
                icon: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppTheme.textLight,
                ),
                tooltip: 'CSV Format Hint',
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
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
    } else if (type == 'class') {
      rows = [
        ['type', 'Yes', '"class"'],
        ['class_id', 'Yes', 'Numeric Class ID'],
        ['batch_id', 'Yes', 'Numeric Batch ID'],
        ['class', 'Yes', 'Class Name (e.g. CS-A)'],
        ['dept_id', 'Yes', 'Numeric Department ID'],
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
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                type == 'department' ? Icons.business : Icons.calendar_today,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type == 'department' ? item['dept_name'] : item['batch'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _classTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Class Name')),
          DataColumn(label: Text('Department')),
          DataColumn(label: Text('Batch')),
          DataColumn(label: Text('Status')),
        ],
        rows: _classes.map((c) {
          return DataRow(
            cells: [
              DataCell(Text(c['class'])),
              DataCell(Text(c['Departments']['dept_name'])),
              DataCell(Text(c['Batches']['batch'])),
              DataCell(Text(c['is_active'] ? 'Active' : 'Inactive')),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddDialog(String type) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final idController = TextEditingController();
        dynamic selectedDept;
        dynamic selectedBatch;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add New $type'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: 'ID (Number)',
                        hintText: 'e.g. 101',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name / Title',
                        hintText: type == 'class' ? 'e.g. CS-A' : 'e.g. IT',
                      ),
                    ),
                    if (type == 'class') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<dynamic>(
                        value: selectedDept,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                        ),
                        items: _departments.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d['dept_name']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedDept = val),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<dynamic>(
                        value: selectedBatch,
                        decoration: const InputDecoration(labelText: 'Batch'),
                        items: _batches.map((b) {
                          return DropdownMenuItem(
                            value: b,
                            child: Text(b['batch']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedBatch = val),
                      ),
                    ],
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
                      final id = int.parse(idController.text);
                      final name = nameController.text;

                      if (type == 'department') {
                        await _adminService.createDepartment(id, name);
                      } else if (type == 'batch') {
                        await _adminService.createBatch(id, name);
                      } else if (type == 'class') {
                        if (selectedDept == null || selectedBatch == null) {
                          throw Exception("Please select Department and Batch");
                        }
                        await _adminService.createClass(
                          id,
                          name,
                          selectedBatch['batch_id'],
                          selectedDept['dept_id'],
                        );
                      }

                      Navigator.pop(context);
                      _fetchData();
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
      },
    );
  }
}
