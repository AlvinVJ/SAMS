import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_app_header.dart';
import '../widgets/faculty_sidebar.dart';

class FacultyActedRequestsScreen extends StatelessWidget {
  const FacultyActedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          // ✅ MUST MATCH ROUTE STRING
          const FacultySidebar(activeRoute: '/faculty/request-status'),

          Expanded(
            child: Column(
              children: [
                 /// 👇 replaced AppHeader with FacultyAppHeader
                const FacultyAppHeader(facultyName: "Dr. Sarah Johnson"),

                // ✅ MAIN CONTENT AREA
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= HEADER =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Requests',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Historical log of requests you have reviewed and acted upon.',
                                  style: TextStyle(
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                              label: const Text('Export Log'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ================= FILTER BAR =================
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      'Search by Request ID, Student Name, or Type',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _dropdown('All Actions'),
                            const SizedBox(width: 12),
                            _dropdown('Last 30 Days'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ================= TABLE =================
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _tableHeader(),
                              const Divider(height: 1),
                              ...List.generate(
                                4,
                                (index) => _tableRow(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        const Center(
                          child: Text(
                            '© 2023 SAMS Faculty Portal. All rights reserved.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
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

  // ================= UI HELPERS =================

  Widget _dropdown(String label) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField(
        value: label,
        items: [label]
            .map(
              (e) => DropdownMenuItem(value: e, child: Text(e)),
            )
            .toList(),
        onChanged: (_) {},
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.grey.shade50,
      child: Row(
        children: const [
          _Header('Request ID'),
          _Header('Request Type'),
          _Header('Requested By'),
          _Header('Your Action'),
          _Header('Status'),
          _Header('Date'),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _tableRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: const [
          _Cell('#REQ-2023-849', primary: true),
          _Cell('Course Overload'),
          _Cell('John Doe\nStudent'),
          _Badge('Approved', Colors.green),
          _Cell('Pending Dean'),
          _Cell('Oct 24, 2023'),
          Icon(Icons.visibility, size: 20),
        ],
      ),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../styles/app_theme.dart';
// import '../widgets/app_header.dart';
// import '../widgets/faculty_sidebar.dart';

// /* ===================== DATA MODEL ===================== */

// class ActedRequest {
//   final String requestId;
//   final String requestType;
//   final String requesterName;
//   final String requesterRole;
//   final String actionTaken;
//   final String currentStatus;
//   final String date;
//   final Color actionColor;

//   ActedRequest({
//     required this.requestId,
//     required this.requestType,
//     required this.requesterName,
//     required this.requesterRole,
//     required this.actionTaken,
//     required this.currentStatus,
//     required this.date,
//     required this.actionColor,
//   });
// }

// /* ===================== SCREEN ===================== */

// class FacultyActedRequestsScreen extends StatelessWidget {
//   const FacultyActedRequestsScreen({super.key});

//   // Dummy data (backend-ready)
//   static final List<ActedRequest> _dummyRequests = [
//     ActedRequest(
//       requestId: '#REQ-2023-849',
//       requestType: 'Course Overload',
//       requesterName: 'John Doe',
//       requesterRole: 'Student',
//       actionTaken: 'Approved',
//       currentStatus: 'Pending Dean',
//       date: 'Oct 24, 2023',
//       actionColor: Colors.green,
//     ),
//     ActedRequest(
//       requestId: '#REQ-2023-832',
//       requestType: 'Leave Request',
//       requesterName: 'Sarah Smith',
//       requesterRole: 'Student',
//       actionTaken: 'Rejected',
//       currentStatus: 'Closed',
//       date: 'Oct 22, 2023',
//       actionColor: Colors.red,
//     ),
//     ActedRequest(
//       requestId: '#REQ-2023-815',
//       requestType: 'Grade Change',
//       requesterName: 'Mike Ross',
//       requesterRole: 'Student',
//       actionTaken: 'Forwarded',
//       currentStatus: 'Awaiting Registrar',
//       date: 'Oct 20, 2023',
//       actionColor: AppTheme.primary,
//     ),
//     ActedRequest(
//       requestId: '#REQ-2023-790',
//       requestType: 'Lab Equipment',
//       requesterName: 'Dr. J. Cole',
//       requesterRole: 'Faculty',
//       actionTaken: 'Approved',
//       currentStatus: 'Completed',
//       date: 'Oct 18, 2023',
//       actionColor: Colors.green,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: Row(
//         children: [
//           // ✅ Correct sidebar highlight
//           const FacultySidebar(activeRoute: '/faculty/request-status'),

//           Expanded(
//             child: Column(
//               children: [
//                 const AppHeader(),

//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // ================= HEADER =================
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: const [
//                                 Text(
//                                   'Requests',
//                                   style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 6),
//                                 Text(
//                                   'Historical log of requests you have reviewed and acted upon.',
//                                   style: TextStyle(color: AppTheme.textLight),
//                                 ),
//                               ],
//                             ),
//                             OutlinedButton.icon(
//                               onPressed: () {},
//                               icon: const Icon(Icons.download),
//                               label: const Text('Export Log'),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 24),

//                         // ================= FILTER BAR =================
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 decoration: InputDecoration(
//                                   hintText:
//                                       'Search by Request ID, Student Name, or Type',
//                                   prefixIcon: const Icon(Icons.search),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             _dropdown('All Actions'),
//                             const SizedBox(width: 12),
//                             _dropdown('Last 30 Days'),
//                           ],
//                         ),

//                         const SizedBox(height: 24),

//                         // ================= TABLE =================
//                         Expanded(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               border:
//                                   Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 _tableHeader(),
//                                 const Divider(height: 1),
//                                 Expanded(
//                                   child: ListView.separated(
//                                     itemCount: _dummyRequests.length,
//                                     separatorBuilder: (_, __) =>
//                                         const Divider(height: 1),
//                                     itemBuilder: (context, index) {
//                                       return _row(_dummyRequests[index]);
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 12),

//                         // ================= FOOTER =================
//                         const Center(
//                           child: Text(
//                             '© 2023 SAMS Faculty Portal. All rights reserved.',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: AppTheme.textLight,
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

//   /* ===================== UI HELPERS ===================== */

//   Widget _dropdown(String label) {
//     return DropdownButtonFormField(
//       value: label,
//       items: [label]
//           .map(
//             (e) => DropdownMenuItem(value: e, child: Text(e)),
//           )
//           .toList(),
//       onChanged: (_) {},
//       decoration: InputDecoration(
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

//   Widget _tableHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       color: Colors.grey.shade50,
//       child: Row(
//         children: const [
//           _HeaderCell('Request ID', flex: 2),
//           _HeaderCell('Request Type', flex: 2),
//           _HeaderCell('Requested By', flex: 2),
//           _HeaderCell('Your Action', flex: 2),
//           _HeaderCell('Status', flex: 2),
//           _HeaderCell('Date', flex: 2),
//           _HeaderCell('Actions', flex: 1),
//         ],
//       ),
//     );
//   }

//   Widget _row(ActedRequest r) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       child: Row(
//         children: [
//           _cell(r.requestId, flex: 2, primary: true),
//           _cell(r.requestType, flex: 2),
//           _cell('${r.requesterName}\n${r.requesterRole}', flex: 2),
//           _badge(r.actionTaken, r.actionColor, flex: 2),
//           _cell(r.currentStatus, flex: 2),
//           _cell(r.date, flex: 2),
//           IconButton(
//             icon: const Icon(Icons.visibility),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _cell(String text,
//       {required int flex, bool primary = false}) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: primary ? FontWeight.w600 : FontWeight.normal,
//           color: primary ? AppTheme.primary : AppTheme.textDark,
//         ),
//       ),
//     );
//   }

//   Widget _badge(String text, Color color, {required int flex}) {
//     return Expanded(
//       flex: flex,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(color: color, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }

// /* ===================== SMALL COMPONENT ===================== */

// class _HeaderCell extends StatelessWidget {
//   final String label;
//   final int flex;

//   const _HeaderCell(this.label, {required this.flex});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       flex: flex,
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: AppTheme.textLight,
//         ),
//       ),
//     );
//   }
// }
