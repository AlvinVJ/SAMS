import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../globals.dart';
import '../widgets/notification_banner.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('FCM Authorization status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Initialize foreground listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a Firebase message while in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification?.title}');
          showInAppNotification(
            message.notification?.title ?? 'Notification',
            message.notification?.body ?? '',
          );
        }
      });
    }
  }

  Future<String?> getFCMToken() async {
    try {
      if (kIsWeb) {
        // For Flutter Web, you must pass the VAPID key generated from Firebase Console
        return await _firebaseMessaging.getToken(
          vapidKey: "BEjBJLilJWPbnId0WJV8iSi-aFVmqNUICC9gXXgJC5WouKSGM6BHgQf-7WIhwk3tTK03u69Jt-Har8o2jiJc27E", 
        );
      } else {
        return await _firebaseMessaging.getToken();
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
      return null;
    }
  }
}
