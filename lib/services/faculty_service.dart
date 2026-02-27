import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty_profile.dart';
import '../models/notification.dart';
import 'auth_service.dart';

import '../config/environment.dart';

class FacultyService {
  final String _baseUrl = Environment.apiUrl;

  Future<FacultyProfile> getFacultyProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not authenticated");
    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse("$_baseUrl/api/faculty/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return FacultyProfile.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? "Failed to fetch profile");
    } else {
      throw Exception("Failed to load profile: ${response.statusCode}");
    }
  }

  Future<List<SAMSNotification>> getFacultyNotifications() async {
    try {
      final userProfile = AuthService().userProfile;
      if (userProfile == null || userProfile.email == null) {
        throw Exception('User profile or email not found. Cannot fetch notifications.');
      }

      final emailPrefix = userProfile.email!.split('@')[0].toLowerCase();

      final snapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(emailPrefix)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        if (!data.containsKey('title')) {
           data['title'] = data['type'] == 'success' ? 'Update Successful' 
                         : data['type'] == 'error' ? 'Action Required' 
                         : 'New Notification';
        }

        return SAMSNotification.fromJson(data);
      }).toList();
      
    } catch (e) {
      print('Error fetching faculty notifications from Firestore: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final userProfile = AuthService().userProfile;
      if (userProfile == null || userProfile.email == null) return;
      
      final emailPrefix = userProfile.email!.split('@')[0].toLowerCase();
      
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(emailPrefix)
          .collection('notifications')
          .doc(notificationId)
          .delete();
          
    } catch (e) {
      print('Error marking faculty notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final userProfile = AuthService().userProfile;
      if (userProfile == null || userProfile.email == null) return;
      
      final emailPrefix = userProfile.email!.split('@')[0].toLowerCase();
      
      final snapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(emailPrefix)
          .collection('notifications')
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all faculty notifications as read: $e');
    }
  }
  Future<Map<String, dynamic>> fetchDashboardData({String? role}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not authenticated");
    final token = await user.getIdToken();

    final uri = Uri.parse("$_baseUrl/api/faculty/dashboard").replace(
      queryParameters: role != null && role != "all" ? {"role": role} : {},
    );

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      }
      throw Exception(data['message'] ?? "Failed to fetch dashboard data");
    } else {
      throw Exception("Failed to fetch dashboard data: ${response.statusCode}");
    }
  }
}
