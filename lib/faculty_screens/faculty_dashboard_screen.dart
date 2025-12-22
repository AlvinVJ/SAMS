import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';

class FacultyDashboardScreen extends StatelessWidget {
  // ===== Constructor-based data (backend-ready) =====
  final String facultyName;
  final String dateText;
  final int pending;
  final int approved;
  final int rejected;
  final int total;

  const FacultyDashboardScreen({
    super.key,
    required this.facultyName,
    required this.dateText,
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/dashboard'),

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
                        // ================= WELCOME =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, $facultyName',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Here's an overview of your faculty requests and approvals for today.",
                                  style: TextStyle(color: AppTheme.textLight),
                                ),
                              ],
                            ),
                            Text(
                              dateText,
                              style:
                                  const TextStyle(color: AppTheme.textLight),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ================= STATS =================
                        GridView.count(
                          crossAxisCount: 4,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _StatCard(
                              title: 'Pending Approvals',
                              value: pending.toString(),
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                            _StatCard(
                              title: 'Approved Requests',
                              value: approved.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _StatCard(
                              title: 'Rejected Requests',
                              value: rejected.toString(),
                              icon: Icons.cancel,
                              color: Colors.red,
                            ),
                            _StatCard(
                              title: 'Total Requests',
                              value: total.toString(),
                              icon: Icons.bar_chart,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ================= QUICK ACTIONS (IN CONTAINER) =================
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _QuickActionCard(
                                    title: 'Create Request',
                                    subtitle: 'Start a new approval',
                                    icon: Icons.add,
                                    isPrimary: true,
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/faculty/create-request');
                                    },
                                  ),
                                  const SizedBox(width: 24),
                                  _QuickActionCard(
                                    title: 'Review Approvals',
                                    subtitle: 'Pending requests',
                                    icon: Icons.fact_check,
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/faculty/requests');
                                    },
                                  ),
                                  const SizedBox(width: 24),
                                  _QuickActionCard(
                                    title: 'View History',
                                    subtitle: 'Past submissions',
                                    icon: Icons.history,
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/faculty/history');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ================= RECENT PENDING APPROVALS + LATEST UPDATES (SIDE BY SIDE) =================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT: Recent Pending Approvals
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'Recent Pending Approvals',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'View All',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _ApprovalTable(),
                                ],
                              ),
                            ),

                            const SizedBox(width: 24),

                            // RIGHT: Latest Updates
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Latest Updates',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      children: [
                                        _TimelineItem(
                                          color: Colors.green,
                                          time: '2 hours ago',
                                          text:
                                              'Your request #REQ-2023-081 was approved by the Dean.',
                                        ),
                                        _TimelineItem(
                                          color: Colors.red,
                                          time: 'Yesterday',
                                          text:
                                              'Request #REQ-2023-078 was returned for correction.',
                                        ),
                                        _TimelineItem(
                                          color: AppTheme.primary,
                                          time: 'Oct 21',
                                          text:
                                              'System maintenance scheduled for Oct 28th, 10 PM - 2 AM.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // ================= FOOTER =================
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              '© 2023 Smart Approval Management System',
                              style:
                                  TextStyle(color: AppTheme.textLight),
                            ),
                            Row(
                              children: [
                                Text('Support'),
                                SizedBox(width: 16),
                                Text('Privacy Policy'),
                                SizedBox(width: 16),
                                Text('Terms of Service'),
                              ],
                            ),
                          ],
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

/* ================= REUSABLE WIDGETS ================= */

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(color: AppTheme.textLight)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.primary : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isPrimary ? AppTheme.primary : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppTheme.primary,
                size: 32,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  color:
                      isPrimary ? Colors.white70 : AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovalTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Request ID')),
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Status')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('#REQ-2023-089')),
            DataCell(Text('Lab Equipment Purchase')),
            DataCell(Text('Oct 23, 2023')),
            DataCell(Text('Pending Dean')),
          ]),
          DataRow(cells: [
            DataCell(Text('#REQ-2023-092')),
            DataCell(Text('Conference Leave')),
            DataCell(Text('Oct 22, 2023')),
            DataCell(Text('Under Review')),
          ]),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Color color;
  final String time;
  final String text;

  const _TimelineItem({
    required this.color,
    required this.time,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight)),
                const SizedBox(height: 4),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../styles/app_theme.dart';
// import '../widgets/app_header.dart';
// import '../widgets/faculty_sidebar.dart';

// class FacultyDashboardScreen extends StatelessWidget {
//   // ===== Constructor-based data (backend-ready) =====
//   final String facultyName;
//   final String dateText;
//   final int pending;
//   final int approved;
//   final int rejected;
//   final int total;

//   const FacultyDashboardScreen({
//     super.key,
//     required this.facultyName,
//     required this.dateText,
//     required this.pending,
//     required this.approved,
//     required this.rejected,
//     required this.total,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: Row(
//         children: [
//           const FacultySidebar(activeRoute: '/faculty/dashboard'),

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
//                         // ================= WELCOME =================
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Welcome back, $facultyName',
//                                   style: const TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 const Text(
//                                   "Here's an overview of your faculty requests and approvals for today.",
//                                   style: TextStyle(color: AppTheme.textLight),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               dateText,
//                               style:
//                                   const TextStyle(color: AppTheme.textLight),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 32),

//                         // ================= STATS =================
//                         GridView.count(
//                           crossAxisCount: 4,
//                           crossAxisSpacing: 24,
//                           mainAxisSpacing: 24,
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           children: [
//                             _StatCard(
//                               title: 'Pending Approvals',
//                               value: pending.toString(),
//                               icon: Icons.pending_actions,
//                               color: Colors.orange,
//                             ),
//                             _StatCard(
//                               title: 'Approved Requests',
//                               value: approved.toString(),
//                               icon: Icons.check_circle,
//                               color: Colors.green,
//                             ),
//                             _StatCard(
//                               title: 'Rejected Requests',
//                               value: rejected.toString(),
//                               icon: Icons.cancel,
//                               color: Colors.red,
//                             ),
//                             _StatCard(
//                               title: 'Total Requests',
//                               value: total.toString(),
//                               icon: Icons.bar_chart,
//                               color: AppTheme.primary,
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 40),

//                         // ================= QUICK ACTIONS =================
//                         const Text(
//                           'Quick Actions',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         Row(
//                           children: [
//                             _QuickActionCard(
//                               title: 'Create Request',
//                               subtitle: 'Start a new approval',
//                               icon: Icons.add,
//                               isPrimary: true,
//                               onTap: () {
//                                 Navigator.pushNamed(
//                                     context, '/faculty/create-request');
//                               },
//                             ),
//                             const SizedBox(width: 24),
//                             _QuickActionCard(
//                               title: 'Review Approvals',
//                               subtitle: 'Pending requests',
//                               icon: Icons.fact_check,
//                               onTap: () {
//                                 Navigator.pushNamed(
//                                     context, '/faculty/requests');
//                               },
//                             ),
//                             const SizedBox(width: 24),
//                             _QuickActionCard(
//                               title: 'View History',
//                               subtitle: 'Past submissions',
//                               icon: Icons.history,
//                               onTap: () {
//                                 Navigator.pushNamed(
//                                     context, '/faculty/history');
//                               },
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 48),

//                         // ================= RECENT PENDING APPROVALS =================
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text(
//                               'Recent Pending Approvals',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Text(
//                               'View All',
//                               style: TextStyle(
//                                 color: AppTheme.primary,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 16),

//                         _ApprovalTable(),

//                         const SizedBox(height: 48),

//                         // ================= LATEST UPDATES =================
//                         const Text(
//                           'Latest Updates',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         _TimelineItem(
//                           color: Colors.green,
//                           time: '2 hours ago',
//                           text:
//                               'Your request #REQ-2023-081 was approved by the Dean.',
//                         ),
//                         _TimelineItem(
//                           color: Colors.red,
//                           time: 'Yesterday',
//                           text:
//                               'Request #REQ-2023-078 was returned for correction.',
//                         ),
//                         _TimelineItem(
//                           color: AppTheme.primary,
//                           time: 'Oct 21',
//                           text:
//                               'System maintenance scheduled for Oct 28th, 10 PM - 2 AM.',
//                         ),

//                         const SizedBox(height: 48),

//                         // ================= FOOTER =================
//                         const Divider(),
//                         const SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text(
//                               '© 2023 Smart Approval Management System',
//                               style:
//                                   TextStyle(color: AppTheme.textLight),
//                             ),
//                             Row(
//                               children: [
//                                 Text('Support'),
//                                 SizedBox(width: 16),
//                                 Text('Privacy Policy'),
//                                 SizedBox(width: 16),
//                                 Text('Terms of Service'),
//                               ],
//                             ),
//                           ],
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

// /* ================= REUSABLE WIDGETS ================= */

// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(height: 16),
//           Text(title,
//               style: const TextStyle(color: AppTheme.textLight)),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _QuickActionCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;
//   final bool isPrimary;

//   const _QuickActionCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//     this.isPrimary = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: isPrimary ? AppTheme.primary : Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color:
//                   isPrimary ? AppTheme.primary : Colors.grey.shade200,
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(
//                 icon,
//                 color: isPrimary ? Colors.white : AppTheme.primary,
//                 size: 32,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: isPrimary ? Colors.white : AppTheme.textDark,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color:
//                       isPrimary ? Colors.white70 : AppTheme.textLight,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ApprovalTable extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: DataTable(
//         columns: const [
//           DataColumn(label: Text('Request ID')),
//           DataColumn(label: Text('Subject')),
//           DataColumn(label: Text('Date')),
//           DataColumn(label: Text('Status')),
//         ],
//         rows: const [
//           DataRow(cells: [
//             DataCell(Text('#REQ-2023-089')),
//             DataCell(Text('Lab Equipment Purchase')),
//             DataCell(Text('Oct 23, 2023')),
//             DataCell(Text('Pending Dean')),
//           ]),
//           DataRow(cells: [
//             DataCell(Text('#REQ-2023-092')),
//             DataCell(Text('Conference Leave')),
//             DataCell(Text('Oct 22, 2023')),
//             DataCell(Text('Under Review')),
//           ]),
//         ],
//       ),
//     );
//   }
// }

// class _TimelineItem extends StatelessWidget {
//   final Color color;
//   final String time;
//   final String text;

//   const _TimelineItem({
//     required this.color,
//     required this.time,
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             margin: const EdgeInsets.only(top: 6),
//             decoration:
//                 BoxDecoration(color: color, shape: BoxShape.circle),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(time,
//                     style: const TextStyle(
//                         fontSize: 12,
//                         color: AppTheme.textLight)),
//                 const SizedBox(height: 4),
//                 Text(text),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
