import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_dashboard_layout.dart';
import '../services/faculty_service.dart';
import '../models/faculty_profile.dart';

class FacultyProfileScreen extends StatefulWidget {
  const FacultyProfileScreen({super.key});

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen> {
  final FacultyService _facultyService = FacultyService();
  FacultyProfile? _profile;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await _facultyService.getFacultyProfile();
      final dashboardData = await _facultyService.fetchDashboardData(
        role: "all",
      );

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = dashboardData['stats'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FacultyDashboardLayout(
      activeRoute: '/faculty/profile',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: $_error",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= BREADCRUMB =================
                  Row(
                    children: const [
                      Text('Home', style: TextStyle(color: AppTheme.textLight)),
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
                    children: [
                      _StatCard(
                        title: 'Total Requests',
                        value: _stats?['total']?.toString() ?? '0',
                        icon: Icons.folder_open,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        title: 'Approved',
                        value: _stats?['approved']?.toString() ?? '0',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        title: 'Pending',
                        value: _stats?['pending']?.toString() ?? '0',
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  /// ================= CONTACT INFO =================
                  _ContactInfoCard(email: _profile?.email ?? 'N/A'),
                  const SizedBox(height: 32),

                  const Center(
                    child: Text(
                      '© 2024 SAMS Faculty Portal. All rights reserved.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// =============== PROFILE HEADER COMPONENT ===============
  Widget _profileHeader() {
    if (_profile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.primary,
            child: Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(width: 24),

          /// NAME + DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_profile!.designation} • Employee ID: ${_profile!.mitsUid}",
                  style: const TextStyle(color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dept. of ${_profile!.department}",
                  style: const TextStyle(color: AppTheme.textLight),
                ),
                const SizedBox(height: 12),

                /// Assigned Classes
                if (_profile!.assignedClasses.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _profile!.assignedClasses
                        .map(
                          (ac) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.group,
                                  size: 18,
                                  color: AppTheme.textLight,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${ac.role}: ${ac.className}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),

                const SizedBox(height: 12),

                /// Roles / Clubs
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _profile!.roles
                      .map((r) => _Badge(r, Colors.indigo))
                      .toList(),
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
  final String email;
  const _ContactInfoCard({required this.email});

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
        children: [
          const Text(
            "Contact Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 28),
          _InfoRow(Icons.mail, "Email", email),
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
