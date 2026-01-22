import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'package:flutter/foundation.dart'; // Mengimport utilitas dasar Flutter (seperti kIsWeb)
import 'package:animate_do/animate_do.dart'; // Mengimport library animasi widget
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport penyimpanan lokal sederhana
import 'package:image_picker/image_picker.dart'; // Mengimport pengambil gambar dari galeri/kamera
import 'package:google_fonts/google_fonts.dart'; // Mengimport paket Google Fonts
import 'dart:io'; // Mengimport library input/output sistem (untuk File)
import '../services/api_service.dart'; // Mengimport layanan API yang telah dibuat
import '../services/api_config.dart'; // Mengimport konfigurasi API (seperti normalisasi URL)
import 'login_page.dart'; // Mengimport halaman login untuk proses logout

// Kelas utama halaman Profil sebagai StatefulWidget
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  // Membuat state untuk halaman profil
  State<ProfilPage> createState() => _ProfilPageState();
}

// State class untuk mengelola data dan logika profil user
class _ProfilPageState extends State<ProfilPage> {
  final _apiService = ApiService(); // Instansiasi layanan API
  final _nameController =
      TextEditingController(); // Controller untuk input nama
  final _emailController =
      TextEditingController(); // Controller untuk input email
  final ImagePicker _imagePicker =
      ImagePicker(); // Instansiasi pengambil gambar
  int _userId = 0; // Menyimpan ID user
  bool _isLoading = false; // Status loading proses update
  File? _profileImage; // Menyimpan file gambar profil (untuk mobile)
  String? _profileImageUrl; // Menyimpan URL gambar profil dari server
  Uint8List?
  _webImageBytes; // Menyimpan bytes gambar profil (khusus untuk platform web)

  @override
  // Fungsi yang dijalankan saat widget pertama kali dibuat
  void initState() {
    super.initState();
    _loadProfile(); // Memuat data profil dari memori lokal
  }

  // Fungsi untuk mengambil data profil yang tersimpan di SharedPreferences
  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getInt('user_id') ?? 0;
        _nameController.text = prefs.getString('name') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _profileImageUrl = prefs.getString(
          'profile_image',
        ); // Mengambil URL gambar tersimpan
        // Log debug untuk memantau data yang dimuat
        print('DEBUG: Loaded profile image URL: $_profileImageUrl');
        print('DEBUG: User ID: $_userId');
        print('DEBUG: Name: ${_nameController.text}');
        print('DEBUG: Email: ${_emailController.text}');
      });
    }
  }

  // Fungsi asinkron untuk mengambil gambar dari galeri ponsel/browser
  Future<void> _pickImage() async {
    try {
      // Pengecekan apakah aplikasi berjalan di platform Web
      if (kIsWeb) {
        // Penanganan khusus untuk Web
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          print('DEBUG: Web image picked: ${pickedFile.name}');
          // Membaca bytes gambar karena Web tidak mendukung path file lokal secara langsung
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _profileImage = null; // Web tidak menggunakan objek File
            _webImageBytes = bytes; // Simpan bytes untuk ditampilkan di UI
          });

          // Notifikasi berhasil memilih gambar di Web
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gambar berhasil dipilih (Web)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        // Penanganan untuk platform Mobile (Android/iOS)
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          print('DEBUG: Image picked: ${pickedFile.path}');
          setState(() {
            _profileImage = File(pickedFile.path); // Simpan sebagai objek File
          });
        }
      }
    } catch (e) {
      // Penanganan error saat mengambil gambar
      print('DEBUG: Error picking image: $e');
      String errorMessage = 'Gagal mengambil gambar: ${e.toString()}';

      // Pesan error spesifik jika plugin bermasalah atau izin ditolak
      if (e.toString().contains('MissingPluginException')) {
        errorMessage = 'Plugin image picker tidak terkonfigurasi dengan benar.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Izin ditolak. Silakan berikan izin akses kamera/galeri.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Fungsi untuk mengirim perubahan profil ke server
  void _updateProfile() async {
    setState(() => _isLoading = true); // Mulai loading
    try {
      print('DEBUG: Starting profile update');

      // Proses upload gambar jika user memilih gambar baru
      if (_profileImage != null || _webImageBytes != null) {
        print('DEBUG: Uploading profile image...');
        // Memanggil API upload gambar (mengirim file atau bytes)
        final imageResponse = await _apiService.uploadProfileImage(
          _userId,
          _profileImage ?? _webImageBytes,
        );
        print('DEBUG: Image upload response: $imageResponse');

        if (imageResponse['status'] == 'success') {
          final newImageUrl = imageResponse['image_url'];

          // Simpan URL gambar baru ke penyimpanan lokal
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image', newImageUrl!);
          print('DEBUG: Image URL saved to preferences: $newImageUrl');

          if (mounted) {
            setState(() {
              _profileImageUrl =
                  newImageUrl; // Update tampilan dengan gambar baru
            });
          }
        } else {
          throw Exception(
            imageResponse['message'] ?? 'Gagal mengupload gambar',
          );
        }
      }

      // Proses update data teks (nama dan email)
      print('DEBUG: Updating profile data...');
      final response = await _apiService.updateProfile(
        _userId,
        _nameController.text,
        _emailController.text,
      );
      print('DEBUG: Profile update response: $response');

      if (response['status'] == 'success') {
        // Simpan data terbaru ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', _nameController.text);
        await prefs.setString('email', _emailController.text);

        // Sinkronisasi data profile_image dari balasan server
        if (response['profile_image'] != null) {
          await prefs.setString('profile_image', response['profile_image']);
        }

        if (mounted) {
          setState(() {
            _loadProfile(); // Muat ulang data profil terbaru
          });
        }

        // Tampilkan pesan sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      // Penanganan error saat proses update
      print('DEBUG: Error in profile update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Hentikan loading
    }
  }

  // Fungsi pembantu untuk membuat placeholder jika gambar gagal dimuat atau tidak ada
  Widget _buildImagePlaceholder({
    required IconData icon,
    required String label,
    String? sublabel,
  }) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sublabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sublabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.redAccent),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  @override
  // Membangun tampilan utama halaman profil
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF0F4F8,
      ), // Latar belakang abu kebiruan lembut
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // Bagian Header dengan Gradasi Warna
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary, // Warna utama
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Profil Saya', // Judul halaman
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola informasi pribadi Anda', // Sub-judul
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Bagian Foto Profil yang bisa diklik untuk ganti gambar
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage, // Picu fungsi pilih gambar
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[100],
                            child: ClipOval(
                              // Memilih tampilan gambar berdasarkan prioritas (file baru > bytes web > url server)
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : _webImageBytes != null
                                  ? Image.memory(
                                      _webImageBytes!,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : (_profileImageUrl != null &&
                                        _profileImageUrl!.isNotEmpty)
                                  ? Image.network(
                                      // Tambahkan timestamp di URL agar gambar tidak kena cache saat di-update
                                      '${ApiConfig.normalizeUrl(_profileImageUrl!)}&v=${DateTime.now().millisecondsSinceEpoch}',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child; // Selesai muat
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildImagePlaceholder(
                                              icon: Icons.broken_image_rounded,
                                              label: 'Error',
                                              sublabel: 'Gagal memuat',
                                            );
                                          },
                                    )
                                  : _buildImagePlaceholder(
                                      icon: Icons.person_rounded,
                                      label: 'No Image',
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menampilkan ID user di bawah foto jika ada gambar
                  if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'ID Profil: $_userId',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Kartu Informasi Personal
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Informasi Personal',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Tampilan Nama Lengkap
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                    : 'Nama Lengkap',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: _nameController.text.isNotEmpty
                                      ? const Color(0xFF2D3748)
                                      : const Color(0xFFA0AEC0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tampilan Email Address
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _emailController.text.isNotEmpty
                                    ? _emailController.text
                                    : 'Alamat Email',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: _emailController.text.isNotEmpty
                                      ? const Color(0xFF2D3748)
                                      : const Color(0xFFA0AEC0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Simpan Perubahan
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _updateProfile, // Panggil fungsi update
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol Keluar dari Akun
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () async {
                    // Dialog konfirmasi sebelum keluar
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false), // Tutup dialog
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true), // Setujui logout
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs
                          .clear(); // Hapus semua data login dari memori lokal
                      if (mounted) {
                        // Kembali ke halaman login dan hapus tumpukan navigasi
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
