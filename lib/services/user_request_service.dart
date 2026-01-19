import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'auth_service.dart';

class UserRequest {
  final String id;
  final String title;
  final String date;
  final String level;
  final String status;
  final Color statusColor;

  UserRequest({
    required this.id,
    required this.title,
    required this.date,
    required this.level,
    required this.status,
    required this.statusColor,
  });

  factory UserRequest.fromList(List<dynamic> list) {
    // Assuming format: [id, title, date, level, status, colorType]
    // colorType could be 'success', 'warning', 'error', etc.
    final colorType = list[5] as String? ?? 'warning';
    Color color;
    switch (colorType) {
      case 'success':
        color = AppTheme.success;
        break;
      case 'error':
        color = AppTheme.error;
        break;
      case 'warning':
      default:
        color = AppTheme.warning;
        break;
    }

    return UserRequest(
      id: list[0] as String,
      title: list[1] as String,
      date: list[2] as String,
      level: list[3] as String,
      status: list[4] as String,
      statusColor: color,
    );
  }
}

class UserRequestService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<UserRequest>> fetchUserRequests() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/fetch_user_requests'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => UserRequest.fromList(item)).toList();
      } else {
        throw Exception('Failed to load user requests');
      }
    } catch (e) {
      print('Error fetching user requests: $e');
      // For now, return empty or throw
      rethrow;
    }
  }

  Future<List<PendingApproval>> fetchPendingApprovals(String role) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();
      // Using query parameter for role, assuming backend supports it
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/fetch_pending_approvals?role=$role'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PendingApproval.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load pending approvals');
      }
    } catch (e) {
      print('Error fetching pending approvals: $e');
      rethrow;
    }
  }
}

class PendingApproval {
  final String id;
  final String type;
  final String studentName;
  final String studentId;
  final String department;
  final String date;
  final String description;
  final List<String> attachments;
  final String roleTag;
  final Color color;

  PendingApproval({
    required this.id,
    required this.type,
    required this.studentName,
    required this.studentId,
    required this.department,
    required this.date,
    required this.description,
    required this.attachments,
    required this.roleTag,
    required this.color,
  });

  factory PendingApproval.fromJson(Map<String, dynamic> json) {
    // Helper to parse color from string or return default
    Color parseColor(String? colorStr) {
      if (colorStr == null) return Colors.blue;
      switch (colorStr.toLowerCase()) {
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        case 'red':
          return Colors.red;
        case 'purple':
          return Colors.purple;
        default:
          return Colors.blue;
      }
    }

    return PendingApproval(
      id: json['id'] ?? '',
      type: json['type'] ?? 'Request',
      studentName: json['studentName'] ?? 'Unknown',
      studentId: json['studentId'] ?? '',
      department: json['department'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      roleTag: json['roleTag'] ?? '',
      color: parseColor(json['color']),
    );
  }
}
