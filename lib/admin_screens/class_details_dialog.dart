import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/admin_service.dart';

class ClassDetailsDialog extends StatefulWidget {
  final dynamic classData;

  const ClassDetailsDialog({super.key, required this.classData});

  @override
  State<ClassDetailsDialog> createState() => _ClassDetailsDialogState();
}

class _ClassDetailsDialogState extends State<ClassDetailsDialog> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _students = [];
  late List<dynamic> _facultyAdvisors;

  @override
  void initState() {
    super.initState();
    _facultyAdvisors = widget.classData['ClassFaculty'] ?? [];
    _fetchStudents();
    _fetchFacultyRoles();
  }

  Future<void> _fetchFacultyRoles() async {
    try {
      final updatedRoles = await _adminService.getClassFacultyRoles(widget.classData['class_id']);
      if (mounted) {
        setState(() {
          _facultyAdvisors = updatedRoles;
        });
      }
    } catch (e) {
      debugPrint('Error fetching faculty roles: $e');
    }
  }

  Future<void> _fetchStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _adminService.getClassStudents(widget.classData['class_id']);
      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _assignAdvisor(int position, {dynamic oldAdvisor}) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => _FacultySearchDialog(
        deptId: widget.classData['dept_id'],
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final classId = widget.classData['class_id'];
        final roleTag = 'CLASS_ADVISOR';

        await _adminService.assignClassRole(
          classId, 
          result['mits_uid'], 
          roleTag,
          replaceMitsUid: oldAdvisor?['mits_uid'],
        );
        
        // Refresh class data (just the faculty roles part for simplicity, or we can just pop and let parent refresh)
        // Since we don't have a specific endpoint to fetch just ONE class, it's easier to pop(true) to tell parent to refresh,
        // OR we can update the local state manually. But we need the full faculty info.
        // Let's just pop(true) and let the parent refresh everything, or we can just fetch the roles.
        final updatedRoles = await _adminService.getClassFacultyRoles(classId);
        setState(() {
          _facultyAdvisors = updatedRoles;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _removeAdvisor(dynamic advisor) async {
    setState(() => _isLoading = true);
    try {
      await _adminService.removeClassRole(
        widget.classData['class_id'],
        advisor['mits_uid'],
        'CLASS_ADVISOR',
      );
      final updatedRoles = await _adminService.getClassFacultyRoles(widget.classData['class_id']);
      setState(() {
        _facultyAdvisors = updatedRoles;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class: ${widget.classData['class']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.classData['Departments']['dept_name']} | Batch: ${widget.classData['Batches']['batch']}',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, true), // pop(true) to indicate changes might have happened
          ),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 600,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Faculty Advisors
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Faculty Advisors',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          _buildAdvisorCard(1),
                          const SizedBox(height: 16),
                          _buildAdvisorCard(2),
                        ],
                      ),
                    ),
                  ),
                  // Right side: Students
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Students (${_students.length})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _students.isEmpty
                                ? const Center(child: Text('No students found.'))
                                : ListView.separated(
                                    itemCount: _students.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final student = _students[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                                          child: Text(
                                            student['gender'] == 'M'
                                                ? 'M'
                                                : student['gender'] == 'F'
                                                    ? 'F'
                                                    : '?',
                                            style: const TextStyle(color: AppTheme.primary),
                                          ),
                                        ),
                                        title: Text(student['name']),
                                        subtitle: Text(student['mits_uid']),
                                        trailing: student['email'] != null 
                                            ? const Icon(Icons.email_outlined, size: 16, color: Colors.grey) 
                                            : null,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAdvisorCard(int position) {
    // We just take the advisor at index (position - 1)
    final advisorRecord = _facultyAdvisors.length >= position 
        ? _facultyAdvisors[position - 1] 
        : null;

    final faculty = advisorRecord?['Faculty'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advisor $position',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              if (faculty != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                      onPressed: () => _assignAdvisor(position, oldAdvisor: advisorRecord),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: () => _removeAdvisor(advisorRecord),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (faculty != null) ...[
            Text(faculty['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(faculty['mits_uid'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ] else ...[
            Center(
              child: TextButton.icon(
                onPressed: () => _assignAdvisor(position),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Assign'),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// Reused Faculty Search Dialog
class _FacultySearchDialog extends StatefulWidget {
  final int deptId;
  const _FacultySearchDialog({required this.deptId});

  @override
  State<_FacultySearchDialog> createState() => _FacultySearchDialogState();
}

class _FacultySearchDialogState extends State<_FacultySearchDialog> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return;
    setState(() => _isSearching = true);
    try {
      final results = await _adminService.searchFaculty(query, widget.deptId);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Faculty'),
      content: SizedBox(
        width: 400,
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
              const Center(child: CircularProgressIndicator())
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final faculty = _results[index];
                    return ListTile(
                      title: Text(faculty['name']),
                      subtitle: Text(faculty['mits_uid']),
                      onTap: () => Navigator.pop(context, faculty),
                    );
                  },
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
      ],
    );
  }
}
