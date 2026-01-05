import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  // 1. Data from Firebase Auth
  final String authUid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  // 2. Data from Firestore
  final String role;
  final bool? isActive;
  final bool? banned;
  final String? studentId;
  final DateTime? createdAt;

  UserProfile({
    required this.authUid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.isActive,
    this.banned,
    this.studentId,
    this.createdAt,
  });

  factory UserProfile.fromMap({
    required Map<String, dynamic> data,
    required String authUid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) {
    DateTime? getDoB(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return null;
    }

    return UserProfile(
      authUid: authUid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      role: data['role'] ?? 'student',
      isActive: data['isActive'],
      banned: data['banned'],
      studentId: data['uid'],
      createdAt: getDoB(data['createdAt']),
    );
  }
}
