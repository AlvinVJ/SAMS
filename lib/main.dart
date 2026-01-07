import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sams_final/auth_gate.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:sams_final/services/auth_service.dart';
import 'firebase_options.dart';
//import 'services/auth_service.dart';

//
// Student screens
import 'faculty_screens/faculty_acted_requests_screen.dart';
import 'faculty_screens/faculty_profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/create_request_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';

// Admin screens
import 'admin_screens/admin_dashboard_screen.dart';
import 'admin_screens/admin_requests_screen.dart';
import 'admin_screens/admin_settings_screen.dart';
import 'admin_screens/admin_users_screen.dart';
import 'admin_screens/admin_procedures_screen.dart';

// Faculty screens
import 'faculty_screens/faculty_dashboard_screen.dart';
import 'faculty_screens/faculty_create_request_screen.dart';
import 'faculty_screens/faculty_requests_screen.dart';
import 'faculty_screens/faculty_request_history_screen.dart';
//import 'admin_screens/admin_workflow_canvas_screen.dart';

import 'widgets/role_guard.dart';
import 'state/auth_resolution.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    print(await FirebaseAuth.instance.getRedirectResult());
  } catch (e) {
    print("Redirect Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMS',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        //'/': (context) => const DashboardScreen(),
        '/requests': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.student], // Only Students
          child: RequestsScreen(),
        ),
        '/create-request': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.student],
          child: CreateRequestScreen(),
        ),
        '/notifications': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.student], // Both allowed
          child: NotificationsScreen(),
        ),
        '/settings': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.student], // Both allowed
          child: SettingsScreen(),
        ),
        //Admin page routes
        '/admin/dashboard': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.admin], // Only Admins
          child: AdminDashboardScreen(),
        ),
        '/admin/requests': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.admin],
          child: AdminRequestsScreen(),
        ),
        '/admin/settings': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.admin],
          child: AdminSettingsScreen(),
        ),
        '/admin/users': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.admin],
          child: AdminUsersScreen(),
        ),
        '/admin/procedures': (context) => const RoleGuard(
          allowedRoles: [AuthResolution.admin],
          child: AdminProceduresScreen(),
        ),
        // ================= FACULTY =================
        '/faculty/dashboard': (context) => 
          FacultyDashboardScreen(),

        '/faculty/create-request': (context) =>
            const FacultyCreateRequestScreen(),

        '/faculty/requests': (context) =>
             const FacultyRequestsForApprovalScreen(),
        '/faculty/history': (context) =>
            const FacultyRequestHistoryScreen(),

        
        '/faculty/request-status': (context) =>
            const FacultyActedRequestsScreen(),

        '/faculty/profile': (context) =>  FacultyProfileScreen(),
        // '/admin/procedures/create': (context) => const AdminCreateProcedureScreen(),
      },
    );
  }
}
