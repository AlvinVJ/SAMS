import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

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
              Column(
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

          const SizedBox(height: 32),

          // Notifications List
          FutureBuilder<List<SAMSNotification>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(64.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64.0),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(64.0),
                    child: Text('No notifications found.'),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(
                    isUnread: notification.isUnread,
                    title: notification.title,
                    time: notification.timeAgo,
                    description: notification.description,
                    color: notification.color,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required bool isUnread,
    required String title,
    required String time,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnread
            ? AppTheme.primary.withValues(alpha: 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator dot
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6, right: 16),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (isUnread)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 6, right: 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isUnread
                              ? AppTheme.textDark
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnread
                        ? Colors.grey.shade700
                        : Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
