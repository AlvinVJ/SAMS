import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class FacultyService {
  final String _baseUrl = "http://localhost:3000";

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
