import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/faculty_dashboard_layout.dart';
import '../services/user_request_service.dart';
import '../faculty_screens/request_pdf_view_screen.dart';

class UnifiedRequestsScreen extends StatefulWidget {
  final String userRole; // 'student' or 'faculty'

  const UnifiedRequestsScreen({super.key, required this.userRole});

  @override
  State<UnifiedRequestsScreen> createState() => _UnifiedRequestsScreenState();
}

class _UnifiedRequestsScreenState extends State<UnifiedRequestsScreen> {
  final UserRequestService _requestService = UserRequestService();
  List<UserRequest> _allRequests = [];
  List<UserRequest> _filteredRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final reqs = await _requestService.fetchUserRequests();
      if (mounted) {
        setState(() {
          _allRequests = reqs;
          _isLoading = false;
          _updateFilteredList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _updateFilteredList() {
    final query = _searchController.text.trim().toLowerCase();
    final status = _statusFilter.toLowerCase();

    setState(() {
      _filteredRequests = _allRequests.where((req) {
        // Title Filter
        final matchesTitle = req.title.toLowerCase().contains(query);

        // Status Filter
        bool matchesStatus = true;
        if (status != 'all') {
          matchesStatus = req.status.toLowerCase().contains(status);
        }

        return matchesTitle && matchesStatus;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shared Content
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildFilters(),
        const SizedBox(height: 24),
        _buildRequestsTable(),
      ],
    );

    // Layout Switching
    if (widget.userRole == 'student') {
      return DashboardLayout(activeRoute: '/requests', child: content);
    } else {
      return FacultyDashboardLayout(
        activeRoute:
            '/faculty/history', // Route for "My Requests" in faculty sidebar
        child: content,
      );
    }
  }

  Widget _buildHeader() {
    return Row(
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Determines where to navigate based on role
            final route = widget.userRole == 'student'
                ? '/create-request'
                : '/faculty/create-request';
            Navigator.pushNamed(context, route);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    );
  }

  Widget _buildFilters() {
    return Container(
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
              controller: _searchController,
              onChanged: (_) => _updateFilteredList(),
              decoration: InputDecoration(
                hintText: 'Search by Title',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _statusFilter = v;
                    _updateFilteredList();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildTableContent(),
    );
  }

  Widget _buildTableContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchRequests,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRequests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(64.0),
          child: Text('No requests found.'),
        ),
      );
    }

    final requests = _filteredRequests;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
              rows: requests.map((req) => _buildRow(req)).toList(),
            ),
          ),
        );
      },
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
        DataCell(Text(req.level)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: req.statusColor.withOpacity(0.1),
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
                Text(
                  req.status,
                  style: TextStyle(
                    color: req.statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
