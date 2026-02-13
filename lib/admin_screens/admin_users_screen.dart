import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;
  bool _hasSearched = false;
  List<dynamic> _filteredUsers = [];
  List<dynamic> _roles = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminService.getUsers(query: query), // Pass query to service
        _adminService.getRoles(),
      ]);
      setState(() {
        _filteredUsers =
            results[0]; // _filteredUsers will now directly reflect fetched data
        _roles = results[1];
        _isLoading = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _triggerSearch() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await _fetchData(query: query);
    } else {
      setState(() {
        _filteredUsers = [];
        _hasSearched = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a UID or Name to search')),
      );
    }
  }

  Future<void> _toggleUserStatus(dynamic user) async {
    final bool currentStatus = user['is_active'] ?? true;
    final String mitsUid = user['mits_uid'];

    try {
      await _adminService.updateUser(mitsUid, {'is_active': !currentStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User ${!currentStatus ? 'activated' : 'deactivated'} successfully',
          ),
        ),
      );
      _fetchData(
        query: _searchController.text.trim(),
      ); // Refresh list with current query
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  void _showEditUserDialog(dynamic user) {
    final nameController = TextEditingController(
      text: user['Student']?['name'] ?? user['Faculty']?['name'] ?? '',
    );

    // Find current role id
    final List roleMappings = user['RoleMapping'] ?? [];
    int? selectedRoleId = roleMappings.isNotEmpty
        ? roleMappings[0]['role_id']
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit User: ${user['mits_uid']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedRoleId,
                decoration: const InputDecoration(
                  labelText: 'Specific Role (HOD, Advisor, etc.)',
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('No Specific Role'),
                  ),
                  ..._roles
                      .map(
                        (r) => DropdownMenuItem<int>(
                          value: r['role_id'],
                          child: Text(r['role_tag']),
                        ),
                      )
                      .toList(),
                ],
                onChanged: (val) => setDialogState(() => selectedRoleId = val),
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
                  await _adminService.updateUser(user['mits_uid'], {
                    'name': nameController.text,
                    'role_id': selectedRoleId,
                  });
                  Navigator.pop(context);
                  _fetchData(query: _searchController.text.trim());
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/users',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          const SizedBox(height: 16),
          _filters(),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              : (_hasSearched && _filteredUsers.isEmpty)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No users found matching your search.'),
                  ),
                )
              : (!_hasSearched)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('Enter a UID or name to search for users.'),
                  ),
                )
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
            Text('Users', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            const Text(
              'Manage system users, roles, and access permissions.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, email or UID...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _triggerSearch,
                ),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _triggerSearch(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table() {
    return Container(
      decoration: _card(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 16,
                headingRowHeight: 52,
                dataRowMaxHeight: 64,
                headingRowColor: WidgetStateProperty.all(
                  AppTheme.backgroundLight,
                ),
                columns: const [
                  DataColumn(label: _Header('User')),
                  DataColumn(label: _Header('UID')),
                  DataColumn(label: _Header('Role')),
                  DataColumn(label: _Header('Affiliation')),
                  DataColumn(label: _Header('Email')),
                  DataColumn(label: _Header('Actions')),
                ],
                rows: _filteredUsers.map(_row).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  DataRow _row(dynamic u) {
    final String name =
        (u['Student']?['name'] ??
                u['Faculty']?['name'] ??
                u['mits_uid'] ??
                'Unknown User')
            .toString();

    final String email = (u['email'] ?? 'No Email').toString();

    final String uid = (u['mits_uid'] ?? 'N/A').toString();
    final bool isActive = u['is_active'] ?? true;

    final List roles = u['RoleMapping'] ?? [];
    String roleStr = 'User';
    if (roles.isNotEmpty && roles[0]['Roles'] != null) {
      roleStr = roles[0]['Roles']['role_tag']?.toString() ?? 'User';
    } else if (u['UserTypes'] != null) {
      roleStr = u['UserTypes']['user_type_tag']?.toString() ?? 'User';
    }

    String affiliation = 'N/A';
    if (u['Student'] != null) {
      final className =
          u['Student']['Classes']?['class']?.toString() ?? 'No Class';
      final batchName =
          u['Student']['Batches']?['batch']?.toString() ?? 'No Batch';
      affiliation = "$className ($batchName)";
    } else if (u['Faculty'] != null) {
      affiliation =
          u['Faculty']['Departments']?['dept_name']?.toString() ?? 'No Dept';
    }

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              _avatar(name),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _status(isActive),
                ],
              ),
            ],
          ),
        ),
        DataCell(_cellText(uid)),
        DataCell(_role(roleStr)),
        DataCell(_cellText(affiliation)),
        DataCell(_cellText(email)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: AppTheme.primary),
                onPressed: () => _showEditUserDialog(u),
              ),
              IconButton(
                icon: Icon(
                  isActive ? Icons.block : Icons.check_circle_outline,
                  size: 18,
                  color: isActive ? Colors.red : Colors.green,
                ),
                onPressed: () => _toggleUserStatus(u),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _status(bool active) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          active ? 'Active' : 'Blocked',
          style: TextStyle(
            fontSize: 10,
            color: active ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _avatar(String name) {
    String initials = '??';
    try {
      final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        initials = parts.take(2).map((e) => e[0]).join().toUpperCase();
      }
    } catch (_) {}
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E7FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4338CA),
          ),
        ),
      ),
    );
  }

  Widget _role(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cellText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
    );
  }

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  );
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
      ),
    );
  }
}
