import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'package:animate_do/animate_do.dart'; // Mengimport library untuk animasi widget
import '../services/api_service.dart'; // Mengimport layanan API yang telah dibuat

// Kelas halaman Reset Password sebagai StatefulWidget
class ResetPasswordPage extends StatefulWidget {
  @override
  // Membuat state untuk halaman reset password
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

// State class untuk mengampu logika pengaturan ulang password
class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController =
      TextEditingController(); // Controller untuk input email
  final _passwordController =
      TextEditingController(); // Controller untuk input password baru
  final _apiService = ApiService(); // Instansiasi layanan API
  bool _isLoading = false; // Status loading saat proses perubahan password
  bool _obscurePassword = true; // Status untuk sembunyi/tampilkan password baru

  // Fungsi untuk menjalankan proses pengaturan ulang password ke server
  void _resetPassword() async {
    // Validasi: email dan password baru tidak boleh kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password baru harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai status loading
    try {
      // Memanggil fungsi resetPassword dari layanan API
      final response = await _apiService.resetPassword(
        _emailController.text,
        _passwordController.text,
      );

      // Jika proses berhasil
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui'),
            backgroundColor: Colors.green, // Notifikasi sukses warna hijau
          ),
        );
        Navigator.pop(context); // Kembali ke halaman login
      } else {
        // Tampilkan pesan kesalahan dari server
        _showError(response['message']);
      }
    } catch (e) {
      // Penanganan jika ada gangguan jaringan
      _showError('Terjadi kesalahan koneksi');
    } finally {
      // Selesaikan status loading jika widget masih aktif di layar
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi pembantu untuk memunculkan kotak pesan error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  // Membangun tampilan antarmuka halaman reset password
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Transparan agar senada dengan background
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ), // Tombol back gaya iOS
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Animasi judul halaman
            FadeInDown(
              child: Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            // Instruksi singkat bagi pengguna
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Masukkan email terdaftar untuk memperbarui password Anda.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            // Input Field: Email terdaftar
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email Terdaftar',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Input Field: Password baru dengan filter sensor
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password Baru',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      // Toggle menekan ikon mata untuk melihat password
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            // Tombol Update atau animasi loading
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _resetPassword, // Panggil fungsi reset
                      child: const Text(
                        'UPDATE PASSWORD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
