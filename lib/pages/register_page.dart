import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'package:animate_do/animate_do.dart'; // Mengimport library untuk animasi widget
import '../services/api_service.dart'; // Mengimport layanan API yang telah dibuat

// Kelas halaman Registrasi sebagai StatefulWidget
class RegisterPage extends StatefulWidget {
  @override
  // Membuat state untuk halaman registrasi
  _RegisterPageState createState() => _RegisterPageState();
}

// State class untuk mengelola logika pendaftaran akun baru
class _RegisterPageState extends State<RegisterPage> {
  final _nameController =
      TextEditingController(); // Controller untuk input nama lengkap
  final _emailController =
      TextEditingController(); // Controller untuk input email
  final _passwordController =
      TextEditingController(); // Controller untuk input password
  final _apiService = ApiService(); // Instansiasi layanan API
  bool _isLoading = false; // Status loading saat proses pendaftaran berlangsung
  bool _obscurePassword = true; // Status untuk sembunyi/tampilkan password

  // Fungsi untuk menjalankan proses registrasi ke server
  void _register() async {
    // Validasi: pastikan semua field input telah diisi
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    setState(() => _isLoading = true); // Set status loading menjadi aktif
    try {
      // Memanggil fungsi registrasi dari layanan API
      final response = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      // Jika pendaftaran berhasil (status success)
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dibuat! Silakan login.'),
            backgroundColor:
                Colors.green, // Warna hijau untuk notifikasi sukses
          ),
        );
        Navigator.pop(context); // Kembali ke halaman login
      } else {
        // Jika gagal dari sisi server, tampilkan pesan error dari server
        _showError(response['message']);
      }
    } catch (e) {
      // Penanganan error jika terjadi masalah jaringan atau sistem
      _showError('Terjadi kesalahan koneksi');
    } finally {
      // Set status loading kembali ke false apa pun hasilnya
      setState(() => _isLoading = false);
    }
  }

  // Fungsi pembantu untuk menampilkan dialog pesan kesalahan
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Registrasi Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  // Membangun tampilan UI halaman registrasi
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Background app bar transparan
        elevation: 0, // Tanpa bayangan
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
          ), // Tombol kembali gaya iOS
          onPressed: () =>
              Navigator.pop(context), // Kembali ke halaman sebelumnya
        ),
      ),
      body: SingleChildScrollView(
        // Bungkus dengan scroll agar tidak terpotong saat keyboard muncul
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Animasi judul halaman jatuh dari atas
              FadeInDown(
                child: Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              // Animasi deskripsi singkat
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Bergabunglah dan mulai catat keuanganmu!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 40),
              // Input Field: Nama Lengkap
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Input Field: Email
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Input Field: Password dengan fitur sembunyi/tampilkan
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Status sensor password
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Merubah status visibilitas password
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // Tombol Daftar atau Loader
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      ) // Loader saat sedang mendaftar
                    : ElevatedButton(
                        onPressed: _register, // Trigger fungsi registrasi
                        child: const Text(
                          'DAFTAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              // Navigasi bawah untuk pengguna yang sudah punya akun
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context), // Kembali ke login
                      child: Text(
                        'MASUK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
