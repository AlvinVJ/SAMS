import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/admin_service.dart';

class DepartmentAllFacultyDialog extends StatefulWidget {
  final dynamic department;

  const DepartmentAllFacultyDialog({super.key, required this.department});

  @override
  State<DepartmentAllFacultyDialog> createState() => _DepartmentAllFacultyDialogState();
}

class _DepartmentAllFacultyDialogState extends State<DepartmentAllFacultyDialog> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _faculty = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final faculty = await _adminService.getDepartmentFacultyWithRoles(
        widget.department['dept_id'],
      );
      setState(() {
        _faculty = faculty;
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
          Text('${widget.department['dept_name']} Faculty'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 800,
        height: 600,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Text(
                          'Total Faculty: ${_faculty.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _faculty.isEmpty
                        ? const Center(child: Text('No faculty found in this department.'))
                        : ListView.separated(
                            itemCount: _faculty.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final f = _faculty[index];
                              final roles = f['RoleMapping'] as List<dynamic>? ?? [];
                              final classRoles = f['ClassFaculty'] as List<dynamic>? ?? [];
                              final deptRole = f['DepartmentFaculty'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppTheme.primary.withOpacity(0.1),
                                      child: Text(
                                        f['name'][0],
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            f['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            f['mits_uid'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textLight,
                                            ),
                                          ),
                                          if (roles.isNotEmpty || classRoles.isNotEmpty || deptRole != null) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                if (deptRole != null && deptRole['Roles'] != null)
                                                  _roleChip(
                                                    deptRole['Roles']['role_tag'],
                                                    icon: Icons.account_balance_outlined,
                                                    color: Colors.purple.shade50,
                                                    textColor: Colors.purple.shade800,
                                                  ),
                                                ...roles.map((r) => _roleChip(
                                                      r['Roles']['role_tag'],
                                                      icon: Icons.badge_outlined,
                                                    )),
                                                ...classRoles.map((cr) => _roleChip(
                                                      '${cr['Roles']['role_tag']} (${cr['Classes']['class']})',
                                                      color: Colors.blue.shade50,
                                                      textColor: Colors.blue.shade800,
                                                      icon: Icons.class_outlined,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _roleChip(String label, {Color? color, Color? textColor, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (color ?? Colors.green.shade200).withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? Colors.green.shade800),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
