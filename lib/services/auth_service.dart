// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import '../state/auth_resolution.dart';
import '../models/user_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

      print("ResolveUser: User found: ${user.email}");
      final email = user.email;

      if (!isMgitsEmail(email)) {
        //  print("ResolveUser: invalid domain");
        return AuthResolution.unauthorized;
      }

      // all are mgits emails
      final profileDoc = await _db.collection('profiles').doc(email).get();
      //print("ResolveUser: Profile Exists? ${profileDoc.exists}");

      if (!profileDoc.exists) {
        bool onboarding = false;
        String emailPrefix = extractEmailPrefix(email);

        if (isStudentEmail(email)) {
          //  print("ResolveUser: Detected Student Email");
          onboarding = true;

          final newStudentData = {
            'banned': false,
            'createdAt': DateTime.timestamp(),
            'email': email,
            'isActive': true,
            'role': 'student',
            'uid': emailPrefix.toUpperCase(),
          };

          await _db.collection('profiles').doc(emailPrefix).set(newStudentData);
          // print("ResolveUser: Created Student Profile");

          _userProfile = UserProfile.fromMap(
            data: newStudentData,
            authUid: user.uid,
            email: email!,
            displayName: user.displayName,
            photoUrl: user.photoURL,
          );

          _printProfileDetails(); // Print everything

          onboarding = false;
          return AuthResolution.student;
        }

        // --- STAFF FLOW ---
        //  print("ResolveUser: Checking userDetails whitelist...");
        final userDoc = await _db
            .collection('userDetails')
            .doc(emailPrefix)
            .get();
        if (!userDoc.exists) {
          //  print("ResolveUser: Not in userDetails whitelist");
          return AuthResolution.notAdded;
        }

        onboarding = true;
        final data = userDoc.data();
        if (data == null || !data.containsKey('role')) {
          throw StateError(
            'userDetails/$emailPrefix exists but has no role field',
          );
        }

        final String role = data['role'] as String;
        final newStaffData = {
          'banned': false,
          'createdAt': DateTime.timestamp(),
          'email': email,
          'isActive': true,
          'role': role,
          'uid': emailPrefix.toUpperCase(),
        };

        await _db.collection('profiles').doc(emailPrefix).set(newStaffData);
        // print("ResolveUser: Created Staff Profile");

        _userProfile = UserProfile.fromMap(
          data: newStaffData,
          authUid: user.uid,
          email: email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );

        _printProfileDetails(); // Print everything

        onboarding = false;

        switch (role) {
          case 'admin':
            return AuthResolution.admin;
          case 'faculty':
            return AuthResolution.faculty;
          default:
            return AuthResolution.notAdded;
        }
      } else {
        final data = profileDoc.data();
        if (data == null) return AuthResolution.unauthenticated;

        // print("ResolveUser: Loading Existing Profile...");
        _userProfile = UserProfile.fromMap(
          data: data,
          authUid: user.uid,
          email: email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
        // print("ResolveUser: Memory Profile Set");

        _printProfileDetails(); // Print everything

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
    if (_userProfile != null) {
      print("--------------------------------------------------");
      print("USER PROFILE LOADED");
      print("--------------------------------------------------");
      print("Name      : ${_userProfile!.displayName}");
      print("Email     : ${_userProfile!.email}");
      print("UID (Auth): ${_userProfile!.authUid}");
      print("Role      : ${_userProfile!.role}");
      print("Photo URL : ${_userProfile!.photoUrl}");
      print("Active    : ${_userProfile!.isActive}");
      print("Banned    : ${_userProfile!.banned}");
      print("Student ID: ${_userProfile!.studentId}");
      print("--------------------------------------------------");
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
    return (email.split('@').last == 'mgits.ac.in');
  }

  // -------------------------------
  // Auth actions
  // -------------------------------

  Future<void> signInWithGoogle() async {
    try {
      await _auth.signOut();
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

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
