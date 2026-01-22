import 'package:flutter/foundation.dart'; // Mengimport library dasar Flutter (untuk kIsWeb dan TargetPlatform)

// Kelas konfigurasi untuk pengaturan alamat API dan pemrosesan URL
class ApiConfig {
  // Fungsi getter untuk mendeteksi platform secara otomatis dan menentukan Base URL
  static String get baseUrl {
    if (kIsWeb) {
      // Jika dijalankan di platform Web
      return 'https://rio.bersama.cloud/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Jika dijalankan di emulator/perangkat Android
      return 'https://rio.bersama.cloud/api';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Jika dijalankan di simulator/perangkat iOS
      return 'https://rio.bersama.cloud/api';
    } else {
      // Untuk perangkat fisik lainnya, menggunakan alamat IP atau domain server
      return 'https://rio.bersama.cloud/api';
    }
  }

  // Variabel private untuk menyimpan Base URL pengganti saat pengembangan
  static String? _overrideBaseUrl;

  // Fungsi untuk mengatur Base URL secara manual
  static void setBaseUrl(String url) {
    _overrideBaseUrl = url;
  }

  // Fungsi getter untuk mendapatkan Base URL yang sedang aktif (asli atau pengganti)
  static String get effectiveBaseUrl {
    return _overrideBaseUrl ?? baseUrl;
  }

  // Fungsi getter untuk mendapatkan Base URL tanpa akhiran '/api'
  static String get baseUrlWithoutApi {
    final effective = effectiveBaseUrl;
    return effective.replaceAll('/api', '');
  }

  // Fungsi getter untuk mendapatkan URL folder unggahan (uploads)
  static String get uploadsUrl {
    return '$baseUrlWithoutApi/uploads';
  }

  // Fungsi untuk menormalisasi URL gambar agar bisa ditampilkan dengan benar di aplikasi
  static String normalizeUrl(String url) {
    if (url.isEmpty) return ''; // Kembalikan string kosong jika URL kosong

    // 1. Menangani URL lengkap yang diawali dengan 'http'
    if (url.startsWith('http')) {
      // Memeriksa apakah URL tersebut milik domain produksi aplikasi
      if (url.contains('rio.bersama.cloud')) {
        // Memastikan penggunaan protokol HTTPS (lebih aman)
        if (url.startsWith('http://')) {
          return url.replaceFirst('http://', 'https://');
        }
        return url; // Sudah benar
      }

      // Daftar host untuk lingkungan pengembangan (localhost dll)
      final devHosts = ['localhost', '127.0.0.1', '10.0.2.2', '192.168.1.100'];
      bool isDevUrl = false;
      for (var host in devHosts) {
        if (url.contains(host)) {
          isDevUrl = true; // Tandai jika ini URL pengembangan lokal
          break;
        }
      }

      // Jika itu URL pengembangan, bersihkan host-nya agar bisa disesuaikan dengan Base URL baru
      if (isDevUrl) {
        if (url.contains('/uploads/')) {
          // Ambil hanya nama filenya saja dari path uploads
          url = url.substring(url.indexOf('/uploads/') + 9);
        } else {
          // Jika tidak ditemukan pola uploads, ambil bagian terakhir dari URL
          url = url.split('/').last;
        }
      } else {
        // Jika URL eksternal (seperti Google Drive/Unsplash), kembalikan apa adanya
        return url;
      }
    }

    // 2. Menangani Jalur Relatif (Relative Paths)

    // Membuang garis miring awalan jika ada (misal: '/gambar.jpg' jadi 'gambar.jpg')
    if (url.startsWith('/')) {
      url = url.substring(1);
    }

    // Jika path diawali dengan 'uploads/', alihkan ke file proxy PHP untuk keamanan/kompresi
    if (url.startsWith('uploads/')) {
      final filename = url.replaceFirst('uploads/', '');
      return '$effectiveBaseUrl/view_image.php?file=$filename';
    }

    // Jika berupa nama file langsung, asumsikan berada di folder gambar dan gunakan proxy
    return '$effectiveBaseUrl/view_image.php?file=$url';
  }
}
