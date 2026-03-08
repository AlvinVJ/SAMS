import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'url_launcher_stub.dart' if (dart.library.js) 'url_launcher_web.dart' as platform;

class UrlLauncherHelper {
  static Future<void> launch(String url) async {
    if (kIsWeb) {
      try {
        platform.openUrl(url);
      } catch (e) {
        debugPrint('[UrlLauncherHelper] JS fallback failed: $e');
        // Final fallback to url_launcher even if it's likely to fail
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } else {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
