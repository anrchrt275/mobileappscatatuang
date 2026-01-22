import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport library untuk penyimpanan data lokal
import 'package:intl/intl.dart'; // Mengimport library untuk pemformatan tanggal dan waktu
import 'package:animate_do/animate_do.dart'; // Mengimport library untuk animasi widget
import '../services/api_service.dart'; // Mengimport layanan API yang telah disediakan
import '../models/message.dart'; // Mengimport model data pesan notifikasi

// Kelas halaman Notifikasi sebagai StatefulWidget
class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key}); // Konstruktor halaman

  @override
  // Membuat state untuk halaman notifikasi
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

// State class untuk mengelola data notifikasi
class _NotifikasiPageState extends State<NotifikasiPage> {
  final _apiService = ApiService(); // Instansiasi layanan API
  List<NotificationMessage> _messages =
      []; // List untuk menampung pesan notifikasi dari server
  bool _isLoading = true; // Status loading saat data sedang diambil

  @override
  // Fungsi yang dipanggil saat widget pertama kali diinisialisasi
  void initState() {
    super.initState();
    _loadMessages(); // Langsung memuat pesan saat halaman dibuka
  }

  // Fungsi asinkron untuk mengambil data pesan dari API
  void _loadMessages() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance penyimpanan lokal
    final userId =
        prefs.getInt('user_id') ??
        0; // Mengambil user ID, default 0 jika tidak ada
    try {
      final data = await _apiService.getMessages(
        userId,
      ); // Meminta daftar pesan dari API
      if (mounted) {
        setState(() {
          // Membalikkan urutan list agar notifikasi terbaru muncul di paling atas
          _messages = data.reversed.toList();
          _isLoading = false; // Mematikan status loading
        });
      }
    } catch (e) {
      if (mounted)
        setState(() => _isLoading = false); // Jika error, tetap matikan loading
    }
  }

  // Fungsi pembantu untuk menentukan ikon berdasarkan isi judul notifikasi
  IconData _getNotificationIcon(String title) {
    if (title.toLowerCase().contains('profil')) {
      return Icons.person; // Ikon profil
    } else if (title.toLowerCase().contains('password')) {
      return Icons.lock; // Ikon gembok untuk password
    } else if (title.toLowerCase().contains('transaksi')) {
      return Icons.receipt_long; // Ikon struk untuk transaksi
    } else {
      return Icons.notifications; // Ikon notifikasi umum
    }
  }

  @override
  // Membangun tampilan utama halaman notifikasi
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Warna latar belakang halaman biru sangat muda
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Tampilkan loading spinner jika sedang mengambil data
          : RefreshIndicator(
              onRefresh: () async =>
                  _loadMessages(), // Fungsi refresh saat ditarik ke bawah
              child: _messages.isEmpty
                  ? Center(
                      // Tampilan jika tidak ada pesan sama sekali
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada notifikasi',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      // Membangun daftar pesan secara dinamis
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final m = _messages[index]; // Ambil data tiap item
                        return FadeInUp(
                          // Animasi muncul dari bawah ke atas
                          delay: Duration(
                            milliseconds:
                                100 *
                                (index > 10
                                    ? 10
                                    : index), // Delay animasi bertahap
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              // Bagian kiri: Ikon dalam lingkaran berwarna transparan
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getNotificationIcon(
                                    m.title,
                                  ), // Memanggil fungsi pencocokan ikon
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // Warna ikon sesuai tema utama
                                  size: 20,
                                ),
                              ),
                              // Bagian tengah atas: Judul pesan (tebal)
                              title: Text(
                                m.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              // Bagian tengah bawah: Isi/konten pesan
                              subtitle: Text(
                                m.content,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              // Bagian paling kanan: Tanggal pesan dikirim
                              trailing: Text(
                                DateFormat('dd MMM').format(m.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
