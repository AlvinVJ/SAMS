
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_app_header.dart'; // 👈 changed header
import '../widgets/faculty_sidebar.dart';

/// =====================
/// MODEL
/// =====================
class FacultyRequestHistory {
  final String title;
  final String requestId;
  final String date;
  final String status; // Pending, Approved, Rejected
  final String comment;

  FacultyRequestHistory({
    required this.title,
    required this.requestId,
    required this.date,
    required this.status,
    required this.comment,
  });
}

/// =====================
/// SCREEN
/// =====================
class FacultyRequestHistoryScreen extends StatelessWidget {
  const FacultyRequestHistoryScreen({super.key});

  List<FacultyRequestHistory> get requests => [
        FacultyRequestHistory(
          title: 'Conference Leave - IEEE 2023',
          requestId: 'REQ-2023-001',
          date: 'Oct 24, 2023',
          status: 'Pending',
          comment:
              'Please attach the official acceptance letter PDF. The current screenshot is not sufficient for funding approval.',
        ),
        FacultyRequestHistory(
          title: 'Lab Equipment Purchase - Oscilloscopes',
          requestId: 'REQ-2023-014',
          date: 'Sep 12, 2023',
          status: 'Approved',
          comment:
              'Final approval granted by Dean\'s Office on Sep 15, 2023.',
        ),
        FacultyRequestHistory(
          title: 'Curriculum Change Proposal - CS101',
          requestId: 'REQ-2023-009',
          date: 'Aug 05, 2023',
          status: 'Rejected',
          comment:
              'The proposed changes overlap significantly with existing curriculum.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/history'),

          Expanded(
            child: Column(
              children: [
                /// 👇 REPLACED AppHeader with FacultyAppHeader
                const FacultyAppHeader(facultyName: "Dr. Sarah Johnson"),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Breadcrumb
                        Row(
                          children: const [
                            Text('Home',
                                style:
                                    TextStyle(color: AppTheme.textLight)),
                            Icon(Icons.chevron_right, size: 18),
                            Text('Request History',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        /// Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'My Request History',
                                  style: TextStyle(
                                    fontSize: 28, // slightly reduced
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Track the status and progress of your submitted approvals.',
                                  style: TextStyle(
                                      color: AppTheme.textLight),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('New Request'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// Stats (reduced height)
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              2.7, // 👈 WIDER THAN TALL = LOWER CARD HEIGHT
                          children: const [
                            _StatCard(
                                label: 'Total Requests',
                                value: '12',
                                icon: Icons.folder_open),
                            _StatCard(
                                label: 'Pending',
                                value: '3',
                                icon: Icons.hourglass_empty,
                                color: Colors.orange),
                            _StatCard(
                                label: 'Approved',
                                value: '8',
                                icon: Icons.check_circle,
                                color: Colors.green),
                            _StatCard(
                                label: 'Rejected',
                                value: '1',
                                icon: Icons.cancel,
                                color: Colors.red),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// Search + Filters
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        const Icon(Icons.search),
                                    hintText:
                                        'Search by ID or Subject...',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              _DropdownFilter(label: 'All Status'),
                              const SizedBox(width: 16),
                              _DropdownFilter(label: 'Last 30 Days'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// Request Cards
                        Column(
                          children: requests
                              .map((r) => _HistoryCard(request: r))
                              .toList(),
                        ),
                      ],
                    ),
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

/// =====================
/// COMPONENTS
/// =====================

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.blueGrey;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 👈 smaller
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // slightly smaller
        border: Border(left: BorderSide(color: c, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // centers vertically
        children: [
          Icon(icon, color: c, size: 18),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppTheme.textLight)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20, // 👈 smaller
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  const _DropdownFilter({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: label,
          items: [label]
              .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final FacultyRequestHistory request;
  const _HistoryCard({required this.request});

  Color get statusColor {
    switch (request.status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    request.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(request.status),
                    backgroundColor:
                        statusColor.withOpacity(0.1),
                    labelStyle:
                        TextStyle(color: statusColor),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View Details'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Meta
          Row(
            children: [
              Text(request.requestId,
                  style: const TextStyle(
                      color: AppTheme.textLight)),
              const SizedBox(width: 16),
              Text(request.date,
                  style: const TextStyle(
                      color: AppTheme.textLight)),
            ],
          ),

          const SizedBox(height: 16),

          /// Comment
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.chat, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.comment,
                    style: TextStyle(color: statusColor),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (request.status == 'Pending')
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Withdraw Request',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextButton(
                onPressed: () {},
                child: Text(
                  request.status == 'Approved'
                      ? 'Download PDF'
                      : 'Edit & Resubmit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
