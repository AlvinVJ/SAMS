// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/auth_resolution.dart';
import '../models/user_profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../screens/login_screen.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _db = FirebaseFirestore.instance; // Retired
  List<String> roleTags = [];

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<AuthResolution> resolveUser() async {
    try {
      final user = currentUser;

      if (user == null) {
        return AuthResolution.unauthenticated;
      }

      final email = user.email;
      final emailPrefix = extractEmailPrefix(email);
      print("ResolveUser: User is signed in. Email: $email, MITS UID (Doc ID): $emailPrefix");

      // 🔹 Ensure Firestore profile document exists (for subcollection access)
      // We do this EARLY so it exists even if the backend call fails or takes time.
      try {
        print("ResolveUser: Attempting to sync Firestore profile doc ($emailPrefix)...");
        await FirebaseFirestore.instance.collection('profiles').doc(emailPrefix).set({
          'email': email,
          'authUid': user.uid,
          'lastLogin': FieldValue.serverTimestamp(),
          // role will be updated after backend sync
        }, SetOptions(merge: true));
        print("ResolveUser: Firestore profile document synced/ensured (minimal)");
      } catch (e) {
        print("ResolveUser: 🔥 Firestore Error: $e");
      }

      if (!isMgitsEmail(email)) {
        print("ResolveUser: Non-MGITS email detected. Access Denied.");
        return AuthResolution.unauthorized;
      }

      // Everything is now handled by the backend API as a single source of truth
      print("ResolveUser: Calling backend signup/sync...");
      final backendData = await sendUserProfileToBackend(
        baseUrl: Environment.apiUrl,
      );
      
      final String? role = backendData['role'];
      final bool isActive = backendData['isActive'] ?? true;
      final bool banned = backendData['banned'] ?? false;

      print("ResolveUser: Backend sync successful. Role: $role");

      if (role == 'faculty' || role == 'admin') {
        try {
          roleTags = await fetchRoleTags();
        } catch (e) {
          print('ResolveUser: Error fetching role tags: $e');
        }
      }

      // Update with role and other data if we got it from backend
      try {
        await FirebaseFirestore.instance.collection('profiles').doc(emailPrefix).update({
          'role': role,
        });
        print("ResolveUser: Firestore profile updated with role: $role");
      } catch (e) {
        print("ResolveUser: Firestore update (role) failed: $e");
      }

      _userProfile = UserProfile.fromMap(
        data: backendData,
        authUid: user.uid,
        email: email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        roleTags: roleTags,
      );

      print("ResolveUser: UI Profile Initialized from Backend");
      _printProfileDetails();

      if (!isActive) return AuthResolution.inactive;
      if (banned) return AuthResolution.banned;

      switch (role) {
        case 'admin':
          return AuthResolution.admin;
        case 'faculty':
          return AuthResolution.faculty;
        case 'student':
          return AuthResolution.student;
        default:
          return AuthResolution.notAdded;
      }
    } catch (e, stackTrace) {
      print("CRITICAL ERROR in resolveUser: $e");
      // Handle the case where user is not whitelisted in SQL
      if (e.toString().contains('authorized') || e.toString().contains('not found')) {
        return AuthResolution.notAdded;
      }
      return AuthResolution.unauthenticated;
    }
  }

  // 🔹 Helper to print all details clearly

  void _printProfileDetails() {
    if (userProfile != null) {
      userProfile!.debugPrintProfile();
    }
  }

  // -------------------------------
  // Static Helpers
  // -------------------------------

  bool isStudentEmail(String? email) {
    final regex = RegExp(r'^\d+[a-zA-Z]+\d+@mgits\.ac\.in$');
    if (email == null) return false;
    return regex.hasMatch(email);
  }

  String extractEmailPrefix(String? email) {
    if (email == null) return "";
    return email.split('@').first;
  }

  bool isMgitsEmail(String? email) {
    if (email == null) return false;
    // return (email.split('@').last == 'mgits.ac.in');
    return true; 
  }

  // -------------------------------
  // Auth actions
  // -------------------------------

  Future<void> signInWithGoogle() async {
    try {
      // await _auth.signOut();
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({
        'prompt': 'select_account',
        'auth_type': 'reauthenticate',
      });
      await _auth.signInWithPopup(provider);
    } catch (e) {
      print("sign in error: $e");
    }
  }

  Future<void> handleRedirectResult() async {
    try {
      await _auth.getRedirectResult();
    } catch (e) {
      print('Redirect result error: $e');
    }
  }

  Future<AuthResolution> signOut() async {
    try {
      final user = currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final deviceId = prefs.getString('device_id');
        
        if (deviceId != null) {
          final idToken = await user.getIdToken();
          await http.delete(
            Uri.parse('http://localhost:3000/api/common/delete_fcm_token'),
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'session_id': deviceId}),
          );
          print("FCM token deleted successfully for session: $deviceId");
        }
      }
    } catch (e) {
      print("Error deleting FCM token on signout: $e");
    }

    await _auth.signOut();
    _userProfile = null;
    print("AuthService: Signed out and profile cleared");
    return AuthResolution.unauthenticated;
  }
}

// function to send signup data to express

Future<Map<String, dynamic>> sendUserProfileToBackend({
  required String baseUrl,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final authToken = await user.getIdToken();

  final response = await http.post(
    Uri.parse('${Environment.apiUrl}/api/common/signup'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
  );

  // ❌ Error case
  if (response.statusCode != 200 && response.statusCode != 201) {
    String errorMessage = 'Failed to sync user profile with backend';

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        errorMessage = decoded['message'];
      }
    } catch (_) {}

    throw Exception(errorMessage);
  }

  // ✅ Success case
  final Map<String, dynamic> decoded =
      jsonDecode(response.body) as Map<String, dynamic>;

  // optional safety check
  if (decoded['success'] != true) {
    throw Exception(decoded['message'] ?? 'Backend error');
  }

  return decoded['data'] as Map<String, dynamic>;
}

// api call to fetch the  role tag from backend and then extract the array.
Future<List<String>> fetchRoleTags() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }
  final authToken = await user.getIdToken();
  final url = Uri.parse('${Environment.apiUrl}/api/common/get_role_tags');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;

    final List<dynamic> roleTags = decoded['data']['role_tags'];

    return roleTags.map((e) => e.toString()).toList();
  } else {
    throw Exception('Failed to fetch role tags');
  }
}
