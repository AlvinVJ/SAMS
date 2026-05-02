import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/admin_service.dart';

class RoleAssignmentDialog extends StatefulWidget {
  final dynamic role;

  const RoleAssignmentDialog({super.key, required this.role});

  @override
  State<RoleAssignmentDialog> createState() => _RoleAssignmentDialogState();
}

class _RoleAssignmentDialogState extends State<RoleAssignmentDialog> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _assignedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _adminService.getRoleUsers(widget.role['role_id']);
      setState(() {
        _assignedUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _searchAndAssign() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const _UserSearchDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _adminService.assignRoleUser(
          widget.role['role_id'],
          result['mits_uid'],
        );
        _fetchUsers();
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _removeUser(String mitsUid) async {
    setState(() => _isLoading = true);
    try {
      await _adminService.removeRoleUser(widget.role['role_id'], mitsUid);
      _fetchUsers();
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
            child: Text(
              'Manage Role: ${widget.role['role_tag']}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _searchAndAssign,
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Assign Person'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _assignedUsers.isEmpty
                ? const Center(
                    child: Text(
                      'No users assigned to this role.',
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  )
                : ListView.separated(
                    itemCount: _assignedUsers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = _assignedUsers[index];
                      final isFaculty = user['type'] == 'FACULTY';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isFaculty
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          child: Text(
                            isFaculty ? 'F' : 'S',
                            style: TextStyle(
                              color: isFaculty ? Colors.blue : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('ID: ${user['mits_uid']}'),
                            Text(
                              'Dept: ${user['department']}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _removeUser(user['mits_uid']),
                          tooltip: 'Remove Role',
                        ),
                      );
                    },
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

class _UserSearchDialog extends StatefulWidget {
  const _UserSearchDialog();

  @override
  State<_UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<_UserSearchDialog> {
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
      title: const Text('Search Users'),
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
                    final user = _results[index];
                    final isFaculty =
                        user['UserTypes']['user_type_tag'] == 'FACULTY';
                    final profile =
                        isFaculty ? user['Faculty'] : user['Student'];

                    if (profile == null) return const SizedBox.shrink();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isFaculty
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        child: Text(
                          isFaculty ? 'F' : 'S',
                          style: TextStyle(
                            color: isFaculty ? Colors.blue : Colors.orange,
                          ),
                        ),
                      ),
                      title: Text(profile['name'] ?? 'Unknown'),
                      subtitle: Text(user['mits_uid']),
                      onTap: () => Navigator.pop(context, user),
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
