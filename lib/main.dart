import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sams_final/auth_gate.dart';

import 'config/supabase.dart';
//import 'services/auth_service.dart';

import 'screens/dashboard_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/create_request_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'admin_screens/admin_dashboard_screen.dart';
import 'admin_screens/admin_requests_screen.dart';
import 'admin_screens/admin_settings_screen.dart';
import 'admin_screens/admin_users_screen.dart';
import 'admin_screens/admin_procedures_screen.dart';
//import 'admin_screens/admin_workflow_canvas_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await dotenv.load(fileName: ".env");
  await SupabaseConfig.init();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAMS',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
      //initialRoute: '/',
      routes: {
        //'/': (context) => const DashboardScreen(),
        '/requests': (context) => const RequestsScreen(),
        '/create-request': (context) => const CreateRequestScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/settings': (context) => const SettingsScreen(),

        //Admin page routes
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
        '/admin/requests': (context) => const AdminRequestsScreen(),
        '/admin/settings': (context) => const AdminSettingsScreen(),
        '/admin/users': (context) => const AdminUsersScreen(),
        '/admin/procedures': (context) => const AdminProceduresScreen(),
        // '/admin/procedures/create': (context) => const AdminCreateProcedureScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
