import 'package:flutter/material.dart'; // Mengimport paket UI dasar Flutter
import 'package:animate_do/animate_do.dart'; // Mengimport paket animasi widget
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport paket untuk simpan data lokal sederhana
import '../services/api_service.dart'; // Mengimport layanan API
import 'register_page.dart'; // Mengimport halaman pendaftaran
import 'reset_password_page.dart'; // Mengimport halaman lupa password
import 'dashboard_page.dart'; // Mengimport halaman dashboard utama

// Kelas halaman login sebagai StatefulWidget
class LoginPage extends StatefulWidget {
  @override
  // Membuat state untuk halaman login
  _LoginPageState createState() => _LoginPageState();
}

// State class untuk LoginPage yang menampung logika login
class _LoginPageState extends State<LoginPage> {
  final _emailController =
      TextEditingController(); // Controller untuk input email
  final _passwordController =
      TextEditingController(); // Controller untuk input password
  final _apiService = ApiService(); // Instansiasi layanan API
  bool _isLoading = false; // Status loading saat proses login
  bool _obscurePassword =
      true; // Status untuk menyembunyikan/menampilkan password

  // Fungsi untuk menjalankan proses login
  void _login() async {
    // Validasi input email dan password tidak boleh kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true); // Set status loading jadi true
    try {
      // Memanggil fungsi login dari API Service
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Jika login berhasil
      if (response['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        // Simpan data user ke dalam SharedPreferences (penyimpanan lokal)
        await prefs.setInt(
          'user_id',
          int.parse(response['user_id'].toString()),
        );
        if (response['name'] != null)
          await prefs.setString('name', response['name']);
        if (response['email'] != null)
          await prefs.setString('email', response['email']);
        if (response['profile_image'] != null)
          await prefs.setString('profile_image', response['profile_image']);

        // Pindah ke halaman Dashboard dan hapus history halaman sebelumnya
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        // Tampilkan error jika status bukan success
        _showError(response['message']);
      }
    } catch (e) {
      // Tampilkan error jika terjadi kegagalan sistem/jaringan
      _showError(e.toString());
    } finally {
      // Set status loading kembali ke false setelah proses selesai
      setState(() => _isLoading = false);
    }
  }

  // Fungsi pembantu untuk menampilkan dialog pesan error
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Login Gagal'),
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
  // Membangun tampilan UI halaman login
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Agar halaman bisa discroll saat keyboard muncul
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            // Memberikan efek gradasi pada latar belakang
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animasi ikon jatuh dari atas
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Animasi teks judul
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                // Deskripsi singkat aplikasi
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Kelola keuanganmu dengan mudah di Catatuang',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 50),
                // Input field untuk Email
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
                // Input field untuk Password dengan tombol lihat/sembunyi
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
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
                          // Toggle status visibilitas password
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Tombol navigasi Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordPage(),
                        ),
                      ),
                      child: Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Tombol login atau loader jika sedang memproses
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text(
                            'MASUK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                // Link ke halaman pendaftaran (Register)
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        ),
                        child: Text(
                          'Daftar Sekarang',
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
      ),
    );
  }
}
