import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';
import '../services/auth_service.dart';
import '../services/user_request_service.dart';

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
    final profile = AuthService().userProfile;
    roleTags = profile?.roleTags ?? [];

    if (roleTags.isNotEmpty) {
      activeRole = roleTags.first;
      _fetchRequests();
    }
  }

  Future<void> _fetchRequests() async {
    if (activeRole == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {},
                  child: const Text('Approve', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {},
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
