import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../state/auth_resolution.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<AuthResolution> allowedRoles;

  const RoleGuard({super.key, required this.child, required this.allowedRoles});

  @override
  Widget build(BuildContext context) {
    final userProfile = AuthService().userProfile;

    // 1. Safety Check: If config is missing, kick them out
    if (userProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Convert String Role to Enum
    AuthResolution currentRole;
    switch (userProfile.role) {
      case 'admin':
        currentRole = AuthResolution.admin;
        break;
      case 'faculty':
        currentRole = AuthResolution.faculty;
        break;
      case 'student':
        currentRole = AuthResolution.student;
        break;
      default:
        currentRole = AuthResolution.unauthenticated;
    }

    // 3. Permission Check
    if (allowedRoles.contains(currentRole)) {
      return child; // SUCCESS: Access Granted
    } else {
      // FAILURE: Redirect to Home (AuthGate will handle the rest)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Access Denied: You do not have permission."),
            backgroundColor: Colors.red,
          ),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
