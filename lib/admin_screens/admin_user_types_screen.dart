import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/admin_service.dart';

class AdminUserTypesScreen extends StatefulWidget {
  const AdminUserTypesScreen({super.key});

  @override
  State<AdminUserTypesScreen> createState() => _AdminUserTypesScreenState();
}

class _AdminUserTypesScreenState extends State<AdminUserTypesScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  List<dynamic> _userTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchUserTypes();
  }

  Future<void> _fetchUserTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _adminService.getUserTypes();
      if (mounted) {
        setState(() {
          _userTypes = types;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user types: $e')),
        );
      }
    }
  }

  void _showAddUserTypeDialog() {
    final tagController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Creating a user type will also automatically create a corresponding system role.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tagController,
              decoration: const InputDecoration(
                labelText: 'Type Tag (e.g., VISITOR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
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
              if (tagController.text.trim().isEmpty) return;
              try {
                await _adminService.createUserType(
                  tagController.text.trim().toUpperCase(),
                  descController.text.trim(),
                );
                Navigator.pop(context);
                _fetchUserTypes();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed: $e')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/user-types',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userTypes.isEmpty
                  ? const Center(child: Text('No user types found.'))
                  : _table(),
        ],
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
            Text('User Types', style: Theme.of(context).textTheme.headlineMedium),
            const Text(
              'Manage base identities and system roles.',
              style: TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddUserTypeDialog,
          icon: const Icon(Icons.add),
          label: const Text('Create Type'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _table() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Tag', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _userTypes.map((t) {
          final bool isActive = t['is_active'] ?? true;
          return DataRow(cells: [
            DataCell(Text(t['user_type_id'].toString())),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t['user_type_tag'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            )),
            DataCell(Text(t['description'] ?? 'No description')),
            DataCell(Row(
              children: [
                Icon(Icons.circle, size: 8, color: isActive ? Colors.green : Colors.red),
                const SizedBox(width: 4),
                Text(isActive ? 'Active' : 'Inactive'),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
