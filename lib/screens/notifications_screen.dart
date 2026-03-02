import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';
import '../widgets/shared_notification_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<SAMSNotification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/notifications',
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
                      'Stay updated on your request statuses and important announcements.',
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
                        _notificationsFuture = _notificationService
                            .fetchNotifications();
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

          // Notifications List
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
