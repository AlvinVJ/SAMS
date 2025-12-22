
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';

class FacultySidebar extends StatelessWidget {
  final String activeRoute;

  const FacultySidebar({
    super.key,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          // ================= LOGO =================
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
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Faculty Portal',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= MENU =================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _item(
                  context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/faculty/dashboard',
                ),
                _item(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Create Request',
                  route: '/faculty/create-request',
                ),
                _item(
                  context,
                  icon: Icons.fact_check,
                  label: 'Requests for Approval',
                  route: '/faculty/requests',
                ),
                _item(
                  context,
                  icon: Icons.folder_open,
                  label: 'My Requests',
                  route: '/faculty/history',
                ),


                 _item(
                  context,
                  icon: Icons.hourglass_empty,
                  label: 'Request status',
                  route: '/faculty/request-status',
                ),
                _item(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  route: '/faculty/profile',
                ),

               

              ],
            ),
          ),

          // ================= LOGOUT =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                // TODO: handle logout
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU ITEM =================
  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final bool active = activeRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: active ? Colors.white : AppTheme.textLight,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          if (!active) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
