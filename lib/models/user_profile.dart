import 'package:flutter/foundation.dart';
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

  // 3. To take role tag for faculty
  final List<String>? roleTags;

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
    this.roleTags,
  });

  factory UserProfile.fromMap({
    required Map<String, dynamic>? data,
    required String authUid,
    required String email,
    String? displayName,
    String? photoUrl,
    List<String>? roleTags,

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
      role: data?['role'] ?? 'unknown',
      isActive: data?['isActive'],
      banned: data?['banned'],
      studentId: data?['uid'],
      createdAt: getDoB(data?['createdAt']),
      roleTags: roleTags,
    );
  }

  /// Debug helper method
  void debugPrintProfile() {
    debugPrint('''
      ========== USER PROFILE ==========
      Auth UID     : $authUid
      Email        : $email
      Display Name : ${displayName ?? 'N/A'}
      Photo URL    : ${photoUrl ?? 'N/A'}
      Role         : $role
      Is Active    : ${isActive ?? 'N/A'}
      Banned       : ${banned ?? 'N/A'}
      Student ID   : ${studentId ?? 'N/A'}
      Created At   : ${createdAt?.toIso8601String() ?? 'N/A'}
      Role tags    : ${roleTags}
      =================================
''');
  }
}
