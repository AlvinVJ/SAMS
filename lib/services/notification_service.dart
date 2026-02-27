import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import 'auth_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SAMSNotification>> fetchNotifications() async {
    try {
      final userProfile = AuthService().userProfile;
      if (userProfile == null || userProfile.email == null) {
        throw Exception('User profile or email not found. Cannot fetch notifications.');
      }

      // The backend saves using the mits_uid (email prefix), which is mostly lowercase in Postgres
      final emailPrefix = userProfile.email!.split('@')[0].toLowerCase();

      final snapshot = await _firestore
          .collection('profiles')
          .doc(emailPrefix)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Inject the document ID so we can reference it later
        
        // Let's create a friendly title based on the message or type if one isn't provided
        if (!data.containsKey('title')) {
           data['title'] = data['type'] == 'success' ? 'Update Successful' 
                         : data['type'] == 'error' ? 'Action Required' 
                         : 'New Notification';
        }

        return SAMSNotification.fromJson(data);
      }).toList();
      
    } catch (e) {
      print('Error fetching notifications from Firestore: $e');
      rethrow;
    }
  }

  // Bonus: A function to mark a notification as read!
  Future<void> markAsRead(String notificationId) async {
    try {
      final userProfile = AuthService().userProfile;
      if (userProfile == null || userProfile.email == null) return;
      
      final emailPrefix = userProfile.email!.split('@')[0].toLowerCase();
      
      // We explicitly DELETE the notification document when it is read
      // This acts as a true Inbox where processing an alert removes it
      await _firestore
          .collection('profiles')
          .doc(emailPrefix)
          .collection('notifications')
          .doc(notificationId)
          .delete();
          
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read (delete all)
  Future<void> markAllAsRead() async {
    try {
      final userProfile = AuthService().userProfile;
      if (userProfile == null || userProfile.email == null) return;
      
      final emailPrefix = userProfile.email!.split('@')[0].toLowerCase();
      
      final snapshot = await _firestore
          .collection('profiles')
          .doc(emailPrefix)
          .collection('notifications')
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
