
// import 'package:flutter/material.dart';
// import '../styles/app_theme.dart';
// import '../widgets/faculty_app_header.dart';
// import '../widgets/faculty_sidebar.dart';

// /// =====================
// /// MODEL
// /// =====================
// class RequestData {
//   final String id;
//   final String type;
//   final Color color;
//   final String name;
//   final String studentId;
//   final String department;
//   final String date;
//   final String description;
//   final List<String> attachments;

//   RequestData({
//     required this.id,
//     required this.type,
//     required this.color,
//     required this.name,
//     required this.studentId,
//     required this.department,
//     required this.date,
//     required this.description,
//     required this.attachments,
//   });
// }

// /// =====================
// /// DUMMY DATA PER ROLE  (SIMULATES API RESPONSE)
// /// =====================
// Map<String, List<RequestData>> roleRequests = {
//   "Faculty Advisor": [
//     RequestData(
//       id: 'REQ-001',
//       type: 'Leave Application',
//       color: Colors.blue,
//       name: 'Michael Foster',
//       studentId: '2021045',
//       department: 'CSE',
//       date: 'Oct 24, 2023',
//       description: '3 day medical leave request.',
//       attachments: ['medical_cert.pdf'],
//     ),
//   ],
//   "HOD": [
//     RequestData(
//       id: 'REQ-005',
//       type: 'Funding Request',
//       color: Colors.green,
//       name: 'Sarah Paul',
//       studentId: '2020143',
//       department: 'CSE',
//       date: 'Oct 21, 2023',
//       description: 'Requesting ₹20,000 for tech fest workshop.',
//       attachments: [],
//     ),
//   ],
//   "Principal": [
//     RequestData(
//       id: 'REQ-009',
//       type: 'Event Permission',
//       color: Colors.orange,
//       name: 'Manu Joseph',
//       studentId: '2020011',
//       department: 'ECE',
//       date: 'Oct 20, 2023',
//       description: 'Annual Coding Hackathon proposal.',
//       attachments: ['proposal.pdf'],
//     ),
//   ],
// };

// /// =====================
// /// SCREEN
// /// =====================
// class FacultyRequestsForApprovalScreen extends StatefulWidget {
//   const FacultyRequestsForApprovalScreen({super.key});

//   @override
//   State<FacultyRequestsForApprovalScreen> createState() =>
//       _FacultyRequestsForApprovalScreenState();
// }

// class _FacultyRequestsForApprovalScreenState
//     extends State<FacultyRequestsForApprovalScreen> {
//   String activeRole = "Faculty Advisor"; // default role

//   @override
//   Widget build(BuildContext context) {
//     final displayRequests = roleRequests[activeRole] ?? [];

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: Row(
//         children: [
//           const FacultySidebar(activeRoute: '/faculty/requests'),

//           Expanded(
//             child: Column(
//               children: [
//                 const FacultyAppHeader(facultyName: "Dr. Sarah Johnson"),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         /// HEADER + ROLE SWITCH
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Requests for Approval',
//                                   style: TextStyle(
//                                       fontSize: 28,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(height: 6),
//                                 Text(
//                                   'Review pending requests and take action.',
//                                   style: TextStyle(color: AppTheme.textLight),
//                                 ),
//                               ],
//                             ),

//                             /// ---- ROLE SWITCH ----
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: Colors.grey.shade300),
//                               ),
//                               child: DropdownButtonHideUnderline(
//                                 child: DropdownButton<String>(
//                                   value: activeRole,
//                                   items: ["Faculty Advisor", "HOD", "Principal"]
//                                       .map((role) => DropdownMenuItem(
//                                             value: role,
//                                             child: Text(role),
//                                           ))
//                                       .toList(),
//                                   onChanged: (role) {
//                                     setState(() => activeRole = role!);
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 32),

//                         /// GRID OF REQUESTS
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: displayRequests.length,
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 24,
//                             mainAxisSpacing: 24,
//                             childAspectRatio: 1.15, // smaller height
//                           ),
//                           itemBuilder: (context, index) {
//                             return _RequestCard(
//                                 request: displayRequests[index]);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// =====================
// /// REQUEST CARD (STATEFUL)
// /// =====================
// class _RequestCard extends StatefulWidget {
//   final RequestData request;

//   const _RequestCard({required this.request});

//   @override
//   State<_RequestCard> createState() => _RequestCardState();
// }

// class _RequestCardState extends State<_RequestCard> {
//   final TextEditingController _commentController = TextEditingController();

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final request = widget.request;

//     return Container(
//       padding: const EdgeInsets.all(14), // 🔽 reduced padding
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border(left: BorderSide(color: request.color, width: 3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TYPE + DATE
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Chip(
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 padding: EdgeInsets.zero,
//                 label: Text(
//                   request.type,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 backgroundColor: request.color.withOpacity(0.1),
//                 labelStyle: TextStyle(
//                   color: request.color,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 request.date,
//                 style: const TextStyle(
//                   color: AppTheme.textLight,
//                   fontSize: 11,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 6),

//           /// NAME
//           Text(
//             request.name,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           Text(
//             'ID: ${request.studentId} • ${request.department}',
//             style: const TextStyle(
//               fontSize: 11,
//               color: AppTheme.textLight,
//             ),
//           ),

//           const SizedBox(height: 6),

//           /// DESCRIPTION
//           Text(
//             request.description,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontSize: 12),
//           ),

//           const SizedBox(height: 8),

//           /// COMMENT BOX (NEW)
//           TextField(
//             controller: _commentController,
//             maxLines: 2,
//             style: const TextStyle(fontSize: 12),
//             decoration: InputDecoration(
//               hintText: 'Add comment (optional)',
//               isDense: true,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           /// ACTION BUTTONS
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                   onPressed: () {
//                     // API later:
//                     // approve(request.id, _commentController.text)
//                   },
//                   child: const Text('Approve', style: TextStyle(fontSize: 13)),
//                 ),
//               ),
//               const SizedBox(width: 6),

//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                   onPressed: () {
//                     // API later:
//                     // reject(request.id, _commentController.text)
//                   },
//                   child: const Text('Reject', style: TextStyle(fontSize: 13)),
//                 ),
//               ),

//               /// FORWARD BUTTON (NEW)
//               IconButton(
//                 tooltip: 'Forward to next authority',
//                 icon: const Icon(Icons.forward),
//                 onPressed: () {
//                   // API later:
//                   // forwardRequest(request.id, nextRole)
//                 },
//               ),

//               /// VIEW FORM
//               IconButton(
//                 tooltip: "View Form Details",
//                 icon: const Icon(Icons.visibility),
//                 onPressed: () {
//                   Navigator.pushNamed(
//                     context,
//                     "/faculty/form-view",
//                     arguments: request.id,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
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
/// DUMMY DATA (API READY)
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
  String activeRole = "Faculty Advisor";

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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Review pending requests and take action.',
                                  style:
                                      TextStyle(color: AppTheme.textLight),
                                ),
                              ],
                            ),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey.shade300),
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
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        /// GRID OF REQUESTS (FIXED HEIGHT ISSUE)
                        GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: displayRequests.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.55, // 🔥 KEY FIX
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
class _RequestCard extends StatefulWidget {
  final RequestData request;

  const _RequestCard({required this.request});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  final TextEditingController _commentController =
      TextEditingController();

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
        border:
            Border(left: BorderSide(color: request.color, width: 3)),
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
                materialTapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                label: Text(
                  request.type,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor:
                    request.color.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: request.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                request.date,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// NAME + META
          Text(
            request.name,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            'ID: ${request.studentId} • ${request.department}',
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textLight),
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
              contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
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
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {},
                  child: const Text('Approve',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {},
                  child: const Text('Reject',
                      style: TextStyle(fontSize: 13)),
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
