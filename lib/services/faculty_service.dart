import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/faculty_profile.dart';
import '../models/notification.dart';

class FacultyService {
  final String _baseUrl = "http://localhost:3000";

  Future<FacultyProfile> getFacultyProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not authenticated");
    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/api/faculty/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return FacultyProfile.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? "Failed to fetch profile");
    } else {
      throw Exception("Failed to load profile: ${response.statusCode}");
    }
  }

  Future<List<SAMSNotification>> getFacultyNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not authenticated");
    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/api/faculty/notifications"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> notificationsData = data['data'];
        return notificationsData
            .map((json) => SAMSNotification.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch notifications');
      }
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchDashboardData({String? role}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not authenticated");
    final token = await user.getIdToken();

    final uri = Uri.parse("$_baseUrl/api/faculty/dashboard").replace(
      queryParameters: role != null && role != "all" ? {"role": role} : {},
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
      throw Exception(data['message'] ?? "Failed to fetch dashboard data");
    } else {
      throw Exception("Failed to fetch dashboard data: ${response.statusCode}");
    }
  }
}
