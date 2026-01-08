import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/faculty_sidebar.dart';

class FacultyCreateRequestScreen extends StatelessWidget {
  const FacultyCreateRequestScreen({super.key});

  // ---- Dummy data for now (API later) ----
  final String facultyName = "Dr. Sarah Johnson";

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
                AppHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 950),
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
                            const SizedBox(height: 6),
                            const Text(
                              'Choose the category that best fits your needs to begin the approval process.',
                              style: TextStyle(color: AppTheme.textLight),
                            ),

                            const SizedBox(height: 28),

                            // ===== REQUEST TYPE CARDS (reduced size) =====
                            GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 3.2, // << reduced height
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: const [
                                _RequestTypeCard(
                                  title: 'Sick Leave',
                                  description:
                                      'Leave due to medical reasons or appointments.',
                                ),
                                _RequestTypeCard(
                                  title: 'Casual Leave',
                                  description:
                                      'Personal time off or family-related matters.',
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ===== COMING SOON =====
                            Container(
                              height: 140, // reduced height
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
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

                            const SizedBox(height: 40),
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

/* ================= REQUEST TYPE CARD (reduced size) ================= */

class _RequestTypeCard extends StatelessWidget {
  final String title;
  final String description;

  const _RequestTypeCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20), // tighter padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, // reduced
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 13,
              ), // smaller
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: Navigate to request form screen when API ready
              },
              child: const Text("Apply Now"),
            ),
          ),
        ],
      ),
    );
  }
}
