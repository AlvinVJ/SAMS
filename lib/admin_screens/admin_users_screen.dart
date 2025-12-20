import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  ///  DUMMY DATA — replace with API later
  static final List<_AdminUser> users = [
    _AdminUser(
      name: 'John Doe',
      email: 'john.doe@example.com',
      initials: 'JD',
      role: 'Admin',
      department: 'IT',
      lastActive: '2 hours ago',
      isActive: true,
      avatarBg: Color(0xFFE0E7FF),
      avatarText: Color(0xFF4338CA),
    ),
    _AdminUser(
      name: 'Sarah Smith',
      email: 'sarah.smith@example.com',
      initials: 'SS',
      role: 'Manager',
      department: 'HR',
      lastActive: '5 minutes ago',
      isActive: true,
      avatarBg: Color(0xFFFCE7F3),
      avatarText: Color(0xFFBE185D),
    ),
    _AdminUser(
      name: 'Lisa Brown',
      email: 'lisa.brown@example.com',
      initials: 'LB',
      role: 'Manager',
      department: 'Sales',
      lastActive: '2 days ago',
      isActive: false,
      avatarBg: Color(0xFFFFEDD5),
      avatarText: Color(0xFF9A3412),
    ),
  ];

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
          _table(),
        ],
      ),
    );
  }

  // ================= HEADER =================

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
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ================= FILTERS =================

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('All Roles'),
          ),
        ],
      ),
    );
  }

  // ================= DATATABLE =================

  Widget _table() {
    return Container(
      decoration: _card(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth, // 🔑 remove side whitespace
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 16, // 🔑 controlled margin
              headingRowHeight: 52,
              dataRowMaxHeight: 64,
              headingRowColor: WidgetStateProperty.all(
                AppTheme.backgroundLight,
              ),
              columns: const [
                DataColumn(label: _Header('User',)),
                DataColumn(label: _Header('Email')),
                DataColumn(label: _Header('Role')),
                DataColumn(label: _Header('Department')),
                DataColumn(label: _Header('Last Active')),
                DataColumn(label: _Header('Actions')),
              ],
              rows: users.map(_row).toList(),
            ),
          );
        },
      ),
    );
  }

  DataRow _row(_AdminUser u) {
    return DataRow(
      cells: [
        // USER CELL
        DataCell(
          Row(
            children: [
              _avatar(u),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _status(u.isActive),
                ],
              ),
            ],
          ),
        ),

        DataCell(_cellText(u.email)),
        DataCell(_role(u.role)),
        DataCell(_cellText(u.department)),
        DataCell(_cellText(u.lastActive)),

        DataCell(
          Row(
            children: const [
              Icon(Icons.edit, size: 18, color: AppTheme.primary),
              SizedBox(width: 12),
              Icon(Icons.block, size: 18, color: AppTheme.textLight),
            ],
          ),
        ),
      ],
    );
  }

  // ================= SMALL UI =================

  Widget _avatar(_AdminUser u) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: u.avatarBg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          u.initials,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: u.avatarText,
          ),
        ),
      ),
    );
  }

  Widget _status(bool active) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF22C55E) : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          active ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            color: active ? const Color(0xFF16A34A) : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        role,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _cellText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: AppTheme.textLight,
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      );
}

// ================= HELPERS =================

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

class _AdminUser {
  final String name;
  final String email;
  final String initials;
  final String role;
  final String department;
  final String lastActive;
  final bool isActive;
  final Color avatarBg;
  final Color avatarText;

  _AdminUser({
    required this.name,
    required this.email,
    required this.initials,
    required this.role,
    required this.department,
    required this.lastActive,
    required this.isActive,
    required this.avatarBg,
    required this.avatarText,
  });
}
