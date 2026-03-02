import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  final String? activeRoute;
  final bool isCollapsed;

  const AdminSidebar({super.key, this.activeRoute, this.isCollapsed = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo / Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user, color: Colors.white),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAMS',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Admin Panel',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: activeRoute == '/admin/dashboard',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/dashboard',
                  ),
                ),
                _NavItem(
                  icon: Icons.description,
                  label: 'Procedures',
                  isActive: activeRoute == '/admin/procedures',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/procedures',
                  ),
                ),
                _NavItem(
                  icon: Icons.inbox,
                  label: 'Requests',
                  isActive: activeRoute == '/admin/requests',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/requests',
                  ),
                ),
                _NavItem(
                  icon: Icons.group,
                  label: 'Users',
                  isActive: activeRoute == '/admin/users',
                  isCollapsed: isCollapsed,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/admin/users'),
                ),
                _NavItem(
                  icon: Icons.account_tree,
                  label: 'Academic Structure',
                  isActive: activeRoute == '/admin/academic-structure',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/academic-structure',
                  ),
                ),
                _NavItem(
                  icon: Icons.upload_file,
                  label: 'Data Import',
                  isActive: activeRoute == '/admin/data-import',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/data-import',
                  ),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isActive: activeRoute == '/admin/settings',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/settings',
                  ),
                ),
              ],
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: _NavItem(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: AppTheme.error,
              isCollapsed: isCollapsed,
              onTap: () async {
                await AuthService().signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isCollapsed = false,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isActive ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Tooltip(
            message: isCollapsed ? label : '',
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCollapsed ? 0 : 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: isCollapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? Colors.white
                        : (iconColor ?? AppTheme.textLight),
                    size: 20,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? Colors.white : AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
