import 'package:flutter/foundation.dart';

class ApiConfig {
  // Detect platform automatically
  static String get baseUrl {
    if (kIsWeb) {
      // For web testing
      return 'https://rio.bersama.cloud/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android emulator
      return 'https://rio.bersama.cloud/api';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // For iOS simulator
      return 'https://rio.bersama.cloud/api';
    } else {
      // For physical devices - use your PC's IP address
      // Change this to your actual PC IP address
      return 'https://rio.bersama.cloud/api';
    }
  }

  // For development - you can override the base URL
  static String? _overrideBaseUrl;

  static void setBaseUrl(String url) {
    _overrideBaseUrl = url;
  }

  static String get effectiveBaseUrl {
    return _overrideBaseUrl ?? baseUrl;
  }

  static String get baseUrlWithoutApi {
    final effective = effectiveBaseUrl;
    return effective.replaceAll('/api', '');
  }

  static String get uploadsUrl {
    return '$baseUrlWithoutApi/uploads';
  }

  static String normalizeUrl(String url) {
    if (url.isEmpty) return '';

    // 1. Handle full URLs (starting with http)
    if (url.startsWith('http')) {
      // Check if it's our production domain
      if (url.contains('rio.bersama.cloud')) {
        // Enforce HTTPS
        if (url.startsWith('http://')) {
          return url.replaceFirst('http://', 'https://');
        }
        return url;
      }

      // Check for dev hosts (localhost, etc)
      final devHosts = ['localhost', '127.0.0.1', '10.0.2.2', '192.168.1.100'];
      bool isDevUrl = false;
      for (var host in devHosts) {
        if (url.contains(host)) {
          isDevUrl = true;
          break;
        }
      }

      // If it's a dev URL, we want to strip the host and make it relative
      // so we can re-append the correct base URL (which might be https://rio... or another dev host)
      if (isDevUrl) {
        if (url.contains('/uploads/')) {
          url = url.substring(url.indexOf('/uploads/') + 9);
          // Fall through to relative handling
        } else {
          // Can't identify path, just return the last segment
          url = url.split('/').last;
          // Fall through to relative handling
        }
      } else {
        // External URL (like Unsplash/Google), return as is
        return url;
      }
    }

    // 2. Handle Relative Paths

    // Remove leading slash if present
    if (url.startsWith('/')) {
      url = url.substring(1);
    }

    // If the path already has 'uploads/', use the view_image.php proxy
    if (url.startsWith('uploads/')) {
      final filename = url.replaceFirst('uploads/', '');
      return '$effectiveBaseUrl/view_image.php?file=$filename';
    }

    // Otherwise assume it's a filename, use the proxy
    return '$effectiveBaseUrl/view_image.php?file=$url';
  }
}
