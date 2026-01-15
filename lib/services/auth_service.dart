// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import '../state/auth_resolution.dart';
import '../models/user_profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/login_screen.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> roleTags = [];

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<AuthResolution> resolveUser() async {
    try {
      // print("ResolveUser: Started");
      final user = currentUser;

      if (user == null) {
        //   print("ResolveUser: User is NULL");
        return AuthResolution.unauthenticated;
      }

      final email = user.email;
      String emailPrefix = extractEmailPrefix(email);
      final uid = user.uid;

      if (!isMgitsEmail(email)) {
        //  print("ResolveUser: invalid domain");
        return AuthResolution.unauthorized;
      }

      // all are mgits emails
      final profileDoc = await _db
          .collection('profiles')
          .doc(emailPrefix)
          .get();
      //print("ResolveUser: Profile Exists? ${profileDoc.exists}");

      if (!profileDoc.exists) {
        bool onboarding = false;
        final backendBaseUrl = 'http://localhost:3000';

        final backendData = await sendUserProfileToBackend(
          baseUrl: backendBaseUrl,
        );
        print(backendData);

        final String? role = backendData['role'];
        //final String? email = backendData['email'];
        //final String uid = backendData['uid'];

        final snapshot = await _db
            .collection('profiles')
            .doc(emailPrefix)
            .get();
        print(snapshot.data());
        print(user);

        // checking for faculty role and then calling the api end point.
        //List<String> roleTags = [];
        if (snapshot.data()?['role'] == 'faculty') {
          try {
            roleTags = await fetchRoleTags();
          } catch (e) {
            print('Error : $e');
          }
        }
        _userProfile = UserProfile.fromMap(
          data: snapshot.data(),
          authUid: user.uid,
          email: email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          roleTags: roleTags,
        );

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
      } else {
        final data = profileDoc.data();
        if (data == null) {
          return AuthResolution.unauthenticated;
        } else {
          if (data['role'] == 'faculty') {
            //await call roletag api /common/get_role_tags
            try {
              roleTags = await fetchRoleTags();
            } catch (e) {
              print('Error : $e');
            }
          }
        }

        print("ResolveUser: Loading Existing Profile...");
        _userProfile = UserProfile.fromMap(
          data: data,
          authUid: user.uid,
          email: email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          roleTags: roleTags,
        );
        // print("ResolveUser: Memory Profile Set");
        print(_userProfile);
        _printProfileDetails();
        if (data['isActive'] == true) {
          if (data['banned'] != true) {
            switch (_userProfile!.role) {
              case 'admin':
                return AuthResolution.admin;
              case 'faculty':
                return AuthResolution.faculty;
              case 'student':
                return AuthResolution.student;
              default:
                return AuthResolution.notAdded;
            }
          }
          return AuthResolution.banned;
        }
        return AuthResolution.inactive;
      }
    } catch (e, stackTrace) {
      print("CRITICAL ERROR in resolveUser: $e");
      print(stackTrace);
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
  // Firestore helpers (read-only)
  // -------------------------------

  Future<String?> getAllowedRole(String? email) async {
    final doc = await _db.collection('userdetails').doc(email).get();
    return doc.data()?['role'];
  }

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
    Uri.parse('$baseUrl/api/common/signup'),
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
  final url = Uri.parse('http://localhost:3000/api/common/get_role_tags');

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

    final List<dynamic> roleTags = decoded['role_tags'];

    return roleTags.map((e) => e.toString()).toList();
  } else {
    throw Exception('Failed to fetch role tags');
  }
}
