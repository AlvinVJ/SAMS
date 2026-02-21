import 'package:flutter/material.dart';
import '../../widgets/admin_dashboard_layout.dart';
import '../../styles/app_theme.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _stats;
  List<dynamic> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final data = await _adminService.getAdminDashboardStats();
      setState(() {
        _stats = data['stats'];
        _recentActivity = data['recentActivity'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overview of your approval system',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              IconButton(
                onPressed: _fetchDashboardData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Dashboard',
              ),
            ],
          ),

          const SizedBox(height: 32),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: $_errorMessage'),
                  TextButton(
                    onPressed: _fetchDashboardData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          else ...[
            // Stats Cards
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 120,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _StatCard(
                      title: 'Total Requests',
                      value: _stats?['total'] ?? 0,
                      color: AppTheme.primary,
                    );
                  case 1:
                    return _StatCard(
                      title: 'Pending',
                      value: _stats?['pending'] ?? 0,
                      color: AppTheme.warning,
                    );
                  case 2:
                    return _StatCard(
                      title: 'Approved',
                      value: _stats?['approved'] ?? 0,
                      color: AppTheme.success,
                    );
                  case 3:
                    return _StatCard(
                      title: 'Rejected',
                      value: _stats?['rejected'] ?? 0,
                      color: AppTheme.error,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            if (_recentActivity.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No recent activity found',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ),
              )
            else
              Column(
                children: _recentActivity.map((activity) {
                  return _ActivityItem(
                    initials: activity['initials'] ?? '??',
                    title: activity['title'] ?? 'Unknown Action',
                    subtitle: activity['subtitle'] ?? '',
                    time: _formatTime(activity['time']),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final dateTime = DateTime.parse(timeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return timeStr.split('T')[0];
      }
    } catch (e) {
      return '';
    }
  }
}

/* -------------------- Supporting Widgets -------------------- */

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// admin actions commented out to use in future if needed.
// class _ChartPlaceholder extends StatelessWidget {
//   final String title;

//   const _ChartPlaceholder({required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 320,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: Theme.of(context).textTheme.titleLarge),
//           const SizedBox(height: 16),

//           // Dummy chart placeholder (replace with real chart widget later)
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppTheme.backgroundLight,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Center(
//                 child: Text(
//                   'Chart Placeholder',
//                   style: TextStyle(color: AppTheme.textLight),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ActivityItem extends StatelessWidget {
  final String initials;
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.initials,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(time, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
