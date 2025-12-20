import 'package:flutter/material.dart';
import '../../widgets/admin_dashboard_layout.dart';
import '../../styles/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy dashboard stats (replace with API data later)
    final dashboardStats = {
      'total': 1284,
      'pending': 142,
      'approved': 1089,
      'rejected': 53,
    };

    return AdminDashboardLayout(
      activeRoute: '/admin/dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Overview of your approval system',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          // Stats Cards
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                title: 'Total Requests',
                value: dashboardStats['total']!,
                color: AppTheme.primary,
              ),
              _StatCard(
                title: 'Pending',
                value: dashboardStats['pending']!,
                color: AppTheme.warning,
              ),
              _StatCard(
                title: 'Approved',
                value: dashboardStats['approved']!,
                color: AppTheme.success,
              ),
              _StatCard(
                title: 'Rejected',
                value: dashboardStats['rejected']!,
                color: AppTheme.error,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Charts Section
          // Row(
          //   children: [
          //     Expanded(
          //       child: _ChartPlaceholder(
          //         title: 'Monthly Requests',
          //       ),
          //     ),
          //     const SizedBox(width: 24),
          //     Expanded(
          //       child: _ChartPlaceholder(
          //         title: 'Weekly Approvals',
          //       ),
          //     ),
          //   ],
          // ),

          const SizedBox(height: 32),

          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Dummy activity list (replace with API data later)
          Column(
            children: const [
              _ActivityItem(
                initials: 'JD',
                title: 'John Doe created a request',
                subtitle: 'Request #1235 - Marketing Budget Approval',
                time: '5 min ago',
              ),
              _ActivityItem(
                initials: 'SS',
                title: 'Sarah Smith approved Request #1234',
                subtitle: 'New Hire Onboarding Equipment',
                time: '12 min ago',
              ),
              _ActivityItem(
                initials: 'ED',
                title: 'Emily Davis rejected Request #1230',
                subtitle: 'Missing manager approval signature',
                time: '2 hours ago',
              ),
            ],
          ),
        ],
      ),
    );
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
          Text(title,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: color),
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
                Text(title,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
