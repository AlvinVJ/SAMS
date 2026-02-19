import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/admin_service.dart';
import 'department_faculty_dialog.dart';

class BatchClassesDialog extends StatefulWidget {
  final dynamic batch;

  const BatchClassesDialog({super.key, required this.batch});

  @override
  State<BatchClassesDialog> createState() => _BatchClassesDialogState();
}

class _BatchClassesDialogState extends State<BatchClassesDialog> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _classes = [];
  List<dynamic> _departments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminService.getClasses(batchId: widget.batch['batch_id']),
        _adminService.getDepartments(),
      ]);
      setState(() {
        _classes = results[0];
        _departments = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addClass() async {
    final nameController = TextEditingController();
    dynamic selectedDept;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'e.g. CSE-A',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<dynamic>(
                value: selectedDept,
                decoration: const InputDecoration(labelText: 'Department'),
                items: _departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept['dept_name']),
                  );
                }).toList(),
                onChanged: (val) => setDialogState(() => selectedDept = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedDept == null) return;
                try {
                  await _adminService.createClass(
                    nameController.text,
                    widget.batch['batch_id'],
                    selectedDept['dept_id'],
                  );
                  if (mounted) Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _fetchData();
    }
  }

  Future<void> _assignAdvisor(dynamic classItem, int advisorSlot, {dynamic oldAdvisor}) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const FacultySearchDialog(),
    );

    if (result != null) {
      if (oldAdvisor != null && result['mits_uid'] == oldAdvisor['mits_uid']) {
        return; // No change
      }

      setState(() => _isLoading = true);
      try {
        if (oldAdvisor != null) {
          await _adminService.removeClassRole(
            classItem['class_id'],
            oldAdvisor['mits_uid'],
            'CLASS_ADVISOR',
          );
        }
        await _adminService.assignClassRole(
          classItem['class_id'],
          result['mits_uid'],
          'CLASS_ADVISOR',
        );
        _fetchData();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeAdvisor(dynamic classItem, dynamic faculty) async {
    setState(() => _isLoading = true);
    try {
      await _adminService.removeClassRole(
        classItem['class_id'],
        faculty['mits_uid'],
        'CLASS_ADVISOR',
      );
      _fetchData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage ${widget.batch['batch']} Classes'),
      content: SizedBox(
        width: 900,
        height: 600,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Classes: ${_classes.length}',
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addClass,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Class'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _classes.isEmpty
                        ? const Center(child: Text('No classes found for this batch.'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.5),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(3),
                                3: FlexColumnWidth(3),
                              },
                              border: TableBorder.all(color: Colors.grey.shade200),
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(color: Colors.grey.shade100),
                                  children: const [
                                    _TableCell(text: 'Class', isHeader: true),
                                    _TableCell(text: 'Department', isHeader: true),
                                    _TableCell(text: 'Advisor 1', isHeader: true),
                                    _TableCell(text: 'Advisor 2', isHeader: true),
                                  ],
                                ),
                                ..._classes.map((c) {
                                  final facultyList = c['ClassFaculty'] ?? [];
                                  final advisor1 = facultyList.isNotEmpty ? facultyList[0] : null;
                                  final advisor2 = facultyList.length > 1 ? facultyList[1] : null;

                                  return TableRow(
                                    children: [
                                      _TableCell(text: c['class']),
                                      _TableCell(text: c['Departments']['dept_name']),
                                      _AdvisorCell(
                                        advisor: advisor1,
                                        onAssign: () => _assignAdvisor(c, 1),
                                        onEdit: () => _assignAdvisor(c, 1, oldAdvisor: advisor1),
                                        onRemove: advisor1 != null ? () => _removeAdvisor(c, advisor1['Faculty']) : null,
                                      ),
                                      _AdvisorCell(
                                        advisor: advisor2,
                                        onAssign: () => _assignAdvisor(c, 2),
                                        onEdit: () => _assignAdvisor(c, 2, oldAdvisor: advisor2),
                                        onRemove: advisor2 != null ? () => _removeAdvisor(c, advisor2['Faculty']) : null,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
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
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 13 : 12,
        ),
      ),
    );
  }
}

class _AdvisorCell extends StatelessWidget {
  final dynamic advisor;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback? onRemove;

  const _AdvisorCell({
    this.advisor,
    required this.onAssign,
    required this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (advisor == null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton.icon(
          onPressed: onAssign,
          icon: const Icon(Icons.person_add_alt_1, size: 14),
          label: const Text('Assign', style: TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    final faculty = advisor['Faculty'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, size: 10, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        faculty['name'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Text(
                    advisor['mits_uid'],
                    style: const TextStyle(fontSize: 9, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 14, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class FacultySearchDialog extends StatefulWidget {
  const FacultySearchDialog({super.key});

  @override
  State<FacultySearchDialog> createState() => _FacultySearchDialogState();
}

class _FacultySearchDialogState extends State<FacultySearchDialog> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return;
    setState(() => _isSearching = true);
    try {
      final results = await _adminService.getUsers(query: query);
      setState(() {
        _results = results
            .where((u) => u['UserTypes']['user_type_tag'] == 'FACULTY')
            .toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Faculty'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or MITS ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => _performSearch(_searchController.text),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const CircularProgressIndicator()
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final faculty = _results[index];
                    return ListTile(
                      title: Text(faculty['Faculty']['name']),
                      subtitle: Text(faculty['mits_uid']),
                      onTap: () => Navigator.pop(context, faculty),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
