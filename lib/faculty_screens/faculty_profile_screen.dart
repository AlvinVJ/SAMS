import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';

class FacultyProfileScreen extends StatelessWidget {
  FacultyProfileScreen({super.key});

  // ===== Dummy Data (API-ready later) =====
  final String facultyName = "Dr. Sarah Johnson";
  final String employeeId = "FAC-2023-88";
  final String department = "Computer Science";
  final String designation = "Associate Professor";
  final String assignedClass = "S6 CSE A";
  final List<String> roles = ["IEEE Faculty Advisor", "Innovation Cell Mentor"];

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
                AppHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= BREADCRUMB =================
                        Row(
                          children: const [
                            Text(
                              'Home',
                              style: TextStyle(color: AppTheme.textLight),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppTheme.textLight,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Profile',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
                    const Icon(
                      Icons.group,
                      size: 18,
                      color: AppTheme.textLight,
                    ),
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
          Text(
            "Contact Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
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
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
