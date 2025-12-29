
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_app_header.dart';
import '../widgets/faculty_sidebar.dart';

/// =====================
/// MODEL
/// =====================
class RequestData {
  final String id;
  final String type;
  final Color color;
  final String name;
  final String studentId;
  final String department;
  final String date;
  final String description;
  final List<String> attachments;

  RequestData({
    required this.id,
    required this.type,
    required this.color,
    required this.name,
    required this.studentId,
    required this.department,
    required this.date,
    required this.description,
    required this.attachments,
  });
}

/// =====================
/// DUMMY DATA PER ROLE  (SIMULATES API RESPONSE)
/// =====================
Map<String, List<RequestData>> roleRequests = {
  "Faculty Advisor": [
    RequestData(
      id: 'REQ-001',
      type: 'Leave Application',
      color: Colors.blue,
      name: 'Michael Foster',
      studentId: '2021045',
      department: 'CSE',
      date: 'Oct 24, 2023',
      description: '3 day medical leave request.',
      attachments: ['medical_cert.pdf'],
    ),
  ],
  "HOD": [
    RequestData(
      id: 'REQ-005',
      type: 'Funding Request',
      color: Colors.green,
      name: 'Sarah Paul',
      studentId: '2020143',
      department: 'CSE',
      date: 'Oct 21, 2023',
      description: 'Requesting ₹20,000 for tech fest workshop.',
      attachments: [],
    ),
  ],
  "Principal": [
    RequestData(
      id: 'REQ-009',
      type: 'Event Permission',
      color: Colors.orange,
      name: 'Manu Joseph',
      studentId: '2020011',
      department: 'ECE',
      date: 'Oct 20, 2023',
      description: 'Annual Coding Hackathon proposal.',
      attachments: ['proposal.pdf'],
    ),
  ],
};

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
  String activeRole = "Faculty Advisor"; // default role

  @override
  Widget build(BuildContext context) {
    final displayRequests = roleRequests[activeRole] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/requests'),

          Expanded(
            child: Column(
              children: [
                const FacultyAppHeader(facultyName: "Dr. Sarah Johnson"),

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
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Review pending requests and take action.',
                                  style: TextStyle(color: AppTheme.textLight),
                                ),
                              ],
                            ),

                            /// ---- ROLE SWITCH ----
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: activeRole,
                                  items: ["Faculty Advisor", "HOD", "Principal"]
                                      .map((role) => DropdownMenuItem(
                                            value: role,
                                            child: Text(role),
                                          ))
                                      .toList(),
                                  onChanged: (role) {
                                    setState(() => activeRole = role!);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        /// GRID OF REQUESTS
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayRequests.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.15, // smaller height
                          ),
                          itemBuilder: (context, index) {
                            return _RequestCard(
                                request: displayRequests[index]);
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
class _RequestCard extends StatelessWidget {
  final RequestData request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: request.color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(request.type),
                backgroundColor: request.color.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: request.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(request.date,
                  style:
                      const TextStyle(color: AppTheme.textLight, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 8),
          Text(request.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('ID: ${request.studentId} • ${request.department}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 8),

          Expanded(
            child: Text(
              request.description,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Divider(),

          /// Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Reject'),
                ),
              ),
              IconButton(
                tooltip: "View Form Details",
                onPressed: () {
                  // 👇 this will later open full request form screen
                  Navigator.pushNamed(context, "/faculty/form-view",
                      arguments: request.id);
                },
                icon: const Icon(Icons.visibility),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
