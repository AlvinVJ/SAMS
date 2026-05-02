import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/admin_service.dart';

class ClubDetailsDialog extends StatefulWidget {
  final dynamic club;

  const ClubDetailsDialog({super.key, required this.club});

  @override
  State<ClubDetailsDialog> createState() => _ClubDetailsDialogState();
}

class _ClubDetailsDialogState extends State<ClubDetailsDialog> {
  final AdminService _adminService = AdminService();
  late dynamic _clubData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clubData = widget.club;
  }

  Future<void> _refreshClubData() async {
    setState(() => _isLoading = true);
    try {
      final allClubs = await _adminService.getClubs();
      final updatedClub = allClubs.firstWhere(
        (c) => c['club_id'] == _clubData['club_id'],
        orElse: () => _clubData,
      );
      setState(() {
        _clubData = updatedClub;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changeCoordinator() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const _UserSearchDialog(userType: 'FACULTY'),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _adminService.assignClubRole(
          _clubData['club_id'],
          result['mits_uid'],
          'CLUB_COORDINATOR',
        );
        await _refreshClubData();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _addLead() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => const _UserSearchDialog(userType: 'STUDENT'),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await _adminService.assignClubRole(
          _clubData['club_id'],
          result['mits_uid'],
          'CLUB_LEAD',
        );
        await _refreshClubData();
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _removeLead(dynamic admin) async {
    setState(() => _isLoading = true);
    try {
      await _adminService.removeClubRole(
        _clubData['club_id'],
        admin['mits_uid'],
        'CLUB_LEAD',
      );
      await _refreshClubData();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coordinatorName = _clubData['coordinatorName'] ?? 'Not Assigned';
    final coordinatorUid = _clubData['coordinatorUid'] ?? '-';
    final deptName = _clubData['Departments']?['dept_name'] ?? 'General';
    final admins = _clubData['admins'] as List<dynamic>? ?? [];

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _clubData['club_name'] ?? 'Unnamed Club',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Department: $deptName',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, true), // pop true to refresh parent
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Faculty Coordinator / Advisor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    TextButton.icon(
                      onPressed: _changeCoordinator,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coordinatorName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              coordinatorUid,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Student Leads / Admins (${admins.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addLead,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Lead'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (admins.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No student leads assigned.'),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: admins.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final admin = admins[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(Icons.person_outline, color: Colors.blue),
                          ),
                          title: Text(admin['adminName'] ?? 'Unknown'),
                          subtitle: Text(admin['mits_uid'] ?? '-'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _removeLead(admin),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

class _UserSearchDialog extends StatefulWidget {
  final String userType;
  const _UserSearchDialog({required this.userType});

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
        _results = results.where((u) => u['UserTypes']['user_type_tag'] == widget.userType).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search ${widget.userType == 'FACULTY' ? 'Faculty' : 'Student'}'),
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
                    final name = widget.userType == 'FACULTY' 
                      ? user['Faculty']['name'] 
                      : user['Student']['name'];
                    return ListTile(
                      title: Text(name),
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
