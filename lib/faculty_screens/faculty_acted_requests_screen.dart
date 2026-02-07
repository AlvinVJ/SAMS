import 'package:flutter/material.dart';
import '../services/user_request_service.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import 'request_pdf_view_screen.dart';

class FacultyActedRequestsScreen extends StatefulWidget {
  const FacultyActedRequestsScreen({super.key});

  @override
  State<FacultyActedRequestsScreen> createState() =>
      _FacultyActedRequestsScreenState();
}

class _FacultyActedRequestsScreenState
    extends State<FacultyActedRequestsScreen> {
  final UserRequestService _service = UserRequestService();
  List<UserRequest> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final requests = await _service.fetchActedRequests();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load request history';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/request-status'),
          Expanded(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= HEADER =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Acted Requests',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Historical log of requests you have reviewed and their current status.',
                                  style: TextStyle(color: AppTheme.textLight),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ================= FILTER BAR =================
                        TextField(
                          decoration: InputDecoration(
                            hintText:
                                'Search by Request ID, Student Name, or Type',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ================= TABLE =================
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(64.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _error != null
                              ? Padding(
                                  padding: const EdgeInsets.all(64.0),
                                  child: Center(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    _tableHeader(),
                                    const Divider(height: 1),
                                    if (_requests.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(64.0),
                                        child: Center(
                                          child: Text(
                                            'No request history found.',
                                          ),
                                        ),
                                      )
                                    else
                                      ..._requests.map(
                                        (req) => _tableRow(
                                          requestId: req.id,
                                          type: req.title,
                                          requestedBy: 'Student',
                                          status: req.status,
                                          date: req.date,
                                          color: req.statusColor,
                                          levelText:
                                              'Level ${req.currentLevel} of ${req.totalLevels}',
                                          request: req,
                                        ),
                                      ),
                                  ],
                                ),
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

  // ================= TABLE HEADER =================

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.grey.shade50,
      child: Row(
        children: const [
          _Header('Request ID'),
          _Header('Request Type'),
          _Header('Submission Date'),
          _Header('Current Progress'),
          _Header('Live Status'),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  // ================= TABLE ROW =================

  Widget _tableRow({
    required String requestId,
    required String type,
    required String requestedBy,
    required String status,
    required String date,
    required Color color,
    required String levelText,
    required UserRequest request,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _Cell(requestId, primary: true),
          _Cell(type),
          _Cell(date),
          _Cell(levelText),
          Expanded(child: _Badge(status, color)),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _showRequestDetails(request),
            tooltip: 'View Details',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestPdfViewScreen(
                    requestId: requestId,
                    request: request.toPendingApproval(),
                  ),
                ),
              );
            },
            tooltip: 'Download PDF',
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(UserRequest req) {
    debugPrint('[HISTORY-DEBUG] Opening details for ${req.id}');
    debugPrint(
      '[HISTORY-DEBUG]   UserRequest History Count: ${req.approvalHistory.length}',
    );
    for (var i = 0; i < req.approvalHistory.length; i++) {
      final h = req.approvalHistory[i];
      debugPrint(
        '[HISTORY-DEBUG]     Level ${h.level}: ${h.status} by ${h.approverName} (${h.role})',
      );
    }

    final pending = req.toPendingApproval();
    debugPrint(
      '[HISTORY-DEBUG]   PendingApproval History Count: ${pending.approvalHistory.length}',
    );

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

                // Feedback section
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
                          physics: const NeverScrollableScrollPhysics(),
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
                              color: req.statusColor,
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
    required Color color,
  }) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $level: $status',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                approver,
                style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
              ),
              if (comment != null && comment.trim().isNotEmpty) ...[
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

/* ================= SMALL WIDGETS ================= */

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textLight,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool primary;
  const _Cell(this.text, {this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          color: primary ? AppTheme.primary : AppTheme.textDark,
          fontWeight: primary ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.1,
        ), // Changed from withValues to withOpacity for syntactic correctness
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // We don't have the full request object here easily without a bigger refactor,
          // but if we had req.approvalHistory, we would show it.
          // For now, keeping it clean or passing the comment.
        ],
      ),
    );
  }
}
