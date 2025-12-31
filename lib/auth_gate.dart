import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'state/auth_resolution.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'admin_screens/admin_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 🔹 Waiting for auth state to settle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 🔹 Logged in → resolve role
        return FutureBuilder<AuthResolution>(
          future: authService.resolveUser(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final resolution = roleSnapshot.data!;

            if (resolution == AuthResolution.accessDenied) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAccessDeniedDialog(context, authService);
              });
              return const Scaffold();
            }
            print(resolution);
            switch (resolution) {
              case AuthResolution.admin:
                return const AdminDashboardScreen();

              case AuthResolution.student:
                return const DashboardScreen();

              case AuthResolution.unauthenticated:
                return const LoginScreen();

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
