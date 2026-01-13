import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import '../services/user_request_service.dart';

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
  String activeRole = "Faculty Advisor";
  final UserRequestService _requestService = UserRequestService();
  late Future<List<PendingApproval>> _pendingRequestsFuture;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _pendingRequestsFuture = _requestService.fetchPendingApprovals(
        activeRole,
      );
    });
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
                const AppHeader(),

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
                                  items: ["Faculty Advisor", "HOD", "Principal"]
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role,
                                          child: Text(role),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (role) {
                                    setState(() => activeRole = role!);
                                    _loadRequests();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        /// GRID OF REQUESTS (DYNAMIC)
                        FutureBuilder<List<PendingApproval>>(
                          future: _pendingRequestsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            final requests = snapshot.data ?? [];

                            if (requests.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text(
                                    'No pending requests for this role.',
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: requests.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                    childAspectRatio: 1.55,
                                  ),
                              itemBuilder: (context, index) {
                                return _RequestCard(
                                  request: requests[index],
                                  onAction: _loadRequests,
                                );
                              },
                            );
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
  final VoidCallback onAction;

  const _RequestCard({required this.request, required this.onAction});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(String action) async {
    final success = await UserRequestService().updateRequestStatus(
      requestId: widget.request.id,
      action: action,
      comment: _commentController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request $action successfully')));
        widget.onAction();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to perform action')),
        );
      }
    }
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
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
            request.name,
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
            maxLines: 1, // 🔥 REDUCED HEIGHT
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleAction('approve'),
                  child: const Text('Approve', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () => _handleAction('reject'),
                  child: const Text('Reject', style: TextStyle(fontSize: 13)),
                ),
              ),
              IconButton(
                tooltip: 'Forward',
                icon: const Icon(Icons.forward),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'View Form',
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/faculty/form-view",
                    arguments: request.id,
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
