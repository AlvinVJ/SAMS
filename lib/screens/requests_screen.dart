import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/user_request_service.dart';
import '../widgets/dashboard_layout.dart';
import '../faculty_screens/request_pdf_view_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final UserRequestService _requestService = UserRequestService();
  late Future<List<UserRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _requestService.fetchUserRequests();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/requests',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // page header
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // filters bar
            Container(
              width: double.infinity,
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
                      value: '30',
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
              width: double.infinity,
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
              child: FutureBuilder<List<UserRequest>>(
                future: _requestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(64.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(64.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _requestsFuture = _requestService
                                      .fetchUserRequests();
                                });
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(64.0),
                        child: Text('No requests found.'),
                      ),
                    );
                  }

                  final requests = snapshot.data!;

                  return Column(
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Procedure Title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Submission Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Current Level',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Action',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: requests
                                  .map((req) => _buildRow(req))
                                  .toList(),
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
                            Text(
                              'Showing ${requests.length} requests',
                              style: const TextStyle(color: AppTheme.textLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(UserRequest req) {
    return DataRow(
      cells: [
        DataCell(
          Text(req.id, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        DataCell(Text(req.title)),
        DataCell(Text(req.date)),
        DataCell(Text('Level ${req.currentLevel} of ${req.totalLevels}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: req.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: req.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        req.status,
                        style: TextStyle(
                          color: req.statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (req.approvalHistory.isNotEmpty &&
                          req.approvalHistory.last.comments != null)
                        Text(
                          req.approvalHistory.last.comments!,
                          style: TextStyle(
                            color: req.statusColor.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(
          TextButton(
            onPressed: () => _showRequestDetails(req),
            child: Text('View Details (${req.approvalHistory.length})'),
          ),
        ),
      ],
    );
  }

  void _showRequestDetails(UserRequest req) {
    debugPrint('[UI-FINAL-VERIFY] Details Dialog opened for ID: ${req.id}');
    debugPrint(
      '[UI-FINAL-VERIFY] History Count in Object: ${req.approvalHistory.length}',
    );
    for (var i = 0; i < req.approvalHistory.length; i++) {
      debugPrint(
        '[UI-FINAL-VERIFY]   Level ${req.approvalHistory[i].level}: ${req.approvalHistory[i].status} | Comments: ${req.approvalHistory[i].comments}',
      );
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${req.id} • Submitted on ${req.date}',
                            style: const TextStyle(color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 40),

                // All Feedback summary section
                if (req.approvalHistory.any(
                  (h) => h.comments != null && h.comments!.trim().isNotEmpty,
                )) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: req.statusColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: req.statusColor.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.feedback_outlined,
                              size: 16,
                              color: req.statusColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'APPROVAL FEEDBACK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...req.approvalHistory
                            .where(
                              (h) =>
                                  h.comments != null &&
                                  h.comments!.trim().isNotEmpty,
                            )
                            .map(
                              (h) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${h.approverName} (${h.role}):',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\"${h.comments}\"',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'APPROVAL TIMELINE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestPdfViewScreen(
                              requestId: req.id,
                              request: req.toPendingApproval(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('View Request PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Flexible(
                  child: req.approvalHistory.isEmpty
                      ? const Center(child: Text('No approval actions yet.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: req.approvalHistory.length,
                          itemBuilder: (context, index) {
                            final history = req.approvalHistory[index];
                            return _buildTimelineItem(
                              level: history.level,
                              status: history.status,
                              approver:
                                  '${history.approverName} (${history.role})',
                              comment: history.comments,
                              timestamp: history.timestamp,
                              isLast: index == req.approvalHistory.length - 1,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required int level,
    required String status,
    required String approver,
    String? comment,
    required String timestamp,
    bool isLast = false,
  }) {
    final isApproved = status.toUpperCase() == 'APPROVED';
    final color = isApproved ? Colors.green : Colors.red;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(width: 2, height: 80, color: Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level $level: $status',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(approver, style: const TextStyle(fontSize: 14)),
              if (comment != null && comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Text(
                    '"$comment"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                timestamp,
                style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
