/// MockRequestApprovalService
///
/// MOCK SERVICE FOR FRONTEND TESTING WITHOUT BACKEND
///
/// This service simulates backend responses for approval actions.
/// Use this when the backend is not available to test frontend functionality.
///
/// TO USE THIS MOCK SERVICE:
/// 1. In faculty_requests_screen.dart, import this file instead of request_approval_service.dart
/// 2. Replace RequestApprovalService() with MockRequestApprovalService()
/// 3. Test the UI flow - all actions will succeed after a short delay
///
/// TO SWITCH BACK TO REAL SERVICE:
/// 1. Import request_approval_service.dart
/// 2. Use RequestApprovalService() instead
class MockRequestApprovalService {
  /// Simulate network delay (in milliseconds)
  final int _networkDelay = 800;

  /// Mock approve request - always succeeds after delay
  Future<bool> approveRequest({
    required String requestId,
    required String role,
    String? comments,
  }) async {
    print('🔶 MOCK: Approving request $requestId as $role');
    print('   Comments: ${comments ?? "None"}');

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _networkDelay));

    print('✓ MOCK: Request approved successfully');
    return true;
  }

  /// Mock reject request - always succeeds after delay
  Future<bool> rejectRequest({
    required String requestId,
    required String role,
    required String reason,
  }) async {
    print('🔶 MOCK: Rejecting request $requestId as $role');
    print('   Reason: $reason');

    if (reason.trim().isEmpty) {
      throw Exception('Rejection reason is required');
    }

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _networkDelay));

    print('✓ MOCK: Request rejected successfully');
    return true;
  }

  /// Mock forward request - always succeeds after delay
  Future<bool> forwardRequest({
    required String requestId,
    required String toRole,
    String? comments,
  }) async {
    print('🔶 MOCK: Forwarding request $requestId to $toRole');
    print('   Comments: ${comments ?? "None"}');

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _networkDelay));

    print('✓ MOCK: Request forwarded successfully');
    return true;
  }
}
