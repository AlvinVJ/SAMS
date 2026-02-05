import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// RequestApprovalService
///
/// Service to handle approval actions (approve, reject, forward) on requests.
/// This service communicates with the backend API to process approval workflows.
///
/// For MVP testing without backend: Use MockRequestApprovalService instead
class RequestApprovalService {
  final String baseUrl = 'http://localhost:3000';

  /// Approve a request at the current approval level
  ///
  /// [requestId] - Unique identifier of the request
  /// [role] - The role performing the approval (e.g., "Club Coordinator", "HOD")
  /// [comments] - Optional comments from the approver
  ///
  /// Returns true if approval was successful
  Future<bool> approveRequest({
    required String requestId,
    required String role,
    String? comments,
  }) async {
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/faculty/approve_request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'requestId': requestId,
          'role': role,
          'comments': comments,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✓ Request approved: ${data['message']}');
        return true;
      } else {
        print('✗ Failed to approve request: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('✗ Error approving request: $e');
      rethrow;
    }
  }

  /// Reject a request with a mandatory reason
  ///
  /// [requestId] - Unique identifier of the request
  /// [role] - The role performing the rejection
  /// [reason] - Mandatory rejection reason (cannot be empty)
  ///
  /// Returns true if rejection was successful
  Future<bool> rejectRequest({
    required String requestId,
    required String role,
    required String reason,
  }) async {
    try {
      if (reason.trim().isEmpty) {
        throw Exception('Rejection reason is required');
      }

      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/faculty/reject_request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'requestId': requestId,
          'role': role,
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✓ Request rejected: ${data['message']}');
        return true;
      } else {
        print('✗ Failed to reject request: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('✗ Error rejecting request: $e');
      rethrow;
    }
  }

  /// Forward a request to another approver/role (DEPRECATED: System handles routing)
  Future<bool> forwardRequest({
    required String requestId,
    required String toRole,
    String? comments,
  }) async {
    return true; // No-op placeholder for backward compatibility if needed
  }
}
