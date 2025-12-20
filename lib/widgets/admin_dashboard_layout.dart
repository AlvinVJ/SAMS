import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'admin_sidebar.dart';
import 'app_header.dart';

class AdminDashboardLayout extends StatelessWidget {
  final Widget child;
  final String? activeRoute;

  const AdminDashboardLayout({
    super.key,
    required this.child,
    this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          // Admin Sidebar
          AdminSidebar(activeRoute: activeRoute),

          // Main Content
          Expanded(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
