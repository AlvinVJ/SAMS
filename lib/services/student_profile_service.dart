import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// StudentProfileService
///
/// Service to manage student-specific profile updates.
/// This service handles updating student classification fields like
/// hosteler status and department information.
///
/// Created for SAMS MVP to support conditional approval workflows
/// (e.g., Warden notification for hostelers)
class StudentProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Update the hosteler status for a student
  ///
  /// [userId] - The email prefix of the student (e.g., "student123")
  /// [isHosteler] - true if student resides in hostel, false for day scholar
  ///
  /// This field is used to determine if Warden notification should be sent
  /// when a student's event participation request is approved
  Future<void> updateHostelerStatus(String userId, bool isHosteler) async {
    try {
      await _db.collection('profiles').doc(userId).update({
        'isHosteler': isHosteler,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ Updated hosteler status for $userId: $isHosteler');
    } catch (e) {
      print('✗ Error updating hosteler status: $e');
      rethrow;
    }
  }

  /// Update the department for a student
  ///
  /// [userId] - The email prefix of the student
  /// [department] - Department name (e.g., "Computer Science", "Mechanical")
  Future<void> updateDepartment(String userId, String department) async {
    try {
      await _db.collection('profiles').doc(userId).update({
        'department': department,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ Updated department for $userId: $department');
    } catch (e) {
      print('✗ Error updating department: $e');
      rethrow;
    }
  }

  /// Update both hosteler status and department in a single transaction
  ///
  /// More efficient when updating multiple fields at once
  Future<void> updateStudentClassification({
    required String userId,
    required bool isHosteler,
    required String department,
  }) async {
    try {
      await _db.collection('profiles').doc(userId).update({
        'isHosteler': isHosteler,
        'department': department,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✓ Updated student classification for $userId');
    } catch (e) {
      print('✗ Error updating student classification: $e');
      rethrow;
    }
  }

  /// Get the current user's profile and check if they are a hosteler
  ///
  /// Returns null if user is not authenticated or profile doesn't exist
  Future<bool?> isCurrentUserHosteler() async {
    try {
      final user = AuthService().currentUser;
      if (user == null) return null;

      final emailPrefix = user.email?.split('@').first;
      if (emailPrefix == null) return null;

      final doc = await _db.collection('profiles').doc(emailPrefix).get();
      if (!doc.exists) return null;

      return doc.data()?['isHosteler'] ?? false;
    } catch (e) {
      print('✗ Error checking hosteler status: $e');
      return null;
    }
  }
}
