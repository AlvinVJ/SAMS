import 'package:flutter/material.dart';
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
    return SAMSNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      isUnread: json['isUnread'] ?? false,
      type: json['type'] ?? 'info',
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
