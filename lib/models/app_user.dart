import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final bool isActive;
  final bool banned;
  final DateTime createdAt;
  final String? photoUrl; //from google userdata

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.isActive,
    required this.banned,
    required this.createdAt,
    this.photoUrl,
  });

  /// Construct from Firestore
  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      isActive: data['isActive'] as bool,
      banned: data['banned'] as bool,
      createdAt: data['createdAt'] as DateTime,
      photoUrl: data['photoUrl'] as String?, // ✅
    );
  }
}
