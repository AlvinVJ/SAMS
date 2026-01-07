import 'package:flutter/material.dart';
import '../styles/app_theme.dart';

class FacultyAppHeader extends StatelessWidget {
  final String facultyName;
  final String facultyRole; 

  const FacultyAppHeader({
    super.key,
    required this.facultyName,
    this.facultyRole = "Faculty Advisor",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          // ===== Search Bar =====
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppTheme.textLight, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Search requests, approvals...",
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 24),

          // ===== Notifications =====
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.textDark),
          ),

          const SizedBox(width: 8),

          // ===== Profile Section =====
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary,
                child: Text(
                  // facultyName[0], // first letter
                   facultyName.isNotEmpty ? facultyName[0].toUpperCase() : "?",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(facultyName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(facultyRole,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textLight)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
