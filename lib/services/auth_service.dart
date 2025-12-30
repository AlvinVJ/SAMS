import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/auth_resolution.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;

  Future<AuthResolution> resolveUser() async {
    final user = currentUser;
    if (user == null) return AuthResolution.unauthenticated;

    final profile = await getUserProfile();

    // 🔹 No profile → onboarding / auto-provision
    if (profile == null || profile['exists'] == false) {
      final email = user.email;
      if (email == null) return AuthResolution.accessDenied;

      final allowedRole = await getAllowedRole(email);
      if (allowedRole != null) {
        return AuthResolution.needsOnboarding;
      }

      final studentId = extractStudentId(email);
      if (studentId != null) {
        await saveUserProfile(
          userIdCode: studentId,
          role: 'student',
        );
        return AuthResolution.student;
      }

      return AuthResolution.accessDenied;
    }

    // 🔹 Existing profile → route by role
    switch (profile['role']) {
      case 'admin':
        return AuthResolution.admin;
      case 'faculty':
        return AuthResolution.faculty;
      default:
        return AuthResolution.student;
    }
  }

  // -------------------------------
  // Existing methods you already had
  // -------------------------------

  Future<Map<String, dynamic>?> getUserProfile() async {
    final res = await _supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();

    return res == null ? {'exists': false} : res;
  }

  Future<String?> getAllowedRole(String email) async {
    final res = await _supabase
        .from('allowed_users')
        .select('role')
        .eq('email', email)
        .maybeSingle();

    return res?['role'];
  }

  String? extractStudentId(String email) {
    // example: 22cs123@college.edu
    final match = RegExp(r'^\d{2}[a-z]{2}\d{3}')
        .firstMatch(email);
    return match?.group(0);
  }

  Future<void> saveUserProfile({
    required String userIdCode,
    required String role,
  }) async {
    await _supabase.from('profiles').insert({
      'id': currentUser!.id,
      'user_id_code': userIdCode,
      'role': role,
    });
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? 'http://localhost:3000/'
            : 'io.supabase.sams://login-callback/',
      );
      return true;
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
