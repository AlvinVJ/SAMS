// import 'package:flutter/material.dart';
// import '../styles/app_theme.dart';
// import '../widgets/app_header.dart';
// import '../widgets/faculty_sidebar.dart';

// // Model class for request data
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
//   final String avatarUrl;

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
//     required this.avatarUrl,
//   });
// }

// class FacultyRequestsForApprovalScreen extends StatelessWidget {
//   final String activeRole;
//   final List<RequestData>? requests; // Optional - can be null

//   const FacultyRequestsForApprovalScreen({
//     super.key,
//     this.activeRole = 'Faculty Advisor',
//     this.requests, // Will use dummy data if null
//   });

//   // Dummy data for development - easy to replace with API call later
//   static List<RequestData> _getDummyRequests() {
//     return [
//       RequestData(
//         id: 'REQ-001',
//         type: 'Leave Application',
//         color: Colors.blue,
//         name: 'Michael Foster',
//         studentId: '2021045',
//         department: 'Computer Science',
//         date: 'Oct 24, 2023',
//         description:
//             'Requesting medical leave for 3 days due to high fever and viral infection. I have attached the medical certificate from the university clinic.',
//         attachments: const ['medical_cert.pdf'],
//         avatarUrl: '',
//       ),
//       RequestData(
//         id: 'REQ-002',
//         type: 'Funding Request',
//         color: Colors.green,
//         name: 'Sarah Jenkins',
//         studentId: '2021088',
//         department: 'Robotics Club Lead',
//         date: 'Oct 23, 2023',
//         description:
//             'Requesting \$500 for materials required for the upcoming National Robotics Competition. Itemized budget breakdown attached.',
//         attachments: const ['budget_breakdown.xlsx', 'competition_flyer.pdf'],
//         avatarUrl: '',
//       ),
//       RequestData(
//         id: 'REQ-003',
//         type: 'Event Proposal',
//         color: Colors.purple,
//         name: 'David Kim',
//         studentId: '2020112',
//         department: 'Student Council Pres.',
//         date: 'Oct 22, 2023',
//         description:
//             'Seeking approval for Annual Tech Symposium to be held on Nov 15th in the Main Auditorium. Expected attendance: 200+',
//         attachments: const ['event_proposal_v2.pdf'],
//         avatarUrl: '',
//       ),
//       RequestData(
//         id: 'REQ-004',
//         type: 'Leave Application',
//         color: Colors.orange,
//         name: 'Emily Watson',
//         studentId: '2022003',
//         department: 'Electrical Eng.',
//         date: 'Oct 10, 2023',
//         description:
//             'Requesting leave for 2 weeks to attend a family wedding overseas. All coursework will be submitted in advance.',
//         attachments: const [],
//         avatarUrl: '',
//       ),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use provided requests or fall back to dummy data
//     final displayRequests = requests ?? _getDummyRequests();

//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: Row(
//         children: [
//           const FacultySidebar(activeRoute: '/faculty/requests'),

//           Expanded(
//             child: Column(
//               children: [
//                 const AppHeader(),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // ================= HEADER =================
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: const [
//                                 Text(
//                                   'Requests for Approval',
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 6),
//                                 Text(
//                                   'Review pending requests from students and staff.',
//                                   style: TextStyle(color: AppTheme.textLight),
//                                 ),
//                               ],
//                             ),

//                             _RoleSwitch(activeRole: activeRole),
//                           ],
//                         ),

//                         const SizedBox(height: 32),

//                         // ================= FILTERS =================
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Wrap(
//                               spacing: 8,
//                               children: const [
//                                 _FilterChip(label: 'All Requests', active: true),
//                                 _FilterChip(label: 'Leave Applications', count: 5),
//                                 _FilterChip(label: 'Funding', count: 2),
//                                 _FilterChip(label: 'Events', count: 1),
//                               ],
//                             ),
//                             OutlinedButton.icon(
//                               onPressed: () {},
//                               icon: const Icon(Icons.sort, size: 18),
//                               label: const Text('Sort by Date'),
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: AppTheme.textDark,
//                                 side: BorderSide(color: Colors.grey.shade300),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 32),

//                         // ================= REQUEST CARDS =================
//                         GridView.builder(
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 24,
//                             mainAxisSpacing: 24,
//                             childAspectRatio: 1.3,
//                           ),
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: displayRequests.length,
//                           itemBuilder: (context, index) {
//                             return _RequestCard(request: displayRequests[index]);
//                           },
//                         ),

//                         const SizedBox(height: 32),

//                         Center(
//                           child: TextButton.icon(
//                             onPressed: () {},
//                             icon: const Icon(Icons.expand_more),
//                             label: const Text('Load More Requests'),
//                             style: TextButton.styleFrom(
//                               foregroundColor: AppTheme.primary,
//                             ),
//                           ),
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

// /* ================= COMPONENTS ================= */

// class _RoleSwitch extends StatelessWidget {
//   final String activeRole;
  
//   const _RoleSwitch({required this.activeRole});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           _RoleItem('Faculty Advisor', active: activeRole == 'Faculty Advisor'),
//           _RoleItem('HOD', active: activeRole == 'HOD'),
//           _RoleItem('Principal', active: activeRole == 'Principal'),
//         ],
//       ),
//     );
//   }
// }

// class _RoleItem extends StatelessWidget {
//   final String label;
//   final bool active;
//   const _RoleItem(this.label, {this.active = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       decoration: BoxDecoration(
//         color: active ? Colors.white : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: active
//             ? [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 )
//               ]
//             : null,
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 14,
//           color: active ? AppTheme.primary : AppTheme.textLight,
//         ),
//       ),
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   final String label;
//   final int? count;
//   final bool active;

//   const _FilterChip({
//     required this.label,
//     this.count,
//     this.active = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       decoration: BoxDecoration(
//         color: active ? AppTheme.primary : Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: active ? AppTheme.primary : Colors.grey.shade300,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: active ? Colors.white : AppTheme.textDark,
//               fontWeight: FontWeight.w500,
//               fontSize: 14,
//             ),
//           ),
//           if (count != null) ...[
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: active ? Colors.white.withOpacity(0.3) : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 '$count',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: active ? Colors.white : AppTheme.textDark,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _RequestCard extends StatelessWidget {
//   final RequestData request;

//   const _RequestCard({required this.request});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border(
//           left: BorderSide(color: request.color, width: 4),
//           top: BorderSide(color: Colors.grey.shade200),
//           right: BorderSide(color: Colors.grey.shade200),
//           bottom: BorderSide(color: Colors.grey.shade200),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with type and date
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: request.color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   request.type,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: request.color,
//                   ),
//                 ),
//               ),
//               Text(
//                 request.date,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: AppTheme.textLight,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Student info with avatar
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: request.color.withOpacity(0.1),
//                 child: Text(
//                   request.name[0],
//                   style: TextStyle(
//                     color: request.color,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       request.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       'ID: ${request.studentId} • ${request.department}',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.textLight,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Description
//           Text(
//             request.description,
//             style: const TextStyle(
//               color: AppTheme.textDark,
//               fontSize: 14,
//               height: 1.4,
//             ),
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),

//           const SizedBox(height: 16),

//           // Attachments
//           if (request.attachments.isNotEmpty)
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: request.attachments
//                   .map(
//                     (attachment) => Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: BorderRadius.circular(6),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             _getFileIcon(attachment),
//                             size: 14,
//                             color: AppTheme.textLight,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             attachment,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: AppTheme.textDark,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                   .toList(),
//             )
//           else
//             Text(
//               'No attachments',
//               style: TextStyle(
//                 fontStyle: FontStyle.italic,
//                 color: AppTheme.textLight,
//                 fontSize: 13,
//               ),
//             ),

//           const Spacer(),

//           const Divider(height: 24),

//           // Action buttons
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppTheme.primary,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text('Approve'),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {},
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red,
//                     side: const BorderSide(color: Colors.red),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text('Reject'),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 onPressed: () {},
//                 icon: const Icon(Icons.arrow_forward),
//                 color: AppTheme.textLight,
//                 style: IconButton.styleFrom(
//                   side: BorderSide(color: Colors.grey.shade300),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getFileIcon(String filename) {
//     if (filename.endsWith('.pdf')) return Icons.picture_as_pdf;
//     if (filename.endsWith('.xlsx') || filename.endsWith('.xls')) {
//       return Icons.table_chart;
//     }
//     return Icons.attach_file;
//   }
// }

import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
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
/// SCREEN
/// =====================
class FacultyRequestsForApprovalScreen extends StatefulWidget {
  final String activeRole;
  final List<RequestData>? requests;

  const FacultyRequestsForApprovalScreen({
    super.key,
    this.activeRole = 'Faculty Advisor',
    this.requests,
  });

  @override
  State<FacultyRequestsForApprovalScreen> createState() =>
      _FacultyRequestsForApprovalScreenState();

  /// Dummy data (API-ready)
  static List<RequestData> dummyRequests() => [
        RequestData(
          id: 'REQ-001',
          type: 'Leave Application',
          color: Colors.blue,
          name: 'Michael Foster',
          studentId: '2021045',
          department: 'Computer Science',
          date: 'Oct 24, 2023',
          description:
              'Requesting medical leave for 3 days due to high fever and viral infection.',
          attachments: ['medical_cert.pdf'],
        ),
        RequestData(
          id: 'REQ-002',
          type: 'Funding Request',
          color: Colors.green,
          name: 'Sarah Jenkins',
          studentId: '2021088',
          department: 'Robotics Club Lead',
          date: 'Oct 23, 2023',
          description:
              'Requesting \$500 for materials required for the upcoming competition.',
          attachments: ['budget_breakdown.xlsx', 'competition_flyer.pdf'],
        ),
        RequestData(
          id: 'REQ-003',
          type: 'Event Proposal',
          color: Colors.purple,
          name: 'David Kim',
          studentId: '2020112',
          department: 'Student Council Pres.',
          date: 'Oct 22, 2023',
          description:
              'Seeking approval for the Annual Tech Symposium (200+ attendees).',
          attachments: ['event_proposal_v2.pdf'],
        ),
        RequestData(
          id: 'REQ-004',
          type: 'Leave Application',
          color: Colors.orange,
          name: 'Emily Watson',
          studentId: '2022003',
          department: 'Electrical Eng.',
          date: 'Oct 10, 2023',
          description:
              'Requesting leave for 2 weeks to attend a family wedding overseas.',
          attachments: [],
        ),
      ];
}

/// =====================
/// STATE
/// =====================
class _FacultyRequestsForApprovalScreenState
    extends State<FacultyRequestsForApprovalScreen> {
  late String activeRole;
  late List<RequestData> displayRequests;

  @override
  void initState() {
    super.initState();
    activeRole = widget.activeRole;
    displayRequests =
        widget.requests ?? FacultyRequestsForApprovalScreen.dummyRequests();
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
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Requests for Approval',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Review pending requests from students and staff.',
                                  style:
                                      TextStyle(color: AppTheme.textLight),
                                ),
                              ],
                            ),
                            _RoleSwitch(
                              activeRole: activeRole,
                              onChanged: (role) {
                                setState(() {
                                  activeRole = role;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        /// FILTERS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 8,
                              children: const [
                                _FilterChip(
                                    label: 'All Requests', active: true),
                                _FilterChip(
                                    label: 'Leave Applications', count: 5),
                                _FilterChip(label: 'Funding', count: 2),
                                _FilterChip(label: 'Events', count: 1),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.sort, size: 18),
                              label: const Text('Sort by Date'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        /// GRID (WEB SAFE)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: displayRequests.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: 1.3,
                              ),
                              itemBuilder: (context, index) {
                                return _RequestCard(
                                    request: displayRequests[index]);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Load More Requests'),
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
}

/// =====================
/// ROLE SWITCH
/// =====================
class _RoleSwitch extends StatelessWidget {
  final String activeRole;
  final ValueChanged<String> onChanged;

  const _RoleSwitch({
    required this.activeRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _RoleItem('Faculty Advisor',
              active: activeRole == 'Faculty Advisor', onTap: onChanged),
          _RoleItem('HOD',
              active: activeRole == 'HOD', onTap: onChanged),
          _RoleItem('Principal',
              active: activeRole == 'Principal', onTap: onChanged),
        ],
      ),
    );
  }
}

class _RoleItem extends StatelessWidget {
  final String label;
  final bool active;
  final ValueChanged<String> onTap;

  const _RoleItem(this.label,
      {required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                active ? AppTheme.primary : AppTheme.textLight,
          ),
        ),
      ),
    );
  }
}

/// =====================
/// FILTER CHIP
/// =====================
class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool active;

  const _FilterChip({
    required this.label,
    this.count,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: active
                ? AppTheme.primary
                : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  active ? Colors.white : AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 10,
              backgroundColor:
                  active ? Colors.white24 : Colors.grey.shade200,
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color:
                      active ? Colors.white : AppTheme.textDark,
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: request.color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TYPE + DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(request.type),
                backgroundColor: request.color.withOpacity(0.1),
                labelStyle: TextStyle(
                    color: request.color,
                    fontWeight: FontWeight.w600),
              ),
              Text(request.date,
                  style:
                      const TextStyle(color: AppTheme.textLight)),
            ],
          ),

          const SizedBox(height: 12),

          /// USER
          Text(request.name,
              style:
                  const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'ID: ${request.studentId} • ${request.department}',
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),

          const SizedBox(height: 12),

          Text(
            request.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),
          const Divider(),

          /// ACTIONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
