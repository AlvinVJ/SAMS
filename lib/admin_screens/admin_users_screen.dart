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
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final roles = await _adminService.getRoles();
      if (mounted) {
        setState(() => _roles = roles);
      }
    } catch (e) {
      debugPrint("Error fetching roles: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _adminService.getUsers(query: query),
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

    // Current roles
    final List roleMappings = user['RoleMapping'] ?? [];
    List<int> selectedRoleIds = roleMappings
        .map<int>((m) => m['role_id'] as int)
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit User: ${user['mits_uid']}'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Roles',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedRoleIds.map((rid) {
                    final role = _roles.firstWhere(
                      (r) => r['role_id'] == rid,
                      orElse: () => null,
                    );
                    return Chip(
                      label: Text(role?['role_tag'] ?? rid.toString()),
                      onDeleted: () {
                        setDialogState(() => selectedRoleIds.remove(rid));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  key: ValueKey("edit_role_${selectedRoleIds.length}"),
                  value: null,
                  decoration: const InputDecoration(
                    labelText: 'Add Role',
                    border: OutlineInputBorder(),
                  ),
                  items: _roles
                      .where((r) => !selectedRoleIds.contains(r['role_id']))
                      .map(
                        (r) => DropdownMenuItem<int>(
                          value: (r['role_id'] is int)
                              ? r['role_id']
                              : int.tryParse(r['role_id'].toString()),
                          child: Text(r['role_tag'] ?? "Unnamed"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedRoleIds.add(val));
                    }
                  },
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
                  await _adminService.updateUser(user['mits_uid'], {
                    'name': nameController.text,
                    'role_ids': selectedRoleIds,
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

  void _showAddUserDialog() {
    final uidController = TextEditingController();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    List<int> selectedRoleIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Fetch roles if not already fetched
          if (_roles.isEmpty) {
            _adminService.getRoles().then((val) {
              if (mounted) {
                setState(() => _roles = val);
                setDialogState(() {}); // Rebuild dialog
              }
            });
          }

          return AlertDialog(
            title: const Text('Add New User'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: uidController,
                      decoration: const InputDecoration(
                        labelText: 'MITS UID (Required)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., MITS001',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name (Required)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Assign Roles',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedRoleIds.map((rid) {
                        final role = _roles.firstWhere(
                          (r) => r['role_id'] == rid,
                          orElse: () => null,
                        );
                        return Chip(
                          label: Text(role?['role_tag'] ?? rid.toString()),
                          onDeleted: () =>
                              setDialogState(() => selectedRoleIds.remove(rid)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      key: ValueKey("add_role_${selectedRoleIds.length}"),
                      value: null,
                      decoration: InputDecoration(
                        labelText: 'Add a Role',
                        border: const OutlineInputBorder(),
                        hintText: (_roles.isEmpty) ? "Loading roles..." : null,
                      ),
                      items: _roles
                          .where((r) => !selectedRoleIds.contains(r['role_id']))
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: (r['role_id'] is int)
                                  ? r['role_id']
                                  : int.tryParse(r['role_id'].toString()),
                              child: Text(r['role_tag'] ?? "Unnamed"),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedRoleIds.add(val));
                        }
                      },
                    ),
                    if (_roles.isNotEmpty &&
                        _roles
                            .where(
                              (r) => !selectedRoleIds.contains(r['role_id']),
                            )
                            .isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "All available roles assigned.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (uidController.text.trim().isEmpty ||
                      nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('MITS UID and Name are required'),
                      ),
                    );
                    return;
                  }
                  try {
                    await _adminService.createUser({
                      'mits_uid': uidController.text.trim(),
                      'name': nameController.text.trim(),
                      'email': emailController.text.trim().isEmpty
                          ? null
                          : emailController.text.trim(),
                      'user_type_tag':
                          'FACULTY', // Default for staff/admin additions
                      'role_ids': selectedRoleIds,
                    });
                    Navigator.pop(context);
                    _fetchData(query: uidController.text.trim());
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create User'),
              ),
            ],
          );
        },
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
        ElevatedButton.icon(
          onPressed: _showAddUserDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
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
    List<String> roleTags = [];
    if (roles.isNotEmpty) {
      for (var m in roles) {
        if (m['Roles'] != null) {
          roleTags.add(m['Roles']['role_tag']?.toString() ?? 'User');
        }
      }
    }

    if (roleTags.isEmpty) {
      if (u['UserTypes'] != null) {
        roleTags.add(u['UserTypes']['user_type_tag']?.toString() ?? 'User');
      } else {
        roleTags.add('User');
      }
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
        DataCell(_rolesWrap(roleTags)),
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

  Widget _rolesWrap(List<String> roles) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: roles.map((r) => _role(r)).toList(),
    );
  }

  Widget _role(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
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
