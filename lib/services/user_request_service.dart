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
  final int currentLevel;
  final int totalLevels;
  final List<ApprovalAction> approvalHistory;
  final Map<String, dynamic> formData;
  final String studentName;
  final String studentId;
  final String department;
  final String roleTag;

  UserRequest({
    required this.id,
    required this.title,
    required this.date,
    required this.level,
    required this.status,
    required this.statusColor,
    required this.currentLevel,
    required this.totalLevels,
    required this.approvalHistory,
    this.formData = const {},
    this.studentName = '',
    this.studentId = '',
    this.department = '',
    this.roleTag = 'Approver',
  });

  PendingApproval toPendingApproval() {
    return PendingApproval(
      id: id,
      type: title,
      studentName: studentName,
      studentId: studentId,
      department: department,
      date: date,
      description: '', // PDF uses formData if available
      attachments: [],
      roleTag: roleTag,
      color: statusColor, // Map status color
      approvalHistory: approvalHistory,
      formData: formData,
    );
  }

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    Color parseStatusColor(String? colorType) {
      switch (colorType?.toLowerCase()) {
        case 'success':
        case 'approved':
          return AppTheme.success;
        case 'error':
        case 'rejected':
          return AppTheme.error;
        case 'warning':
        case 'pending':
        default:
          return AppTheme.warning;
      }
    }

    final historyJson = json['approvalHistory'] as List? ?? [];
    debugPrint(
      '[MODEL-DEBUG] Parsing request ${json['req_id']} | History items in JSON: ${historyJson.length}',
    );

    return UserRequest(
      id: json['req_id'] ?? '',
      title: json['procedure_title'] ?? 'Unknown Request',
      date: json['created_at']?.toString().split('T')[0] ?? '',
      level: 'Level ${json['current_level'] ?? 1}',
      status: json['status_text'] ?? 'Pending',
      statusColor: parseStatusColor(json['color']),
      currentLevel: json['current_level'] ?? 1,
      totalLevels: json['total_levels'] ?? 1,
      approvalHistory: historyJson
          .map((h) => ApprovalAction.fromJson(Map<String, dynamic>.from(h)))
          .toList(),
      formData: Map<String, dynamic>.from(json['formData'] ?? {}),
      studentName: json['studentName'] ?? '',
      studentId: json['studentId'] ?? '',
      department: json['department'] ?? '',
      roleTag: json['roleTag'] ?? 'Approver',
    );
  }

  factory UserRequest.fromList(List<dynamic> list) {
    // Assuming format: [id, title, date, level, status, colorType]
    final colorType = list.length > 5
        ? list[5] as String? ?? 'warning'
        : 'warning';
    Color color = colorType == 'success'
        ? AppTheme.success
        : (colorType == 'error' ? AppTheme.error : AppTheme.warning);

    return UserRequest(
      id: list[0] as String,
      title: list[1] as String,
      date: list[2] as String,
      level: list[3] as String,
      status: list[4] as String,
      statusColor: color,
      currentLevel: 1,
      totalLevels: 1,
      approvalHistory: [],
    );
  }
}

class UserRequestService {
  final String baseUrl = 'http://localhost:3000';

  Future<DashboardData> fetchDashboardData() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/requests/dashboard_data'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardData.fromJson(data['data']);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      rethrow;
    }
  }

  Future<List<UserRequest>> fetchUserRequests() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/requests/my_requests'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data is Map ? data['data'] : data;
        return list.map((item) => UserRequest.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load user requests');
      }
    } catch (e) {
      print('Error fetching user requests: $e');
      rethrow;
    }
  }

  Future<List<UserRequest>> fetchActedRequests() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/faculty/acted_requests'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['data'];
        return list.map((item) => UserRequest.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load acted requests');
      }
    } catch (e) {
      print('Error fetching acted requests: $e');
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
        Uri.parse('$baseUrl/api/faculty/request_for_approval?role=$role'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns { success: true, message: "...", data: { requests: [...] } }
        final List<dynamic> requestsData = data['data']['requests'];
        return requestsData
            .map((item) => PendingApproval.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load pending approvals');
      }
    } catch (e) {
      print('Error fetching pending approvals: $e');
      rethrow;
    }
  }

  Future<List<String>> fetchRoleTags() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/common/get_role_tags'),
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tags = data['data']['role_tags'];
        return tags.map((t) => t.toString()).toList();
      } else {
        throw Exception('Failed to load role tags');
      }
    } catch (e) {
      print('Error fetching role tags: $e');
      rethrow;
    }
  }
}

class ApprovalAction {
  final int level;
  final String approverName;
  final String role;
  final String status;
  final String? comments;
  final String timestamp;

  ApprovalAction({
    required this.level,
    required this.approverName,
    required this.role,
    required this.status,
    this.comments,
    required this.timestamp,
  });

  factory ApprovalAction.fromJson(Map<String, dynamic> json) {
    return ApprovalAction(
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '0') ?? 0,
      approverName: json['approverName']?.toString() ?? 'Unknown',
      role: json['role']?.toString().replaceAll('_', ' ').toUpperCase() ?? '',
      status: json['status']?.toString() ?? 'APPROVED',
      comments: json['comments']
          ?.toString(), // Explicitly stringify if not null
      timestamp: json['timestamp']?.toString() ?? '',
    );
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
  final Map<String, dynamic> formData;
  final List<ApprovalAction> approvalHistory;

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
    required this.formData,
    required this.approvalHistory,
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
      formData: Map<String, dynamic>.from(json['formData'] ?? {}),
      approvalHistory: (json['approvalHistory'] as List? ?? [])
          .map((h) => ApprovalAction.fromJson(Map<String, dynamic>.from(h)))
          .toList(),
    );
  }
}

class ActiveRequest {
  final String id;
  final String title;
  final String date;
  final String status;
  final int currentLevel;

  ActiveRequest({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.currentLevel,
  });

  factory ActiveRequest.fromJson(Map<String, dynamic> json) {
    return ActiveRequest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      currentLevel: json['currentLevel'] ?? 1,
    );
  }
}

class DashboardData {
  final Map<String, int> stats;
  final List<ActiveRequest> activeRequests;
  final List<Map<String, dynamic>> notifications;

  DashboardData({
    required this.stats,
    required this.activeRequests,
    required this.notifications,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final stats = Map<String, int>.from(json['stats'] ?? {});
    final activeRequests = (json['activeRequests'] as List? ?? [])
        .map((req) => ActiveRequest.fromJson(req))
        .toList();
    final notifications = List<Map<String, dynamic>>.from(
      json['notifications'] ?? [],
    );

    return DashboardData(
      stats: stats,
      activeRequests: activeRequests,
      notifications: notifications,
    );
  }
}
