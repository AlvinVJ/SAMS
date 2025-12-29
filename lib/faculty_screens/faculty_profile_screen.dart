// import 'package:flutter/material.dart';
// import '../styles/app_theme.dart';
// import '../widgets/app_header.dart';
// import '../widgets/faculty_sidebar.dart';

// class FacultyProfileScreen extends StatelessWidget {
//   const FacultyProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       body: Row(
//         children: [
//           const FacultySidebar(activeRoute: '/faculty/profile'),

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
//                         // ================= BREADCRUMB =================
//                         Row(
//                           children: const [
//                             Text(
//                               'Home',
//                               style: TextStyle(color: AppTheme.textLight),
//                             ),
//                             SizedBox(width: 6),
//                             Icon(Icons.chevron_right,
//                                 size: 16, color: AppTheme.textLight),
//                             SizedBox(width: 6),
//                             Text(
//                               'Profile',
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 24),

//                         // ================= PROFILE CARD =================
//                         _profileHeader(),

//                         const SizedBox(height: 24),

//                         // ================= STATS =================
//                         Row(
//                           children: const [
//                             _StatCard(
//                               title: 'Total Requests',
//                               value: '124',
//                               subtitle: '+12% this month',
//                               icon: Icons.folder_open,
//                               color: Colors.blue,
//                             ),
//                             SizedBox(width: 16),
//                             _StatCard(
//                               title: 'Approved',
//                               value: '110',
//                               progress: 0.88,
//                               icon: Icons.check_circle,
//                               color: Colors.green,
//                             ),
//                             SizedBox(width: 16),
//                             _StatCard(
//                               title: 'Pending Action',
//                               value: '14',
//                               subtitle: 'Requires attention',
//                               icon: Icons.pending,
//                               color: Colors.orange,
//                             ),
//                             SizedBox(width: 16),
//                             _StatCard(
//                               title: 'Years Service',
//                               value: '5',
//                               subtitle: 'Since Aug 2018',
//                               icon: Icons.verified,
//                               color: Colors.purple,
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 32),

//                         // ================= DETAILS =================
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: const [
//                             Expanded(child: _ContactInfoCard()),
//                             SizedBox(width: 24),
//                             Expanded(child: _EmploymentDetailsCard()),
//                           ],
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

//   Widget _profileHeader() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Stack(
//             children: [
//               const CircleAvatar(
//                 radius: 48,
//                 backgroundImage: NetworkImage(
//                   'https://i.pravatar.cc/300?img=47',
//                 ),
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: const BoxDecoration(
//                     color: AppTheme.primary,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.camera_alt,
//                       size: 16, color: Colors.white),
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(width: 24),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   'Sarah Johnson',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Associate Professor',
//                   style: TextStyle(color: AppTheme.primary),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   'Dept. of Computer Science',
//                   style: TextStyle(color: AppTheme.textLight),
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   children: [
//                     _Badge('Active Status', Colors.green),
//                     SizedBox(width: 8),
//                     _Badge('Tenured', Colors.blue),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {},
//             icon: const Icon(Icons.edit),
//             label: const Text('Edit Profile'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               foregroundColor: Colors.white,
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// /* ================= COMPONENTS ================= */

// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final String? subtitle;
//   final double? progress;
//   final IconData icon;
//   final Color color;

//   const _StatCard({
//     required this.title,
//     required this.value,
//     this.subtitle,
//     this.progress,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         color: AppTheme.textLight, fontSize: 13)),
//                 Icon(icon, color: color),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             if (progress != null) ...[
//               const SizedBox(height: 8),
//               LinearProgressIndicator(
//                 value: progress,
//                 color: color,
//                 backgroundColor: color.withOpacity(0.15),
//               ),
//             ],
//             if (subtitle != null) ...[
//               const SizedBox(height: 6),
//               Text(
//                 subtitle!,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: color,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ContactInfoCard extends StatelessWidget {
//   const _ContactInfoCard();

//   @override
//   Widget build(BuildContext context) {
//     return _InfoCard(
//       title: 'Contact Information',
//       trailing: const Text('Update',
//           style: TextStyle(color: AppTheme.primary)),
//       children: const [
//         _InfoRow(Icons.mail, 'Email Address',
//             's.johnson@university.edu', 'Official University ID'),
//         _InfoRow(Icons.call, 'Phone Number',
//             '+1 (555) 012-3456', 'Office Landline'),
//         _InfoRow(Icons.location_on, 'Office Location',
//             'Building B, Room 304', 'Engineering Wing'),
//       ],
//     );
//   }
// }

// class _EmploymentDetailsCard extends StatelessWidget {
//   const _EmploymentDetailsCard();

//   @override
//   Widget build(BuildContext context) {
//     return _InfoCard(
//       title: 'Employment Details',
//       children: const [
//         _InfoRow(Icons.badge, 'Employee ID', 'FAC-2023-88', ''),
//         _InfoRow(Icons.calendar_month, 'Date of Joining', 'Aug 15, 2018', ''),
//         _InfoRow(Icons.domain, 'Department', 'Computer Science', ''),
//         _InfoRow(Icons.psychology, 'Specialization',
//             'AI & Machine Learning', ''),
//         Divider(),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Tenured Professor\nLast review: Jan 2023',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             Text(
//               'Good Standing',
//               style: TextStyle(
//                 color: Colors.green,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final String title;
//   final Widget? trailing;
//   final List<Widget> children;

//   const _InfoCard({
//     required this.title,
//     this.trailing,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: Colors.grey.shade200),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold)),
//                 if (trailing != null) trailing!,
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: children),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final String subtitle;

//   const _InfoRow(this.icon, this.label, this.value, this.subtitle);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: AppTheme.textLight),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 11, color: AppTheme.textLight)),
//                 const SizedBox(height: 2),
//                 Text(value,
//                     style: const TextStyle(fontWeight: FontWeight.w600)),
//                 if (subtitle.isNotEmpty)
//                   Text(subtitle,
//                       style: const TextStyle(
//                           fontSize: 12, color: AppTheme.textLight)),
//               ],
//             ),
//           ),
//         ],
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
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 12,
//           color: color,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_app_header.dart';
import '../widgets/faculty_sidebar.dart';

class FacultyProfileScreen extends StatelessWidget {
   FacultyProfileScreen({super.key});

  // ===== Dummy Data (API-ready later) =====
  final String facultyName = "Dr. Sarah Johnson";
  final String employeeId = "FAC-2023-88";
  final String department = "Computer Science";
  final String designation = "Associate Professor";
  final String assignedClass = "S6 CSE A";
  final List<String> roles = [
    "IEEE Faculty Advisor",
    "Innovation Cell Mentor",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/profile'),

          Expanded(
            child: Column(
              children: [
                FacultyAppHeader(facultyName: facultyName),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= BREADCRUMB =================
                        Row(
                          children: const [
                            Text('Home', style: TextStyle(color: AppTheme.textLight)),
                            SizedBox(width: 6),
                            Icon(Icons.chevron_right, size: 16, color: AppTheme.textLight),
                            SizedBox(width: 6),
                            Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// ================= PROFILE HEADER =================
                        _profileHeader(),

                        const SizedBox(height: 24),

                        /// ================= STATS =================
                        Row(
                          children: const [
                            _StatCard(
                              title: 'Total Requests',
                              value: '124',
                              icon: Icons.folder_open,
                              color: AppTheme.primary,
                            ),
                            SizedBox(width: 16),
                            _StatCard(
                              title: 'Approved',
                              value: '110',
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(width: 16),
                            _StatCard(
                              title: 'Pending',
                              value: '14',
                              icon: Icons.pending,
                              color: Colors.orange,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        /// ================= CONTACT INFO =================
                        const _ContactInfoCard(),

                        const SizedBox(height: 32),

                        const Center(
                          child: Text(
                            '© 2023 SAMS Faculty Portal. All rights reserved.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
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

  /// =============== PROFILE HEADER COMPONENT ===============
  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage("https://i.pravatar.cc/300?img=47"),
          ),
          const SizedBox(width: 24),

          /// NAME + DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facultyName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "$designation • Employee ID: $employeeId",
                  style: const TextStyle(color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dept. of $department",
                  style: const TextStyle(color: AppTheme.textLight),
                ),
                const SizedBox(height: 12),

                /// Assigned Class
                Row(
                  children: [
                    const Icon(Icons.group, size: 18, color: AppTheme.textLight),
                    const SizedBox(width: 8),
                    Text(
                      "Class Faculty: $assignedClass",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Roles / Clubs
                Wrap(
                  spacing: 8,
                  children: roles.map((r) => _Badge(r, Colors.indigo)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= STATS CARD ================= */

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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= CONTACT INFO ================= */

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contact Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Divider(height: 28),
          _InfoRow(Icons.mail, "Email", "s.johnson@university.edu"),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= BADGE (ROLES) ================= */

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
