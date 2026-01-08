// import 'package:flutter/material.dart';
// import '../styles/app_theme.dart';
// import '../widgets/faculty_app_header.dart';
// import '../widgets/faculty_sidebar.dart';

// class FacultyActedRequestsScreen extends StatelessWidget {
//   const FacultyActedRequestsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: Row(
//         children: [
//           // ✅ MUST MATCH ROUTE STRING
//           const FacultySidebar(activeRoute: '/faculty/request-status'),

//           Expanded(
//             child: Column(
//               children: [
//                  /// 👇 replaced AppHeader with FacultyAppHeader
//                 const FacultyAppHeader(facultyName: "Dr. Sarah Johnson"),

//                 // ✅ MAIN CONTENT AREA
//                 Expanded(
//                   child: SingleChildScrollView(
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
//                                   style: TextStyle(
//                                     color: AppTheme.textLight,
//                                   ),
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
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border:
//                                 Border.all(color: Colors.grey.shade200),
//                           ),
//                           child: Column(
//                             children: [
//                               _tableHeader(),
//                               const Divider(height: 1),
//                               ...List.generate(
//                                 4,
//                                 (index) => _tableRow(),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 32),

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

//   // ================= UI HELPERS =================

//   Widget _dropdown(String label) {
//     return SizedBox(
//       width: 160,
//       child: DropdownButtonFormField(
//         value: label,
//         items: [label]
//             .map(
//               (e) => DropdownMenuItem(value: e, child: Text(e)),
//             )
//             .toList(),
//         onChanged: (_) {},
//         decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _tableHeader() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       color: Colors.grey.shade50,
//       child: Row(
//         children: const [
//           _Header('Request ID'),
//           _Header('Request Type'),
//           _Header('Requested By'),
//           _Header('Your Action'),
//           _Header('Status'),
//           _Header('Date'),
//           SizedBox(width: 40),
//         ],
//       ),
//     );
//   }

//   Widget _tableRow() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       child: Row(
//         children: const [
//           _Cell('#REQ-2023-849', primary: true),
//           _Cell('Course Overload'),
//           _Cell('John Doe\nStudent'),
//           _Badge('Approved', Colors.green),
//           _Cell('Pending Dean'),
//           _Cell('Oct 24, 2023'),
//           Icon(Icons.visibility, size: 20),
//         ],
//       ),
//     );
//   }
// }

// /* ================= SMALL WIDGETS ================= */

// class _Header extends StatelessWidget {
//   final String text;
//   const _Header(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: AppTheme.textLight,
//         ),
//       ),
//     );
//   }
// }

// class _Cell extends StatelessWidget {
//   final String text;
//   final bool primary;
//   const _Cell(this.text, {this.primary = false});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Text(
//         text,
//         style: TextStyle(
//           color: primary ? AppTheme.primary : AppTheme.textDark,
//           fontWeight: primary ? FontWeight.w600 : FontWeight.normal,
//         ),
//       ),
//     );
//   }
// }

// class _Badge extends StatelessWidget {
//   final String text;
//   final Color color;
//   const _Badge(this.text, this.color);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }
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
          const FacultySidebar(activeRoute: '/faculty/request-status'),

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
                                  style: TextStyle(color: AppTheme.textLight),
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

                              // ===== ROWS (Dummy → API ready) =====
                              _tableRow(
                                requestId: '#REQ-2023-849',
                                type: 'Course Overload',
                                requestedBy: 'John Doe\nStudent',
                                yourAction: 'Approved',
                                status: 'Pending Dean',
                                date: 'Oct 24, 2023',
                              ),
                              _tableRow(
                                requestId: '#REQ-2023-850',
                                type: 'Leave Application',
                                requestedBy: 'Jane Smith\nStudent',
                                yourAction: 'Rejected',
                                status: 'Closed',
                                date: 'Oct 20, 2023',
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

  // ================= TABLE HEADER =================

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.grey.shade50,
      child: Row(
        children: const [
          _Header('Request ID'),
          _Header('Request Type'),
          _Header('Requested By'),

          // ✅ FIXED WIDTH HEADER
          SizedBox(
            width: 140,
            child: Text(
              'Your Action',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
            ),
          ),

          _Header('Status'),
          _Header('Date'),
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
    required String yourAction,
    required String status,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _Cell(requestId, primary: true),
          _Cell(type),
          _Cell(requestedBy),

          // ✅ FIXED ALIGNMENT FOR BADGE
          SizedBox(
            width: 140,
            child: Center(
              child: _Badge(yourAction, _statusColor(yourAction)),
            ),
          ),

          _Cell(status),
          _Cell(date),
          const Icon(Icons.visibility, size: 20),
        ],
      ),
    );
  }

  // ================= STATUS COLOR =================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
