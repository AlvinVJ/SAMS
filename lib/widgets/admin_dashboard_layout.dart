import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'admin_sidebar.dart';
import 'app_header.dart';

class AdminDashboardLayout extends StatefulWidget {
  final Widget child;
  final String? activeRoute;

  final bool disableSidebar;

  const AdminDashboardLayout({
    super.key,
    required this.child,
    this.activeRoute,
    this.disableSidebar = false,
  });

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  bool _isCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          // Admin Sidebar
          IgnorePointer(
            ignoring: widget.disableSidebar,
            child: AdminSidebar(
              activeRoute: widget.activeRoute,
              isCollapsed: _isCollapsed,
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                AppHeader(onMenuPressed: _toggleSidebar),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: widget.child,
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
