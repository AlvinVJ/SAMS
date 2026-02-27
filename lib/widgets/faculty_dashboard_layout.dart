import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'faculty_sidebar.dart';
import 'app_header.dart';

class FacultyDashboardLayout extends StatefulWidget {
  final String activeRoute;
  final Widget child;

  const FacultyDashboardLayout({
    super.key,
    required this.activeRoute,
    required this.child,
  });

  @override
  State<FacultyDashboardLayout> createState() => _FacultyDashboardLayoutState();
}

class _FacultyDashboardLayoutState extends State<FacultyDashboardLayout> {
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
          FacultySidebar(
            activeRoute: widget.activeRoute,
            isCollapsed: _isCollapsed,
          ),
          Expanded(
            child: Column(
              children: [
                AppHeader(onMenuPressed: _toggleSidebar),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: widget.child,
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
