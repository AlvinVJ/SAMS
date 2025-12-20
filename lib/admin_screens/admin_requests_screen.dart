import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import '../../widgets/admin_dashboard_layout.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/requests',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // PAGE HEADER
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requests',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and track all approval requests across the organization.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'New Request',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // FILTER BAR
            // =========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search requests...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: 'All Statuses',
                      items: const [
                        DropdownMenuItem(
                          value: 'All Statuses',
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Approved',
                          child: Text('Approved'),
                        ),
                        DropdownMenuItem(
                          value: 'Rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (_) {},
                      decoration: _dropdownDecoration(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: 'All Procedures',
                      items: const [
                        DropdownMenuItem(
                          value: 'All Procedures',
                          child: Text('All Procedures'),
                        ),
                        DropdownMenuItem(
                          value: 'Leave Application',
                          child: Text('Leave Application'),
                        ),
                        DropdownMenuItem(
                          value: 'Purchase Request',
                          child: Text('Purchase Request'),
                        ),
                        DropdownMenuItem(
                          value: 'Travel Auth',
                          child: Text('Travel Auth'),
                        ),
                      ],
                      onChanged: (_) {},
                      decoration: _dropdownDecoration(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'dd / mm / yyyy',
                        prefixIcon: const Icon(Icons.calendar_today, size: 20),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TABLE
            // =========================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            horizontalMargin: 16, 
                            columnSpacing: 24, 
                            headingRowHeight: 56,
                            dataRowMaxHeight: 64,
                            headingRowColor: WidgetStateProperty.all(
                              AppTheme.backgroundLight,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Request ID',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Procedure Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Submitted By',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Current Level',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Submission Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              // DataColumn(
                              //   label: Text(
                              //     'Action',
                              //     style: TextStyle(fontWeight: FontWeight.bold),
                              //   ),
                              // ),
                            ],

                            // To do: Replace this dummy request data with API response later
                            rows: _dummyRequests.map(_buildRow).toList(),
                          ),
                        ),
                      );
                    },
                  ),

                  // =========================
                  // FOOTER
                  // =========================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Showing 1 to 2 of 124 requests',
                          style: TextStyle(color: AppTheme.textLight),
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: null,
                              child: const Text('Previous'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  static DataRow _buildRow(_AdminRequest r) {
    return DataRow(
      cells: [
        DataCell(
          Text(r.id, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        DataCell(Text(r.procedure)),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: r.avatarBg,
                child: Text(
                  r.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(r.name),
            ],
          ),
        ),
        DataCell(Text(r.level)),
        DataCell(_statusBadge(r.status, r.statusColor)),
        DataCell(Text(r.date)),
        // DataCell(
        //   IconButton(icon: const Icon(Icons.visibility), onPressed: () {}),
        // ),
      ],
    );
  }

  static Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// DUMMY DATA MODEL
// =========================

class _AdminRequest {
  final String id;
  final String procedure;
  final String name;
  final String initials;
  final String level;
  final String status;
  final String date;
  final Color statusColor;
  final Color avatarBg;

  _AdminRequest({
    required this.id,
    required this.procedure,
    required this.name,
    required this.initials,
    required this.level,
    required this.status,
    required this.date,
    required this.statusColor,
    required this.avatarBg,
  });
}

// To do: Replace this dummy request data with API response later
final List<_AdminRequest> _dummyRequests = [
  _AdminRequest(
    id: '#1001',
    procedure: 'Leave Application',
    name: 'John Doe',
    initials: 'JD',
    level: 'Level 2 – Dept. Head',
    status: 'Pending',
    date: '2024-11-25',
    statusColor: AppTheme.warning,
    avatarBg: Colors.blue,
  ),
  _AdminRequest(
    id: '#1002',
    procedure: 'Purchase Request',
    name: 'Sarah Smith',
    initials: 'SS',
    level: 'Level 3 – Finance Mgr',
    status: 'Approved',
    date: '2024-11-24',
    statusColor: AppTheme.success,
    avatarBg: Colors.purple,
  ),
];
