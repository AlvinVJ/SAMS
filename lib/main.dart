import 'package:flutter/material.dart';

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

void main() {
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
        // ================= STUDENT =================
        '/': (context) => const DashboardScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/create-request': (context) => const CreateRequestScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),

        // ================= ADMIN =================
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/requests': (context) => const AdminRequestsScreen(),
        '/admin/settings': (context) => const AdminSettingsScreen(),
        '/admin/users': (context) => const AdminUsersScreen(),
        '/admin/procedures': (context) => const AdminProceduresScreen(),

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

      },
    );
  }
}

// import 'package:flutter/material.dart';

// // Student screens
// import 'screens/dashboard_screen.dart';
// import 'screens/requests_screen.dart';
// import 'screens/create_request_screen.dart';
// import 'screens/notifications_screen.dart';
// import 'screens/settings_screen.dart';

// // Admin screens
// import 'admin_screens/admin_dashboard_screen.dart';
// import 'admin_screens/admin_requests_screen.dart';
// import 'admin_screens/admin_settings_screen.dart';
// import 'admin_screens/admin_users_screen.dart';
// import 'admin_screens/admin_procedures_screen.dart';

// // Faculty screens
// import 'faculty_screens/faculty_dashboard_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SAMS',
//       theme: ThemeData(useMaterial3: true),
//       debugShowCheckedModeBanner: false,

//       initialRoute: '/',

//       routes: {
//         // ================= STUDENT =================
//         '/': (context) => const DashboardScreen(),
//         '/requests': (context) => const RequestsScreen(),
//         '/create-request': (context) => const CreateRequestScreen(),
//         '/notifications': (context) => const NotificationsScreen(),
//         '/settings': (context) => const SettingsScreen(),

//         // ================= ADMIN =================
//         '/admin/dashboard': (context) => const AdminDashboardScreen(),
//         '/admin/requests': (context) => const AdminRequestsScreen(),
//         '/admin/settings': (context) => const AdminSettingsScreen(),
//         '/admin/users': (context) => const AdminUsersScreen(),
//         '/admin/procedures': (context) => const AdminProceduresScreen(),

//         // ================= FACULTY =================
//         '/faculty/dashboard': (context) => const FacultyDashboardScreen(
//               facultyName: 'Dr. Johnson',
//               dateText: 'October 24, 2023',
//               pending: 3,
//               approved: 12,
//               rejected: 1,
//               total: 16,
//             ),
//       },
//     );
//   }
// }
