import 'dart:convert'; // Mengimport library untuk konversi data JSON
import 'dart:io'; // Mengimport library untuk operasi I/O (seperti SocketException)
import 'dart:async'; // Mengimport library untuk pemrograman asinkron (Future dan Timeout)
import 'dart:typed_data'; // Mengimport library untuk tipe data bytes (Uint8List)
import 'package:flutter/foundation.dart'; // Mengimport library dasar Flutter
import 'package:http/http.dart'
    as http; // Mengimport library untuk permintaan HTTP
import '../models/transaction.dart'; // Mengimport model data Transaksi
import '../models/article.dart'; // Mengimport model data Artikel
import '../models/message.dart'; // Mengimport model data Notifikasi/Pesan
import 'api_config.dart'; // Mengimport konfigurasi API

// Kelas layanan untuk mengelola semua komunikasi dengan server API
class ApiService {
  // Durasi maksimal menunggu respons dari server (10 detik)
  static const Duration _timeout = Duration(seconds: 10);

  // Fungsi untuk melakukan permintaan Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/login.php'),
            body: {'email': email, 'password': password},
          )
          .timeout(_timeout); // Batas waktu tunggu

      if (response.statusCode == 200) {
        return json.decode(
          response.body,
        ); // Mengembalikan data JSON dari server
      } else {
        throw Exception(
          'HTTP Error: ${response.statusCode}',
        ); // Galat jika status bukan 200
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on HttpException {
      throw Exception(
        'Server tidak dapat ditemukan. Pastikan server API sedang berjalan.',
      );
    } on FormatException {
      throw Exception('Response server tidak valid.');
    } on TimeoutException {
      throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk melakukan pendaftaran akun baru (Register)
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/register.php'),
            body: {'name': name, 'email': email, 'password': password},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on TimeoutException {
      throw Exception('Koneksi timeout. Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk mereset kata sandi (Reset Password)
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/reset_password.php'),
            body: {'email': email, 'password': password},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk menambah data transaksi baru
  Future<Map<String, dynamic>> addTransaction(
    int userId,
    String type,
    double amount,
    String note,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/add_transaction.php'),
            body: {
              'user_id': userId.toString(),
              'type': type,
              'amount': amount.toString(),
              'note': note,
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk memperbarui data transaksi
  Future<Map<String, dynamic>> updateTransaction(
    int id,
    int userId,
    String type,
    double amount,
    String note,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/update_transaction.php'),
            body: {
              'id': id.toString(),
              'user_id': userId.toString(),
              'type': type,
              'amount': amount.toString(),
              'note': note,
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk menghapus data transaksi
  Future<Map<String, dynamic>> deleteTransaction(int id, int userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/delete_transaction.php'),
            body: {'id': id.toString(), 'user_id': userId.toString()},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk mengambil daftar riwayat transaksi pengguna
  Future<List<Transaction>> getTransactions(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.effectiveBaseUrl}/transactions.php?user_id=$userId',
            ),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        // Mengubah list JSON menjadi list objek Transaction
        return jsonResponse.map((data) => Transaction.fromJson(data)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk mengambil data statistik dashboard (total pemasukan/pengeluaran)
  Future<Map<String, dynamic>> getDashboardStats(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.effectiveBaseUrl}/dashboard_stats.php?user_id=$userId',
            ),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk mengambil daftar semua artikel
  Future<List<Article>> getArticles() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.effectiveBaseUrl}/articles.php'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        // Mengubah list JSON menjadi list objek Article
        return jsonResponse.map((data) => Article.fromJson(data)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk mengambil daftar notifikasi/pesan untuk pengguna
  Future<List<NotificationMessage>> getMessages(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${ApiConfig.effectiveBaseUrl}/messages.php?user_id=$userId',
            ),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        // Mengubah list JSON menjadi list objek NotificationMessage
        return jsonResponse
            .map((data) => NotificationMessage.fromJson(data))
            .toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk memperbarui informasi profil teks (nama & email)
  Future<Map<String, dynamic>> updateProfile(
    int userId,
    String name,
    String email,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/update_profile.php'),
            body: {'user_id': userId.toString(), 'name': name, 'email': email},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk mengunggah foto profil baru (mendukung File mobile & Bytes web)
  Future<Map<String, dynamic>> uploadProfileImage(
    int userId,
    dynamic imageFile, // Bisa berupa objek File (Mobile) atau Uint8List (Web)
  ) async {
    try {
      // Membuat permintaan Multipart (untuk unggah file)
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.effectiveBaseUrl}/upload_profile_image.php'),
      );

      request.fields['user_id'] = userId.toString();

      // Menangani berbagai tipe input gambar
      if (imageFile is File) {
        // Penanganan untuk platform Mobile/Desktop menggunakan path file
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imageFile.path),
        );
      } else if (imageFile is Uint8List) {
        // Penanganan untuk platform Web menggunakan bytes
        String filename = 'profile_image.jpg'; // default nama file

        // Deteksi format gambar sederhana berdasarkan header file bytes
        if (imageFile.length >= 4) {
          if (imageFile[0] == 0xFF && imageFile[1] == 0xD8) {
            filename = 'profile_image.jpg';
          } else if (imageFile[0] == 0x89 && imageFile[1] == 0x50) {
            filename = 'profile_image.png';
          }
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_image',
            imageFile,
            filename: filename,
          ),
        );
      } else {
        throw Exception('Tipe gambar tidak valid');
      }

      // Mengirim permintaan dan menunggu aliran respons
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: ${e.toString()}');
    }
  }

  // Fungsi untuk menghapus foto profil
  Future<Map<String, dynamic>> deleteProfileImage(int userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/delete_profile_image.php'),
            body: {'user_id': userId.toString()},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus foto profil: ${e.toString()}');
    }
  }

  // Fungsi untuk menambahkan artikel baru (hanya judul, isi, dan URL gambar)
  Future<Map<String, dynamic>> addArticle(
    String title,
    String content,
    String imageUrl,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/add_article.php'),
            body: {'title': title, 'content': content, 'image_url': imageUrl},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk menghapus artikel berdasarkan ID
  Future<Map<String, dynamic>> deleteArticle(int id) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/delete_article.php'),
            body: {'id': id.toString()},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Fungsi untuk memperbarui artikel yang sudah ada
  Future<Map<String, dynamic>> updateArticle(
    int id,
    String title,
    String content,
    String imageUrl,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/update_article.php'),
            body: {
              'id': id.toString(),
              'title': title,
              'content': content,
              'image_url': imageUrl,
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
