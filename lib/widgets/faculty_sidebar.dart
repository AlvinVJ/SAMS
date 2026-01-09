import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/app_theme.dart';

class FacultySidebar extends StatelessWidget {
  final String activeRoute;

  const FacultySidebar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          // ===== LOGO AREA =====
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SAMS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.3,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Faculty Portal',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== MENU =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _menuItem(
                  context: context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/faculty/dashboard',
                ),
                _menuItem(
                  context: context,
                  icon: Icons.add,
                  label: 'Create Request',
                  route: '/faculty/create-request',
                ),
                _menuItem(
                  context: context,
                  icon: Icons.fact_check,
                  label: 'Requests for Approval',
                  route: '/faculty/requests',
                ),
                _menuItem(
                  context: context,
                  icon: Icons.folder_open,
                  label: 'My Requests',
                  route: '/faculty/history',
                ),
                _menuItem(
                  context: context,
                  icon: Icons.pending_actions,
                  label: 'Request Status',
                  route: '/faculty/request-status',
                ),
                _menuItem(
                  context: context,
                  icon: Icons.person,
                  label: 'Profile',
                  route: '/faculty/profile',
                ),
              ],
            ),
          ),

          // ===== LOGOUT =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              onTap: () async {
                await AuthService().signOut();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== MENU ITEM WIDGET =====
  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool active = activeRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        horizontalTitleGap: 10,
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: active ? Colors.white : const Color(0xFF64748B),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : const Color(0xFF64748B),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          if (!active) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
