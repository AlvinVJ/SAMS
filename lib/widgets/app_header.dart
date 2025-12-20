import 'package:flutter/material.dart';
import '../styles/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(bottom: BorderSide(color: Colors.transparent)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar (Desktop)
          Container(
            width: 380,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search requests...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Actions
          Row(
            children: [
              // Notification Bell
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    color: AppTheme.textLight,
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: AppTheme.backgroundLight, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Profile
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Alex Morgan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Computer Science',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBr2Jw3vi1PK-vAwuXMFVY6e3-PWBR9KZhbFlwNR9D9I2XRFGneeD_K6J3AFhL1YQT5r5oC7HEtbir0NfP2kLJ7GvWwCgwlUiyDt_dgnU6uezBHqo9F3oI2LCE7TOeab4eS4GivjcsukvljrA_ih-Joz03vRd2Qd_jpJ2NgAaUm6wDytnHmG4VUv1TXGDlRoirE1Tj-VfJcEIbCmvTivKrrWKV47IbcJwa7X7W7uYqFEFj04bA_Gf7GdZZat5GsshkzW0dX1r8NaoTq',
                    ),
                    radius: 20,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
