import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
                onPressed: () {},
                child: const Text(
                  'Mark all as read',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Notifications List
          Column(
            children: [
              // Today Section
              _buildSectionHeader('Today'),
              const SizedBox(height: 12),
              _buildNotificationItem(
                isUnread: true,
                title: 'Request Approved',
                time: '2 hrs ago',
                description:
                    'Your "Leave Application for Medical Reasons" has been approved by the Department Head.',
                badges: [
                  _Badge(label: 'Approved', color: AppTheme.success),
                  _Badge(label: 'Medical Leave', color: AppTheme.primary),
                ],
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                isUnread: true,
                title: 'New Comment on Request #2024-45',
                time: '5 hrs ago',
                description:
                    'Prof. Williams left a comment: "Please attach the supporting medical certificate by tomorrow."',
              ),

              const SizedBox(height: 32),

              // Yesterday Section
              _buildSectionHeader('Yesterday'),
              const SizedBox(height: 12),
              _buildNotificationItem(
                isUnread: false,
                title: 'System Maintenance Scheduled',
                time: 'Yesterday at 4:00 PM',
                description:
                    'The SAMS portal will be undergoing scheduled maintenance on Saturday, Oct 28th from 10 PM to 2 AM.',
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                isUnread: false,
                title: 'Request Submitted Successfully',
                time: 'Yesterday at 11:30 AM',
                description:
                    'Your request for "Event Hall Booking" has been submitted and is pending initial review.',
              ),

              const SizedBox(height: 32),

              // Earlier Section
              _buildSectionHeader('Earlier'),
              const SizedBox(height: 12),
              _buildNotificationItem(
                isUnread: false,
                title: 'Request Returned for Modification',
                time: 'Oct 20',
                description:
                    'Your "Project Grant Application" was returned. Reason: Budget breakdown unclear.',
                badges: [
                  _Badge(label: 'Action Required', color: AppTheme.warning),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required bool isUnread,
    required String title,
    required String time,
    required String description,
    List<_Badge>? badges,
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
          // Unread indicator dot
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6, right: 16),
            decoration: BoxDecoration(
              color: isUnread ? AppTheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
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
                if (badges != null && badges.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: badges
                        .map(
                          (badge) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badge.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: badge.color,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String label;
  final Color color;

  _Badge({required this.label, required this.color});
}
