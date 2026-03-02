import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../globals.dart'; // Make sure globals.dart has navigatorKey if needed, otherwise we'll pass context or use scaffoldMessengerKey's context

class NotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismissed;

  const NotificationBanner({
    super.key,
    required this.title,
    required this.body,
    required this.onDismissed,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.2), // Start above screen
      end: const Offset(0.0, 0.0), // Slide to natural position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20 + MediaQuery.of(context).padding.top, // Below status bar
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.body,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global reference for active overlay to prevent multiple stackings
OverlayEntry? _activeOverlay;

void showInAppNotification(String title, String body) {
  // Remove existing banner if one is already showing
  _activeOverlay?.remove();
  _activeOverlay = null;

  // Safely extract the root overlay
  if (navigatorKey.currentState == null || !navigatorKey.currentState!.mounted) {
    print("Warning: NavigatorState is null or not mounted. Cannot show banner.");
    return;
  }

  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) {
    print("Warning: OverlayState is null. App might be rebuilding or detached.");
    return;
  }

  _activeOverlay = OverlayEntry(
    builder: (context) {
      return NotificationBanner(
        title: title,
        body: body,
        onDismissed: () {
          _activeOverlay?.remove();
          _activeOverlay = null;
        },
      );
    },
  );

  overlayState.insert(_activeOverlay!);
}
