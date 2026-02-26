import 'package:flutter/material.dart';
import 'package:sams_final/services/auth_service.dart';
import '../styles/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final String? activeRoute;
  final bool isCollapsed;
  const AppSidebar({
    super.key,
    required this.activeRoute,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(24.0),
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
                  child: const Icon(Icons.school, color: Colors.white),
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
                          'Student Portal',
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

          // Navigation Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  isActive: activeRoute == '/',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                _NavItem(
                  icon: Icons.format_list_bulleted,
                  label: 'My Requests',
                  isActive: activeRoute == '/requests',
                  isCollapsed: isCollapsed,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/requests'),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Create Request',
                  isActive: activeRoute == '/create-request',
                  isCollapsed: isCollapsed,
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/create-request',
                  ),
                ),
                _NavItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  isActive: activeRoute == '/notifications',
                  isCollapsed: isCollapsed,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/notifications'),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isActive: activeRoute == '/settings',
                  isCollapsed: isCollapsed,
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/settings'),
                ),
              ],
            ),
          ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _NavItem(
              icon: Icons.logout,
              label: 'Logout',
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
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isCollapsed = false,
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
                    color: isActive ? Colors.white : AppTheme.textLight,
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
