import 'package:flutter/material.dart';
import 'package:sams_final/services/auth_service.dart';
import 'package:sams_final/widgets/faculty_sidebar.dart';
import '../styles/app_theme.dart';
import 'app_header.dart';
import 'app_sidebar.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;
  final String? activeRoute;
  final bool disableSidebar;

  const DashboardLayout({
    super.key,
    required this.child,
    this.activeRoute,
    this.disableSidebar = false,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  bool _isCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  Widget _buildSidebar() {
    final profile = AuthService().userProfile;

    if (profile == null) {
      return const SizedBox.shrink();
    }

    if (profile.role == 'student') {
      return AppSidebar(
        activeRoute: widget.activeRoute,
        isCollapsed: _isCollapsed,
      );
    }

    if (profile.role == 'faculty') {
      return FacultySidebar(
        activeRoute: widget.activeRoute,
        isCollapsed: _isCollapsed,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          // Sidebar
          IgnorePointer(
            ignoring: widget.disableSidebar,
            child: _buildSidebar(),
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
