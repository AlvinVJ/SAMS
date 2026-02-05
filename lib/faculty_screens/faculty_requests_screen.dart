import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import '../services/user_request_service.dart';
import '../services/request_approval_service.dart';

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
      // OLD: final requests = await MockUserRequestService().fetchPendingApprovals(activeRole!);
      // NEW: Using real backend service
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
  final TextEditingController _commentController = TextEditingController();

  // NEW: Track loading state for approval actions
  bool _isProcessing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // NEW: Handle approve action
  Future<void> _handleApprove() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Get active role from parent widget
      final parentState = context
          .findAncestorStateOfType<_FacultyRequestsForApprovalScreenState>();
      final activeRole = parentState?.activeRole;

      if (activeRole == null) {
        throw Exception('No active role selected');
      }

      // Call real approval service
      final service = RequestApprovalService();
      final success = await service.approveRequest(
        requestId: widget.request.id,
        role: activeRole,
        comments: _commentController.text.isNotEmpty
            ? _commentController.text
            : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Request approved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh the list
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

  // NEW: Handle reject action
  Future<void> _handleReject() async {
    if (_isProcessing) return;

    // Show dialog to get rejection reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Rejection reason...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rejection reason is required'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, reasonController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
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
        reason: reason,
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

  // OLD: _handleForward method removed
  // Forward functionality not needed - system automatically routes to next approval level

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: request.color, width: 3)),
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

          const SizedBox(height: 6),

          /// NAME + META
          Text(
            request.studentName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            'ID: ${request.studentId} • ${request.department}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
          ),

          const SizedBox(height: 6),

          /// DESCRIPTION
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 8),

          /// COMMENT (COMPACT)
          TextField(
            controller: _commentController,
            maxLines: 1,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Add comment (optional)',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// ACTIONS
          // NEW: Wired up approval action buttons with mock service
          Row(
            children: [
              // Approve Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  // OLD (commented out): onPressed: () {},
                  // NEW: Call approve handler
                  onPressed: _isProcessing ? null : _handleApprove,
                  child: _isProcessing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Approve', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 6),
              // Reject Button
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  // OLD (commented out): onPressed: () {},
                  // NEW: Call reject handler
                  onPressed: _isProcessing ? null : _handleReject,
                  child: const Text('Reject', style: TextStyle(fontSize: 13)),
                ),
              ),
              // OLD: Forward Button (removed - automatic routing)
              // System automatically routes to next approval level
              // View Form Button (temporarily disabled until screen is created)
              // TODO: Uncomment when RequestDetailsScreen is implemented
              IconButton(
                tooltip: 'View Form',
                icon: const Icon(Icons.visibility),
                // OLD: Navigation to form view (route not created yet)
                // onPressed: () {
                //   Navigator.pushNamed(
                //     context,
                //     "/faculty/form-view",
                //     arguments: request.id,
                //   );
                // },
                // NEW: Disabled for now - show info message
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ℹ️ Form view screen coming soon!'),
                      backgroundColor: Colors.blueGrey,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
