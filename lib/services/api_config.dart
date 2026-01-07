import 'package:flutter/foundation.dart';

class ApiConfig {
  // Detect platform automatically
  static String get baseUrl {
    if (kIsWeb) {
      // For web testing
      return 'http://localhost/praktikmcuas/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android emulator
      return 'http://10.0.2.2/praktikmcuas/api';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // For iOS simulator
      return 'http://localhost:3000/praktikmcuas/api';
    } else {
      // For physical devices - use your PC's IP address
      // Change this to your actual PC IP address
      return 'http://192.168.1.100/praktikmcuas/api';
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

    // If it's a full URL containing a dev host, extract the filename/relative path
    if (url.startsWith('http')) {
      final devHosts = ['localhost', '127.0.0.1', '10.0.2.2', '192.168.1.100'];
      bool isDevUrl = false;
      for (var host in devHosts) {
        if (url.contains(host)) {
          isDevUrl = true;
          break;
        }
      }

      if (isDevUrl) {
        // Find the index of /uploads/ or /praktikmcuas/
        if (url.contains('/uploads/')) {
          url = url.substring(url.indexOf('/uploads/') + 9);
        } else if (url.contains('/api/')) {
          // Should not really happen for images, but just in case
          url = url.substring(url.indexOf('/api/') + 5);
        } else {
          // If we can't find a path, it might be a direct filename that was just prefixed with http://host/
          // extract the last part
          url = url.split('/').last;
        }
        // Now treat it as a relative path below
      } else {
        return url; // External URL (like Unsplash), leave as is
      }
    }

    // Relative path - assume it's in the uploads folder
    return '$uploadsUrl/$url';
  }
}
