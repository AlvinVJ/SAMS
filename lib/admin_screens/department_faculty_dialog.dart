import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/admin_service.dart';

class DepartmentFacultyDialog extends StatefulWidget {
  final dynamic department;

  const DepartmentFacultyDialog({super.key, required this.department});

  @override
  State<DepartmentFacultyDialog> createState() =>
      _DepartmentFacultyDialogState();
}

class _DepartmentFacultyDialogState extends State<DepartmentFacultyDialog> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  dynamic _hod;
  dynamic _asstHod;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    setState(() => _isLoading = true);
    try {
      final roles = await _adminService.getDepartmentFacultyRoles(
        widget.department['dept_id'],
      );
      setState(() {
        _hod = roles.firstWhere(
          (r) => r['Roles']['role_tag'] == 'HOD',
          orElse: () => null,
        );
        _asstHod = roles.firstWhere(
          (r) => r['Roles']['role_tag'] == 'ASSISTANT HOD',
          orElse: () => null,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _searchAndAssign(String roleTag) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => _FacultySearchDialog(deptId: widget.department['dept_id']),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _adminService.assignDepartmentRole(
          widget.department['dept_id'],
          result['mits_uid'],
          roleTag,
        );
        _fetchRoles();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _removeRole(String mitsUid) async {
    setState(() => _isLoading = true);
    try {
      await _adminService.removeDepartmentRole(mitsUid);
      _fetchRoles();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Manage ${widget.department['dept_name']} Faculty'),
      content: SizedBox(
        width: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roleCard('Head of Department (HOD)', 'HOD', _hod),
                  const SizedBox(height: 16),
                  _roleCard('Assistant HOD', 'ASSISTANT HOD', _asstHod),
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

  Widget _roleCard(String title, String roleTag, dynamic assigned) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              if (assigned != null)
                TextButton.icon(
                  onPressed: () => _searchAndAssign(roleTag),
                  icon: const Icon(Icons.swap_horiz, size: 14),
                  label: const Text('Change', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (assigned != null) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    assigned['Faculty']['name'][0],
                    style: const TextStyle(color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assigned['Faculty']['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        assigned['mits_uid'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeRole(assigned['mits_uid']),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Not Assigned',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _searchAndAssign(roleTag),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Assign Faculty'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  elevation: 0,
                  side: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
                    final user = _results[index];
                    final isFaculty = user['UserTypes']['user_type_tag'] == 'FACULTY';
                    final profile = isFaculty ? user['Faculty'] : user['Student'];
                    
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(isFaculty ? 'F' : 'S'),
                        backgroundColor: isFaculty ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      ),
                      title: Text(profile['name']),
                      subtitle: Text(user['mits_uid']),
                      onTap: () => Navigator.pop(context, user),
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
