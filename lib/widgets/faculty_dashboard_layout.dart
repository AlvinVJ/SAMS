import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'faculty_sidebar.dart';
import 'app_header.dart';

class FacultyDashboardLayout extends StatelessWidget {
  final String activeRoute;
  final Widget child;

  const FacultyDashboardLayout({
    super.key,
    required this.activeRoute,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          FacultySidebar(activeRoute: activeRoute),
          Expanded(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: child,
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
