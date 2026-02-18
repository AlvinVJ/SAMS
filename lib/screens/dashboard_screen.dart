import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';
import '../services/auth_service.dart';
import '../services/user_request_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = 'User';
  DashboardData? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _loadUserProfile();
    await _fetchDashboardData();
  }

  void _loadUserProfile() {
    final profile = AuthService().userProfile;
    if (profile != null && profile.displayName != null) {
      setState(() {
        _userName = profile.displayName!
            .split(' ')
            .map((word) {
              if (word.isEmpty) return word;
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            })
            .join(' ');
      });
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final data = await UserRequestService().fetchDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const DashboardLayout(
        activeRoute: '/',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return DashboardLayout(
      activeRoute: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────────── Header Section ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $_userName!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here is the status of your recent applications.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  // Simple date formatting or hardcoded for now
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ───────────────── Section 1: Active Applications ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Applications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal List of Cards
          SizedBox(
            height: 160,
            child:
                (_dashboardData == null ||
                    _dashboardData!.activeRequests.isEmpty)
                ? Center(
                    child: Text(
                      'No active applications',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dashboardData!.activeRequests.length,
                    itemBuilder: (context, index) {
                      final req = _dashboardData!.activeRequests[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildActiveRequestCard(
                          title: req.title,
                          date: req.date,
                          status: req.status,
                          statusColor: req.status.toLowerCase() == 'approved'
                              ? AppTheme.success
                              : (req.status.toLowerCase() == 'rejected'
                                    ? AppTheme.error
                                    : AppTheme.warning),
                          icon: _getIconForType(req.title),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 32),

          // ───────────────── Section 2: Notifications ─────────────────
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children:
                (_dashboardData == null ||
                    _dashboardData!.notifications.isEmpty)
                ? [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No new notifications',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ]
                : _dashboardData!.notifications.map((notif) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildNotificationItem(
                        title: notif['title'] ?? '',
                        description: notif['description'] ?? '',
                        time: notif['time'] ?? '',
                        icon: _getIconForNotification(notif['type']),
                        color: _getColorForNotification(notif['type']),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRequestCard({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Submitted on $date',
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2), // border width
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    type = type.toLowerCase();
    if (type.contains('medical')) return Icons.medical_services;
    if (type.contains('lab')) return Icons.science;
    if (type.contains('event')) return Icons.event;
    if (type.contains('permission')) return Icons.assignment_turned_in;
    return Icons.description;
  }

  IconData _getIconForNotification(String? type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }

  Color _getColorForNotification(String? type) {
    switch (type) {
      case 'success':
        return AppTheme.success;
      case 'warning':
        return AppTheme.warning;
      case 'error':
        return AppTheme.error;
      case 'info':
      default:
        return Colors.blue;
    }
  }
}
