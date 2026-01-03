// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';
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
  // Future<AuthResolution> resolveUser() async {
  //   final user = currentUser;
  //   print(user);
  //   if (user == null) return AuthResolution.unauthenticated; //signed in

  //   if(!isMgitsEmail(user.email)) return AuthResolution.unauthorized; //not mgits

  //   final profileDoc = await _db.collection('profiles').doc(user.email).get();

  //   // 🔹 No profile exists
  //   if (!profileDoc.exists) {
  //     final email = user.email;
  //     // if (email == null) return AuthResolution.unauthenticated;



  //     // Student auto-detection (same logic as before)
  //     if (isStudentEmail(email)) {
  //       return AuthResolution.student;
  //       //do adding to profiles table
  //     }
  //     else{
  //       final allowedRole = await getAllowedRole(email);
  //       if(allowedRole == null){
  //         return AuthResolution.notAdded;
  //       }
  //       else{
  //         return AuthResolution.needsOnboarding;
  //       }
  //     }
  //   }

  //   // 🔹 Existing profile → route by role
  //   final data = profileDoc.data()!;
  //   switch (data['role']) {
  //     //implement ban check
  //     case 'admin':
  //       return AuthResolution.admin;
  //     case 'faculty':
  //       return AuthResolution.faculty;
  //     case 'student':
  //       return AuthResolution.student;
  //     default:
  //       return AuthResolution.unauthenticated;
  //   }
  // }


  Future<AuthResolution> resolveUser() async {

    final user = currentUser;
    //print(user);
    if(user == null) return AuthResolution.unauthenticated;
    final email = user.email;
    if(!isMgitsEmail(email)) return AuthResolution.unauthorized;

    //all are mgits emails
    final profileDoc = await _db.collection('profiles').doc(email).get();
    if(!profileDoc.exists){
      bool onboarding = false;
      String emailPrefix = extractEmailPrefix(email);
      if(isStudentEmail(email)){
        onboarding = true;
        await _db.collection('profiles').doc(emailPrefix).set({
          'banned': false,
          'createdAt': DateTime.timestamp(),
          'email': email, 
          'isActive': true, 
          'role': 'student',
          'uid': emailPrefix.toUpperCase(),
        });
        onboarding = false;
        //check if rollback possible
        return AuthResolution.student;
      }
      final userDoc = await _db.collection('userDetails').doc(emailPrefix).get();
      if(!userDoc.exists){
        return AuthResolution.notAdded;
      }
      onboarding = true;
      final data = userDoc.data();
      if (data == null || !data.containsKey('role')) {
        throw StateError('userDetails/$emailPrefix exists but has no role field');
      }

      final String role = data['role'] as String;
      await _db.collection('profiles').doc(emailPrefix).set({
          'banned': false,
          'createdAt': DateTime.timestamp(),
          'email': email, 
          'isActive': true, 
          'role': role,
          'uid': emailPrefix.toUpperCase(),
        });
      onboarding = false;
      switch(role){
        case 'admin':
          return AuthResolution.admin;
        case 'faculty':
          return AuthResolution.faculty;
        default:
          return AuthResolution.notAdded;
      }
    }
    else{
      final data = profileDoc.data();
      if(data==null) return AuthResolution.unauthenticated;
      if(data['isActive']){
        if(!data['banned']){
          String role = data['role'];
          switch(role){
            case 'admin':
              return AuthResolution.admin;
            case 'faculty':
              return AuthResolution.faculty;
            default:
              return AuthResolution.notAdded;
          }
        }
        return AuthResolution.banned;
      }
      return AuthResolution.inactive;
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
    if(email ==  null) return false;
    return regex.hasMatch(email);
  }

  String extractEmailPrefix(String? email) {
    if (email==null) return "";
    return email.split('@').first;
  }

  bool isMgitsEmail(String? email){
    if (email==null) return false;
    return (email.split('@').last == 'mgits.ac.in');
  }

  // -------------------------------
  // Auth actions
  // -------------------------------

  /// Starts Google OAuth.
  /// DOES NOT report success/failure.
  Future<void> signInWithGoogle() async {
    try{
      await _auth.signOut();
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({
      'prompt': 'select_account',
      'auth_type': 'reauthenticate'
    });
      await _auth.signInWithPopup(provider);
    }
    catch(e){
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
