import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sams_final/faculty_screens/faculty_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/fcm_service.dart';
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
            if (AuthService().userProfile != null) {
              print("TEST SUCCESS: Profile Loaded!");
              print("User Role: ${AuthService().userProfile!.role}");
              print("User Email: ${AuthService().userProfile!.email}");
              print("Auth UID: ${AuthService().userProfile!.authUid}");
              
              // Fetch FCM token and update it in the backend
              FCMService().getFCMToken().then((token) async {
                if (token != null) {
                  print("Sending FCM token to backend: $token");
                  try {
                    final currUser = FirebaseAuth.instance.currentUser;
                    if (currUser != null) {
                      // 1. Get or Generate Persistent Device ID
                      String? deviceId;
                      if (kIsWeb) {
                        final prefs = await SharedPreferences.getInstance();
                        deviceId = prefs.getString('device_id');
                        if (deviceId == null) {
                          deviceId = 'web_${const Uuid().v4()}';
                          await prefs.setString('device_id', deviceId);
                          print("Generated new device_id: $deviceId");
                        } else {
                          print("Reusing existing device_id: $deviceId");
                        }
                      }

                      final idToken = await currUser.getIdToken();
                      await http.post(
                        Uri.parse('http://localhost:3000/api/common/save_fcm_token'),
                        headers: {
                          'Authorization': 'Bearer $idToken',
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'fcm_token': token,
                          if (deviceId != null) 'session_id': deviceId, // Use persistent ID instead of timestamp
                        }),
                      );
                      if (deviceId != null) {
                        print("FCM token saved successfully with session_id: $deviceId");
                      }
                    }
                  } catch (e) {
                    print("Error saving FCM token: $e");
                  }
                }
              });
            } else {
              print("TEST FAILED: Profile is NULL");
            }

            if (resolution == AuthResolution.unauthorized) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAccessDeniedDialog(context, authService);
              });
              return const Scaffold();
            } else if (resolution == AuthResolution.notAdded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showNotAddedDialog(context, authService);
              });
              return const Scaffold();
            } else if (resolution == AuthResolution.banned) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showBannedAccountDialog(context, authService);
              });
              return const Scaffold();
            } else if (resolution == AuthResolution.inactive) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showInactiveAccountDialog(context, authService);
              });
              return const Scaffold();
            }
            // print(resolution);
            // print(UserInfo);
            // print(User);
            switch (resolution) {
              case AuthResolution.admin:
                return const AdminDashboardScreen();

              case AuthResolution.student:
                return const DashboardScreen();

              case AuthResolution.unauthenticated:
                return const LoginScreen();
              case AuthResolution.faculty:
                return  FacultyDashboardScreen();

              //add routing to faculty dashboard

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

  void _showNotAddedDialog(BuildContext context, AuthService authService) {
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
            'Your email has not been added as a valid user to this platform.\n\n'
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

  void _showInactiveAccountDialog(
    BuildContext context,
    AuthService authService,
  ) {
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
            'Your account is no longer active on this platform.\n\n'
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

  void _showBannedAccountDialog(BuildContext context, AuthService authService) {
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
            'Your account has been temporarily banned from this platform.\n\n'
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
