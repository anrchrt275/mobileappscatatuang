import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/article.dart';
import '../models/message.dart';
import 'api_config.dart';

class ApiService {
  // Tambahkan timeout untuk mencegah hanging
  static const Duration _timeout = Duration(seconds: 10);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.effectiveBaseUrl}/login.php'),
            body: {'email': email, 'password': password},
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
        return jsonResponse.map((data) => Transaction.fromJson(data)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
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

  Future<List<Article>> getArticles() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.effectiveBaseUrl}/articles.php'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Article.fromJson(data)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
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
        return jsonResponse
            .map((data) => NotificationMessage.fromJson(data))
            .toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
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
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }
          return json.decode(response.body);
        } catch (e) {
          print('JSON decode error in updateProfile: $e');
          print('Response body: ${response.body}');
          throw Exception('Invalid server response: ${e.toString()}');
        }
      } else {
        print(
          'Server responded with status ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'HTTP Error: ${response.statusCode}, Response: ${response.body}',
        );
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

  Future<Map<String, dynamic>> uploadProfileImage(
    int userId,
    dynamic imageFile, // Can be File or Uint8List
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.effectiveBaseUrl}/upload_profile_image.php'),
      );

      request.fields['user_id'] = userId.toString();

      // Handle different image types
      if (imageFile is File) {
        // For mobile/desktop - use file path
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imageFile.path),
        );
      } else if (imageFile is Uint8List) {
        // For web - use bytes with proper extension detection
        String filename = 'profile_image.jpg'; // default

        // Simple format detection based on file header
        if (imageFile.length >= 4) {
          // JPEG files start with FF D8 FF
          if (imageFile[0] == 0xFF &&
              imageFile[1] == 0xD8 &&
              imageFile[2] == 0xFF) {
            filename = 'profile_image.jpg';
          }
          // PNG files start with 89 50 4E 47
          else if (imageFile[0] == 0x89 &&
              imageFile[1] == 0x50 &&
              imageFile[2] == 0x4E &&
              imageFile[3] == 0x47) {
            filename = 'profile_image.png';
          }
          // GIF files start with 47 49 46 38
          else if (imageFile[0] == 0x47 &&
              imageFile[1] == 0x49 &&
              imageFile[2] == 0x46 &&
              imageFile[3] == 0x38) {
            filename = 'profile_image.gif';
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
        throw Exception('Invalid image type');
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload response status: ${response.statusCode}');
      print('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          if (response.body.isEmpty) {
            throw Exception('Empty response from server');
          }
          return json.decode(response.body);
        } catch (e) {
          print('JSON decode error: $e');
          print('Response body: ${response.body}');
          throw Exception('Invalid server response: ${e.toString()}');
        }
      } else {
        print(
          'Server responded with status ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'HTTP Error: ${response.statusCode}, Response: ${response.body}',
        );
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
}
