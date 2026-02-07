import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import '../services/user_request_service.dart';
import '../services/request_approval_service.dart';
import 'request_pdf_view_screen.dart';

/// =====================
/// MODEL
/// =====================
// Dummy data removed. Fetching from backend via UserRequestService.

/// =====================
/// SCREEN
/// =====================
class FacultyRequestsForApprovalScreen extends StatefulWidget {
  const FacultyRequestsForApprovalScreen({super.key});

  @override
  State<FacultyRequestsForApprovalScreen> createState() =>
      _FacultyRequestsForApprovalScreenState();
}

class _FacultyRequestsForApprovalScreenState
    extends State<FacultyRequestsForApprovalScreen> {
  List<String> roleTags = [];
  String? activeRole;
  List<PendingApproval> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final tags = await UserRequestService().fetchRoleTags();
      setState(() {
        roleTags = tags;
        if (roleTags.isNotEmpty) {
          activeRole = roleTags.first;
        }
      });
      if (activeRole != null) {
        _fetchRequests();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load roles';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRequests() async {
    if (activeRole == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Using real backend service
      final requests = await UserRequestService().fetchPendingApprovals(
        activeRole!,
      );
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load requests';
        _isLoading = false;
      });
    }
  }

  void _onRoleChanged(String? newRole) {
    if (newRole != null && newRole != activeRole) {
      setState(() {
        activeRole = newRole;
      });
      _fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/requests'),
          Expanded(
            child: Column(
              children: [
                /// HEADER
                AppHeader(
                  key: ValueKey(activeRole), // Force rebuild if needed
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER + ROLE SWITCH
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requests for Approval',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Review pending requests and take action.',
                                  style: TextStyle(color: AppTheme.textLight),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: activeRole,
                                  items: roleTags
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _onRoleChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        /// CONTENT AREA
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(50.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_errorMessage != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(50.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          )
                        else if (_requests.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(50.0),
                              child: Text(
                                'No pending requests found for this role.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _requests.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 1.55,
                                ),
                            itemBuilder: (context, index) {
                              return _RequestCard(request: _requests[index]);
                            },
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
/// REQUEST CARD
/// =====================
class _RequestCard extends StatefulWidget {
  final PendingApproval request;

  const _RequestCard({required this.request});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  // NEW: Track loading state for approval actions
  bool _isProcessing = false;

  // NEW: Handle approve action with dialog
  Future<void> _handleApprove() async {
    if (_isProcessing) return;

    final comment = await _showActionDialog(
      title: 'Approve Request',
      message: 'Are you sure you want to approve this request?',
      confirmText: 'Approve',
      confirmColor: Colors.blue,
      isCommentRequired: false,
    );

    if (comment == null) return; // User cancelled

    setState(() => _isProcessing = true);

    try {
      final parentState = context
          .findAncestorStateOfType<_FacultyRequestsForApprovalScreenState>();
      final activeRole = parentState?.activeRole;

      if (activeRole == null) {
        throw Exception('No active role selected');
      }

      final service = RequestApprovalService();
      final success = await service.approveRequest(
        requestId: widget.request.id,
        role: activeRole,
        comments: comment.trim().isNotEmpty ? comment.trim() : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Request approved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        parentState?._fetchRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // NEW: Handle reject action with dialog
  Future<void> _handleReject() async {
    if (_isProcessing) return;

    final reason = await _showActionDialog(
      title: 'Reject Request',
      message: 'Please provide a reason for rejection:',
      confirmText: 'Reject',
      confirmColor: Colors.red,
      isCommentRequired: true,
    );

    if (reason == null || reason.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final parentState = context
          .findAncestorStateOfType<_FacultyRequestsForApprovalScreenState>();
      final activeRole = parentState?.activeRole;

      if (activeRole == null) {
        throw Exception('No active role selected');
      }

      final service = RequestApprovalService();
      final success = await service.rejectRequest(
        requestId: widget.request.id,
        role: activeRole,
        reason: reason.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Request rejected'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        parentState?._fetchRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // Helper to show approval/rejection dialog
  Future<String?> _showActionDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required bool isCommentRequired,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isCommentRequired
                    ? 'Enter reason...'
                    : 'Add a comment (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (isCommentRequired && controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Description/Reason is required'),
                  ),
                );
                return;
              }
              Navigator.pop(context, controller.text);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: request.color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TYPE + DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                label: Text(request.type, style: const TextStyle(fontSize: 12)),
                backgroundColor: request.color.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: request.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                request.date,
                style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// NAME + META
          Text(
            request.studentName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${request.studentId} • ${request.department}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),

          const SizedBox(height: 10),

          /// DESCRIPTION
          Expanded(
            child: Text(
              request.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            ),
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            children: [
              // Approve Button
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _handleApprove,
                ),
              ),
              const SizedBox(width: 8),
              // Reject Button
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Reject', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _handleReject,
                ),
              ),
              const SizedBox(width: 8),
              // View Form Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  tooltip: 'View Form',
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestPdfViewScreen(
                          requestId: request.id,
                          request: request,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
