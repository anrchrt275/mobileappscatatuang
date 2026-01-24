import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'package:google_fonts/google_fonts.dart'; // Mengimport paket Google Fonts untuk tipografi kustom
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport library untuk penyimpanan data lokal
import 'pages/login_page.dart'; // Mengimport halaman login
import 'pages/dashboard_page.dart'; // Mengimport halaman dashboard utama

// Fungsi utama yang dijalankan pertama kali saat aplikasi dimulai
void main() async {
  // Memastikan inisialisasi widget Flutter sudah siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Membuka instance SharedPreferences untuk memeriksa status login
  final prefs = await SharedPreferences.getInstance();
  // Mengambil user_id; jika ada, berarti pengguna sudah login
  final int? userId = prefs.getInt('user_id');

  // Menjalankan aplikasi utama dengan mengirimkan status login
  runApp(MyApp(isLoggedIn: userId != null));
}

// Kelas root aplikasi sebagai StatelessWidget
class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  // Konstruktor untuk menerima status login dari fungsi main
  MyApp({required this.isLoggedIn});

  @override
  // Membangun struktur dasar aplikasi menggunakan MaterialApp
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CATATUANG', // Judul aplikasi
      debugShowCheckedModeBanner:
          false, // Menghilangkan banner "DEBUG" di pojok aplikasi
      // Konfigurasi Tema (Theme) aplikasi secara global
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF0EA5E9),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        // Smooth page transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),

        // Mengatur font default menggunakan Google Fonts Plus Jakarta Sans
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),

        // Tema global untuk Semua Tombol ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFF6366F1,
            ), // Latar tombol biru indigo
            foregroundColor: Colors.white, // Warna teks tombol putih
            minimumSize: const Size(
              double.infinity,
              56,
            ), // Ukuran tombol lebar penuh
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
        ),

        // Tema global untuk Semua Inputan Teks (TextField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Latar belakang input putih
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),

      // Menentukan halaman pertama yang muncul berdasarkan status login
      home: isLoggedIn ? DashboardPage() : LoginPage(),
    );
  }
}
