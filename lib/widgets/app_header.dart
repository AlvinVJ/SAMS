import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../services/auth_service.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _AppHeaderState extends State<AppHeader> {
  String _displayName = '...';
  String _displayRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = AuthService().userProfile;
    //final fname = AuthService().currentUser;
    if (profile != null) {
      setState(() {
        final rawName = profile.displayName ?? 'User';
        _displayName = rawName
            .split(' ')
            .map((word) {
              if (word.isEmpty) return word;
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            })
            .join(' ');

        final rawRole = profile.role;
        _displayRole = rawRole.isNotEmpty
            ? rawRole[0].toUpperCase() + rawRole.substring(1).toLowerCase()
            : '';
      });
    }
  }

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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _displayRole,
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
}
