import '../services/user_request_service.dart';
import 'package:flutter/material.dart';

/// MockUserRequestService
///
/// MOCK SERVICE FOR FRONTEND TESTING WITHOUT BACKEND
///
/// This service simulates backend responses for fetching requests.
/// Use this when the backend is not available to test the faculty approval screen.
///
/// TO USE THIS MOCK SERVICE:
/// 1. In faculty_requests_screen.dart, import this file
/// 2. Replace UserRequestService() with MockUserRequestService()
/// 3. Test the UI - mock data will be displayed
class MockUserRequestService {
  /// Simulate network delay (in milliseconds)
  final int _networkDelay = 500;

  /// Mock fetch pending approvals - returns sample data
  Future<List<PendingApproval>> fetchPendingApprovals(String role) async {
    print('🔶 MOCK: Fetching pending approvals for role: $role');

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _networkDelay));

    // Return mock data based on role
    final mockData = _getMockDataForRole(role);

    print('✓ MOCK: Returning ${mockData.length} pending approvals');
    return mockData;
  }

  /// Generate mock pending approval data
  List<PendingApproval> _getMockDataForRole(String role) {
    // Different mock data for different roles
    if (role.toLowerCase().contains('coordinator')) {
      return [
        PendingApproval(
          id: 'MOCK-REQ-001',
          type: 'Club Event Approval',
          studentName: 'John Doe',
          studentId: 'student123',
          department: 'Computer Science',
          date: DateTime.now()
              .subtract(const Duration(days: 2))
              .toString()
              .split(' ')[0],
          description:
              'Request for organizing Tech Fest 2026 with workshops and competitions',
          attachments: ['event_proposal.pdf', 'budget_estimate.xlsx'],
          roleTag: role,
          color: Colors.blue,
        ),
        PendingApproval(
          id: 'MOCK-REQ-002',
          type: 'Club Event Approval',
          studentName: 'Jane Smith',
          studentId: 'student456',
          department: 'Electronics',
          date: DateTime.now()
              .subtract(const Duration(days: 1))
              .toString()
              .split(' ')[0],
          description:
              'Annual robotics competition with inter-college participation',
          attachments: ['competition_rules.pdf'],
          roleTag: role,
          color: Colors.green,
        ),
      ];
    } else if (role.toLowerCase().contains('hod')) {
      return [
        PendingApproval(
          id: 'MOCK-REQ-003',
          type: 'Student Event Participation',
          studentName: 'Alice Johnson',
          studentId: 'student789',
          department: 'Mechanical',
          date: DateTime.now().toString().split(' ')[0],
          description: 'Participation in National Level Hackathon at IIT Delhi',
          attachments: ['invitation_letter.pdf'],
          roleTag: role,
          color: Colors.purple,
        ),
      ];
    } else if (role.toLowerCase().contains('principal')) {
      return [
        PendingApproval(
          id: 'MOCK-REQ-004',
          type: 'Club Event Approval',
          studentName: 'Bob Wilson',
          studentId: 'student321',
          department: 'Civil',
          date: DateTime.now()
              .subtract(const Duration(hours: 5))
              .toString()
              .split(' ')[0],
          description:
              'Industrial visit to construction site - final approval required',
          attachments: ['visit_plan.pdf', 'safety_checklist.pdf'],
          roleTag: role,
          color: Colors.orange,
        ),
        PendingApproval(
          id: 'MOCK-REQ-005',
          type: 'Placement Attendance',
          studentName: 'Multiple Students',
          studentId: 'bulk_approval',
          department: 'All Departments',
          date: DateTime.now().toString().split(' ')[0],
          description:
              'Bulk approval for 45 students attending TCS campus drive',
          attachments: ['student_list.csv', 'company_details.pdf'],
          roleTag: role,
          color: Colors.teal,
        ),
      ];
    } else {
      // Default mock data for any other role
      return [
        PendingApproval(
          id: 'MOCK-REQ-006',
          type: 'General Request',
          studentName: 'Test Student',
          studentId: 'test123',
          department: 'Test Department',
          date: DateTime.now().toString().split(' ')[0],
          description: 'Sample request for testing purposes',
          attachments: [],
          roleTag: role,
          color: Colors.grey,
        ),
      ];
    }
  }

  /// Mock fetch user requests - returns sample data
  Future<List<List<String>>> fetchUserRequests() async {
    print('🔶 MOCK: Fetching user requests');

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: _networkDelay));

    // Return mock data in the array format expected
    final mockRequests = [
      [
        'MOCK-REQ-101',
        'My Club Event Request',
        DateTime.now()
            .subtract(const Duration(days: 3))
            .toString()
            .split(' ')[0],
        'Level 2',
        'pending',
        'warning',
      ],
      [
        'MOCK-REQ-102',
        'Event Participation Request',
        DateTime.now()
            .subtract(const Duration(days: 1))
            .toString()
            .split(' ')[0],
        'Level 1',
        'pending',
        'warning',
      ],
      [
        'MOCK-REQ-103',
        'Previous Event Request',
        DateTime.now()
            .subtract(const Duration(days: 10))
            .toString()
            .split(' ')[0],
        'Level 3',
        'approved',
        'success',
      ],
    ];

    print('✓ MOCK: Returning ${mockRequests.length} user requests');
    return mockRequests;
  }
}
