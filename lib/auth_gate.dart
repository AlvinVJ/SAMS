import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'state/auth_resolution.dart';

import 'screens/login_screen.dart';
//import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'admin_screens/admin_dashboard_screen.dart';
//import 'screens/faculty_dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, _) {
        return FutureBuilder<AuthResolution>(
          future: authService.resolveUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }            

            final resolution = snapshot.data!;

            // 🚨 Access Denied → show dialog, then logout
            if (resolution == AuthResolution.accessDenied) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAccessDeniedDialog(context, authService);
              });

              // While dialog is shown, render empty scaffold
              //return const Scaffold();
            }

            switch (resolution) {
              case AuthResolution.unauthenticated:
                return const LoginScreen();

              case AuthResolution.needsOnboarding:
              //return const OnboardingScreen();

              case AuthResolution.admin:
                //print(resolution);
                return const AdminDashboardScreen();

              case AuthResolution.faculty:
              //return const FacultyDashboardScreen();

              case AuthResolution.student:
                print(resolution);
                return const DashboardScreen();

              default:
                return const LoginScreen();
            }
          },
        );
      },
    );
  }

  void _showAccessDeniedDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              SizedBox(width: 8),
              Text('Access Denied'),
            ],
          ),
          content: const Text(
            'Your email is not authorized to access this platform.\n\n'
            'If you believe this is a mistake, contact the administrator.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authService.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}
