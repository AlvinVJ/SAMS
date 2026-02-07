import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Service for admin procedure management operations
class AdminProcedureService {
  final String baseUrl = 'http://localhost:3000';

  /// Fetch all active procedures
  Future<List<ProcedureSummary>> fetchProcedures() async {
    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (authToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/procedures'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final procedures = data['data']['procedures'] as List;
        return procedures.map((p) => ProcedureSummary.fromJson(p)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch procedures');
      }
    } catch (e) {
      throw Exception('Error fetching procedures: $e');
    }
  }

  /// Fetch single procedure by ID for editing
  Future<ProcedureDetail> fetchProcedureById(String procedureId) async {
    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (authToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/admin/procedure/$procedureId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: fetchProcedureById response: $data'); // Debug log
        return ProcedureDetail.fromJson(data['data']['procedure']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch procedure');
      }
    } catch (e) {
      throw Exception('Error fetching procedure: $e');
    }
  }

  /// Update existing procedure
  Future<void> updateProcedure(
    String procedureId,
    Map<String, dynamic> procedureData,
  ) async {
    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (authToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/admin/procedure/$procedureId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'procedure': procedureData}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update procedure');
      }
    } catch (e) {
      throw Exception('Error updating procedure: $e');
    }
  }

  /// Delete procedure (soft delete)
  Future<void> deleteProcedure(String procedureId) async {
    try {
      final authToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (authToken == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/admin/procedure/$procedureId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete procedure');
      }
    } catch (e) {
      throw Exception('Error deleting procedure: $e');
    }
  }
}

/// Model for procedure summary (list view)
class ProcedureSummary {
  final String procId;
  final String title;
  final String description;
  final int approvalLevelsCount;
  final String createdBy;
  final bool isActive;

  ProcedureSummary({
    required this.procId,
    required this.title,
    required this.description,
    required this.approvalLevelsCount,
    required this.createdBy,
    required this.isActive,
  });

  factory ProcedureSummary.fromJson(Map<String, dynamic> json) {
    return ProcedureSummary(
      procId: json['proc_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      approvalLevelsCount: json['approval_levels_count'] ?? 0,
      createdBy: json['created_by'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

/// Model for procedure detail (edit view)
class ProcedureDetail {
  final String procId;
  final String title;
  final String description;
  final List<dynamic> formFields;
  final List<dynamic> approvalLevels;
  final List<String> visibility;

  ProcedureDetail({
    required this.procId,
    required this.title,
    required this.description,
    required this.formFields,
    required this.approvalLevels,
    required this.visibility,
  });

  factory ProcedureDetail.fromJson(Map<String, dynamic> json) {
    return ProcedureDetail(
      procId: json['proc_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      formFields: json['formFields'] ?? json['formBuilder'] ?? [],
      approvalLevels: json['approvalLevels'] ?? [],
      visibility: List<String>.from(json['visibility'] ?? []),
    );
  }
}
