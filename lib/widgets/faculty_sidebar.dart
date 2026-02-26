import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/app_theme.dart';

class FacultySidebar extends StatelessWidget {
  final String? activeRoute;
  final bool isCollapsed;

  const FacultySidebar({
    super.key,
    required this.activeRoute,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 260,
      color: Colors.white,
      child: Column(
        children: [
          // ===== LOGO AREA =====
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
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
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
                          overflow: TextOverflow.ellipsis,
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ===== MENU =====
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12),
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
            child: Tooltip(
              message: isCollapsed ? 'Logout' : '',
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: isCollapsed
                    ? null
                    : const Text(
                        'Logout',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 12 : 18,
                ),
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
      child: Tooltip(
        message: isCollapsed ? label : '',
        child: ListTile(
          horizontalTitleGap: isCollapsed ? 0 : 10,
          dense: true,
          leading: Icon(
            icon,
            size: 20,
            color: active ? Colors.white : const Color(0xFF64748B),
          ),
          title: isCollapsed
              ? null
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 18,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            if (!active) {
              Navigator.pushReplacementNamed(context, route);
            }
          },
        ),
      ),
    );
  }
}
