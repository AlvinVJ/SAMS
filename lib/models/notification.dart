import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../styles/app_theme.dart';

class SAMSNotification {
  final String id;
  final String title;
  final String description;
  final DateTime time;
  final bool isUnread;
  final String type; // 'success', 'error', 'info', 'warning'

  SAMSNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isUnread,
    required this.type,
  });

  factory SAMSNotification.fromJson(Map<String, dynamic> json) {
    // Handle Firestore Timestamp or ISO String safely
    DateTime parsedTime = DateTime.now();
    
    try {
      if (json['createdAt'] != null) {
        if (json['createdAt'] is String) {
          parsedTime = DateTime.parse(json['createdAt']);
        } else if (json['createdAt'] is Timestamp) {
          parsedTime = (json['createdAt'] as Timestamp).toDate();
        }
      } else if (json['time'] != null) {
        if (json['time'] is String) {
          parsedTime = DateTime.parse(json['time']);
        }
      }
    } catch (e) {
      print("Warning: Failed to parse notification time: $e");
    }

    return SAMSNotification(
      id: json['id']?.toString() ?? json['requestId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      description: json['message']?.toString() ?? json['description']?.toString() ?? '',
      time: parsedTime,
      isUnread: json.containsKey('isRead') ? !json['isRead'] : (json['isUnread'] ?? true),
      type: json['type']?.toString() ?? 'info',
    );
  }

  Color get color {
    switch (type) {
      case 'success':
        return AppTheme.success;
      case 'error':
        return AppTheme.error;
      case 'warning':
        return AppTheme.warning;
      case 'info':
      default:
        return AppTheme.primary;
    }
  }

  String get timeAgo {
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
