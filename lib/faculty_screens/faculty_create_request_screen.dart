import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';

class FacultyCreateRequestScreen extends StatelessWidget {
  const FacultyCreateRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          const FacultySidebar(activeRoute: '/faculty/create-request'),

          Expanded(
            child: Column(
              children: [
                const AppHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== TITLE =====
                            const Text(
                              'Select a Request Type',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Choose the category that best fits your needs to begin the approval process.',
                              style: TextStyle(color: AppTheme.textLight),
                            ),

                            const SizedBox(height: 32),

                            // ===== REQUEST CARDS =====
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              children: const [
                                _RequestTypeCard(
                                  title: 'Sick Leave',
                                  description:
                                      'Apply for leave due to medical reasons, illness, or medical appointments. Requires documentation for extended periods.',
                                ),
                                _RequestTypeCard(
                                  title: 'Casual Leave',
                                  description:
                                      'Apply for personal time off, planned vacations, or family matters. Subject to availability and prior approval.',
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ===== COMING SOON =====
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_circle_outline,
                                      size: 36,
                                      color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text(
                                    'New Request Types Coming Soon',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

/* ================= REQUEST TYPE CARD ================= */

class _RequestTypeCard extends StatelessWidget {
  final String title;
  final String description;

  const _RequestTypeCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: AppTheme.textLight),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // TODO: Navigate to form
            },
            icon: const Text('Apply Now'),
            label: const Icon(Icons.arrow_forward, size: 18),
          ),
        ],
      ),
    );
  }
}
