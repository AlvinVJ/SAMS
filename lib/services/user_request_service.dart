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

  // To match the UI requirements in FacultyApprovalScreen
  factory UserRequest.fromMap(Map<String, dynamic> map) {
    return UserRequest(
      id: map['requestId'] ?? map['id'] ?? '',
      title: map['procedureTitle'] ?? map['title'] ?? 'Unknown Request',
      date: map['date'] ?? '',
      level: map['currentLevel'] ?? map['level'] ?? '',
      status: map['status'] ?? 'pending',
      statusColor: _getColorForStatus(map['status'] ?? 'pending'),
    );
  }

  static Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'success':
        return AppTheme.success;
      case 'rejected':
      case 'error':
        return AppTheme.error;
      case 'pending':
      case 'warning':
      default:
        return AppTheme.warning;
    }
  }
}

// Model specifically for Faculty Approval View which needs more student info
class PendingApproval {
  final String id;
  final String type;
  final String name;
  final String studentId;
  final String department;
  final String date;
  final String description;
  final List<String> attachments;
  final Color color;

  PendingApproval({
    required this.id,
    required this.type,
    required this.name,
    required this.studentId,
    required this.department,
    required this.date,
    required this.description,
    required this.attachments,
    this.color = Colors.blue,
  });

  factory PendingApproval.fromJson(Map<String, dynamic> json) {
    return PendingApproval(
      id: json['id'] ?? '',
      type: json['type'] ?? 'General Request',
      name: json['studentName'] ?? 'Unknown Student',
      studentId: json['studentId'] ?? '',
      department: json['department'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      color: _getColorForType(json['type'] ?? ''),
    );
  }

  static Color _getColorForType(String type) {
    if (type.contains('Leave')) return Colors.blue;
    if (type.contains('Funding')) return Colors.green;
    if (type.contains('Event')) return Colors.orange;
    return Colors.purple;
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
      rethrow;
    }
  }

  Future<List<PendingApproval>> fetchPendingApprovals(String role) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/faculty/request_for_approval'),
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $idToken'
        }
      );1

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> requests = jsonResponse['data'] ?? [];
        return requests.map((item) => PendingApproval.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load pending approvals');
      }
    } catch (e) {
      print('Error fetching pending approvals: $e');
      rethrow;
    }
  }

  Future<bool> updateRequestStatus({
    required String requestId,
    required String action, // 'approve', 'reject', 'forward'
    String? comment,
    String? forwardTo,
  }) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/faculty/action_request'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'requestId': requestId,
          'action': action,
          'comment': comment,
          'forwardTo': forwardTo,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }
}
