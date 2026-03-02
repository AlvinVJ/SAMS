import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../widgets/shared_notification_list.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<SAMSNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/notifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Stay updated on critical system alerts and activities.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await _notificationService.markAllAsRead();
                      setState(() {
                        _notificationsFuture = _notificationService.fetchNotifications();
                      });
                    },
                    child: const Text(
                      'Mark All Read',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _notificationsFuture = _notificationService.fetchNotifications();
                      });
                    },
                    child: const Text(
                      'Refresh',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Shared Notifications List
          SharedNotificationList(
            notificationsFuture: _notificationsFuture,
            onMarkAsRead: (notificationId) async {
              await _notificationService.markAsRead(notificationId);
            },
            onRefresh: () {
              setState(() {
                _notificationsFuture = _notificationService.fetchNotifications();
              });
            },
          ),
        ],
      ),
    );
  }
}
