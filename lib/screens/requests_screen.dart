import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/requests',
      child: SizedBox(
        // 🔑 FORCE FULL WIDTH
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // page header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Requests',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and manage your submitted applications and approvals.',
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
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'New Request',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // filters bar
            Container(
              width: double.infinity, // 🔑 ensure stretch
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
                        hintText: 'Search by Request ID or Title',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textLight,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: 'all',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Statuses'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'approved',
                          child: Text('Approved'),
                        ),
                        DropdownMenuItem(
                          value: 'rejected',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: '30',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '30',
                          child: Text('Last 30 Days'),
                        ),
                        DropdownMenuItem(
                          value: '90',
                          child: Text('Last 3 Months'),
                        ),
                        DropdownMenuItem(
                          value: '365',
                          child: Text('This Year'),
                        ),
                      ],
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // table container
            Container(
              width: double.infinity, // 🔑 KEY FIX
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            AppTheme.backgroundLight,
                          ),
                          dataRowMinHeight: 60,
                          dataRowMaxHeight: 60,
                          columnSpacing: 32,
                          horizontalMargin: 24,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Request ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Procedure Title',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Submission Date',
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
                                'Action',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: [
                            _buildRow(
                              '#REQ-2023-892',
                              'Dormitory Application',
                              'Oct 12, 2023',
                              'Warden Review',
                              'Pending',
                              AppTheme.warning,
                            ),
                            _buildRow(
                              '#REQ-2023-855',
                              'Scholarship Appeal',
                              'Sept 05, 2023',
                              "Dean's Office",
                              'Approved',
                              AppTheme.success,
                            ),
                            _buildRow(
                              '#REQ-2023-720',
                              'Late Course Add',
                              'Aug 20, 2023',
                              'Registrar',
                              'Rejected',
                              AppTheme.error,
                            ),
                            _buildRow(
                              '#REQ-2023-690',
                              'Transcript Request',
                              'Aug 15, 2023',
                              'Completed',
                              'Approved',
                              AppTheme.success,
                            ),
                            _buildRow(
                              '#REQ-2023-611',
                              'Club Event Approval',
                              'Jul 10, 2023',
                              'Student Affairs',
                              'Pending',
                              AppTheme.warning,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // footer
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
                          'Showing 1 to 5 of 12 requests',
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

  DataRow _buildRow(
    String id,
    String title,
    String date,
    String level,
    String status,
    Color color,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(title)),
        DataCell(Text(date)),
        DataCell(Text(level)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          TextButton(onPressed: () {}, child: const Text('View Details')),
        ),
      ],
    );
  }
}
