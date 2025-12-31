import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import '../state/auth_resolution.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 Auth state stream (single source of truth)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // 🔹 PURE resolver (NO side-effects)
  Future<AuthResolution> resolveUser() async {
    final user = currentUser;
    if (user == null) return AuthResolution.unauthenticated;

    final profileDoc = await _db.collection('profiles').doc(user.uid).get();

    // 🔹 No profile exists
    if (!profileDoc.exists) {
      final email = user.email;
      if (email == null) return AuthResolution.accessDenied;

      // Student auto-detection (same logic as before)
      if (isStudentEmail(email)) {
        return AuthResolution.student;
      }

      // Admin / faculty allowlist
      final allowedRole = await getAllowedRole(email);
      if (allowedRole != null) {
        return AuthResolution.needsOnboarding;
      }

      return AuthResolution.accessDenied;
    }

    // 🔹 Existing profile → route by role
    final data = profileDoc.data()!;
    switch (data['role']) {
      case 'admin':
        return AuthResolution.admin;
      case 'faculty':
        return AuthResolution.faculty;
      default:
        return AuthResolution.student;
    }
  }

  // -------------------------------
  // Firestore helpers (read-only)
  // -------------------------------

  Future<String?> getAllowedRole(String email) async {
    final doc = await _db.collection('userdetails').doc(email).get();
    return doc.data()?['role'];
  }

  bool isStudentEmail(String email) {
    final regex = RegExp(r'^\d+[a-zA-Z]+\d+@mgits\.ac\.in$');
    return regex.hasMatch(email);
  }

  String extractStudentId(String email) {
    return email.split('@').first.toUpperCase();
  }

  // -------------------------------
  // Auth actions
  // -------------------------------

  /// Starts Google OAuth.
  /// DOES NOT report success/failure.
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    print("Entry");
    await _auth.signInWithPopup(provider);
    print("Exit");
    UserCredential user;
    user=await _auth.getRedirectResult();
    print(user);
  }

  Future<void> handleRedirectResult() async {
    try {
      UserCredential user;
      user=await _auth.getRedirectResult();
      print(user);
    } catch (e) {
      print('Redirect result error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
