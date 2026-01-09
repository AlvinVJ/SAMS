import 'package:flutter/material.dart';
import 'package:sams_final/services/auth_service.dart';
import '../styles/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final String? activeRoute;
  const AppSidebar({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
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
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAMS',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Student Portal',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  isActive: activeRoute == '/',
                  onTap: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                _NavItem(
                  icon: Icons.format_list_bulleted,
                  label: 'My Requests',
                  isActive: activeRoute == '/requests',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/requests'),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  label: 'Create Request',
                  isActive: activeRoute == '/create-request',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/create-request',
                  ),
                ),
                _NavItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  isActive: activeRoute == '/notifications',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/notifications'),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isActive: activeRoute == '/settings',
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
              onTap: () async {
                await AuthService().signOut();
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
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : AppTheme.textLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
