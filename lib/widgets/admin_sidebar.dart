import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  final String? activeRoute;

  const AdminSidebar({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo / Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
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
                      'Admin Panel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: activeRoute == '/admin/dashboard',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/dashboard',
                  ),
                ),
                _NavItem(
                  icon: Icons.description,
                  label: 'Procedures',
                  isActive: activeRoute == '/admin/procedures',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/procedures',
                  ),
                ),
                _NavItem(
                  icon: Icons.inbox,
                  label: 'Requests',
                  isActive: activeRoute == '/admin/requests',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/admin/requests',
                  ),
                ),
                _NavItem(
                  icon: Icons.group,
                  label: 'Users',
                  isActive: activeRoute == '/admin/users',
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/admin/users'),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isActive: activeRoute == '/admin/settings',
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
