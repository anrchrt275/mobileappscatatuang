import 'package:flutter/material.dart'; // Mengimport library dasar UI Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport library untuk penyimpanan data lokal
import 'package:intl/intl.dart'; // Mengimport library untuk format angka dan tanggal
import 'package:animate_do/animate_do.dart'; // Mengimport library untuk animasi widget
import '../services/api_service.dart'; // Mengimport layanan API yang telah dibuat
import '../models/transaction.dart'; // Mengimport model data transaksi
import 'transaksi_page.dart'; // Mengimport halaman transaksi untuk navigasi

// Kelas DashboardView sebagai StatefulWidget untuk tampilan beranda
class DashboardView extends StatefulWidget {
  @override
  // Inisialisasi state untuk DashboardView
  _DashboardViewState createState() => _DashboardViewState();
}

// State class yang menampung logika tampilan dashboard
class _DashboardViewState extends State<DashboardView> {
  final _apiService = ApiService(); // Instansiasi layanan API
  double _saldo = 0; // Variabel penyimpan total saldo
  double _pemasukan = 0; // Variabel penyimpan total pemasukan
  double _pengeluaran = 0; // Variabel penyimpan total pengeluaran
  bool _isSaldoVisible =
      true; // Status visibilitas nominal saldo (mata terbuka/tertutup)
  bool _isLoading = true; // Status loading saat mengambil data
  List<Transaction> _recentTransactions =
      []; // List penyimpan transaksi terbaru

  @override
  // Fungsi yang dipanggil saat widget pertama kali dibuat
  void initState() {
    super.initState(); // Memanggil fungsi init super class
    _loadData(); // Memanggil fungsi untuk memuat data dari memori dan API
  }

  // Fungsi untuk memuat semua data yang dibutuhkan dashboard
  void _loadData() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan akses shared preferences
    final userId = prefs.getInt('user_id') ?? 0; // Mengambil user ID, default 0
    final isVisible =
        prefs.getBool('is_saldo_visible') ??
        true; // Mengambil status visibilitas saldo

    if (mounted) {
      setState(() {
        _isSaldoVisible = isVisible; // Update status visibilitas saldo di UI
      });
    }

    try {
      // Memanggil API untuk mendapatkan statistik dashboard (saldo, in, out)
      final stats = await _apiService.getDashboardStats(userId);

      // Memanggil API untuk mendapatkan daftar transaksi user
      final transactions = await _apiService.getTransactions(userId);

      if (mounted) {
        setState(() {
          // Parsing data statistik dari API ke tipe double
          _saldo = _parseDouble(stats['saldo']?.toString() ?? '0');
          _pemasukan = _parseDouble(stats['pemasukan']?.toString() ?? '0');
          _pengeluaran = _parseDouble(stats['pengeluaran']?.toString() ?? '0');
          // Mengambil hanya 3 transaksi terakhir untuk ditampilkan
          _recentTransactions = transactions.take(3).toList();
          _isLoading = false; // Mematikan status loading
        });
      }
    } catch (e) {
      if (mounted)
        setState(() => _isLoading = false); // Jika error, tetap matikan loading
    }
  }

  // Fungsi pembantu untuk mengubah string ke double dengan penanganan error
  double _parseDouble(String value) {
    try {
      return double.parse(value); // Mencoba konversi string ke double
    } catch (e) {
      print('Error parsing double: $value, error: $e'); // Cetak error ke konsol
      return 0.0; // Kembalikan 0 jika gagal
    }
  }

  // Format mata uang Rupiah Indonesia
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  // Membangun tampilan UI
  Widget build(BuildContext context) {
    // Menampilkan loading spinner jika data masih dimuat
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () async =>
          _loadData(), // Fungsi refresh saat ditarik ke bawah
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20,
        ), // Jarak di sekeliling konten
        children: [
          // Widget Kartu Saldo dengan animasi jatuh dari atas
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24), // Jarak dalam kartu
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary, // Warna utama tema
                    Theme.of(
                      context,
                    ).colorScheme.secondary, // Warna sekunder tema
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  24,
                ), // Sudut melengkung kartu
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                      0.3,
                    ), // Bayangan warna biru tipis
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Total Saldo', // Teks label saldo
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8), // Jarak horizontal
                              GestureDetector(
                                onTap: () async {
                                  // Merubah status visibilitas saldo saat ikon mata ditekan
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    _isSaldoVisible =
                                        !_isSaldoVisible; // Toggle status
                                    prefs.setBool(
                                      'is_saldo_visible', // Simpan pilihan user
                                      _isSaldoVisible,
                                    );
                                  });
                                },
                                // Ikon mata (lihat/sembunyi)
                                child: Icon(
                                  _isSaldoVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          // Menampilkan nominal saldo atau titik-titik jika disembunyikan
                          Text(
                            _isSaldoVisible
                                ? currencyFormat.format(_saldo)
                                : 'Rp ••••••••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Ikon dompet di pojok kanan atas kartu
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.2,
                          ), // Latar transparan putih
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wallet,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Jarak vertikal
                  const Divider(color: Colors.white24), // Garis pembatas tipis
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          // Baris kartu Statistik (Pemasukan & Pengeluaran)
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  // Memanggil fungsi pembuat kartu pemasukan
                  child: _buildStatCard(
                    'Pemasukan',
                    _pemasukan,
                    Colors.green,
                    Icons.arrow_upward_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: FadeInRight(
                  delay: const Duration(milliseconds: 200),
                  // Memanggil fungsi pembuat kartu pengeluaran
                  child: _buildStatCard(
                    'Pengeluaran',
                    _pengeluaran,
                    Colors.red,
                    Icons.arrow_downward_rounded,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Judul bagian aktivitas terakhir
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Tombol navigasi ke semua transaksi
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TransaksiPage()),
                    );
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
          ),
          // Daftar transaksi terbaru
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Column(
              children: [
                // Menampilkan label kosong jika tidak ada transaksi
                ..._recentTransactions.isEmpty
                    ? [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: const ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFFE0F2FE),
                              child: Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF0EA5E9),
                              ),
                            ),
                            title: Text('Belum ada transaksi'),
                            subtitle: Text('Tambahkan transaksi pertama kamu!'),
                          ),
                        ),
                      ]
                    // Loop untuk menampilkan list transaksi jika ada
                    : _recentTransactions.asMap().entries.map((entry) {
                        final index = entry.key; // Index urutan
                        final t = entry.value; // Data transaksi
                        final isPemasukan =
                            t.type == 'income'; // Cek apakah pemasukan
                        final isPengeluaran =
                            t.type == 'expense'; // Cek apakah pengeluaran

                        return FadeInUp(
                          delay: Duration(
                            milliseconds: 500 + (index * 100),
                          ), // Animasi berurutan
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: Colors.white,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      (isPemasukan
                                              ? Colors.green
                                              : isPengeluaran
                                              ? Colors.red
                                              : Colors.grey)
                                          .withOpacity(
                                            0.1,
                                          ), // Background warna tipis
                                  shape: BoxShape.circle,
                                ),
                                // Ikon tambah atau kurang sesuai tipe transaksi
                                child: Icon(
                                  isPemasukan
                                      ? Icons.add_rounded
                                      : isPengeluaran
                                      ? Icons.remove_rounded
                                      : Icons.help_outline,
                                  color: isPemasukan
                                      ? Colors.green
                                      : isPengeluaran
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              // Catatan transaksi atau jenis transaksi jika catatan kosong
                              title: Text(
                                t.note.isEmpty
                                    ? (isPemasukan
                                          ? 'Pemasukan'
                                          : isPengeluaran
                                          ? 'Pengeluaran'
                                          : 'Tidak Diketahui')
                                    : t.note,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              // Waktu pembuatan transaksi
                              subtitle: Text(
                                DateFormat('dd MMM, HH:mm').format(t.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              // Nominal transaksi (pendaran nominal sesuai status visibility)
                              trailing: Text(
                                _isSaldoVisible
                                    ? (isPemasukan
                                          ? '+ ${currencyFormat.format(t.amount)}'
                                          : isPengeluaran
                                          ? '- ${currencyFormat.format(t.amount)}'
                                          : '? ${currencyFormat.format(t.amount)}')
                                    : '•••••',
                                style: TextStyle(
                                  color: isPemasukan
                                      ? Colors.green
                                      : isPengeluaran
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi widget untuk membuat kartu statistik (pemasukan/pengeluaran)
  Widget _buildStatCard(
    String title, // Judul kartu
    double amount, // Jumlah uang
    Color color, // Warna aksen
    IconData icon, // Ikon indikator
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Bayangan lembut
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ikon kecil dengan latar belakang bulat
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              // Judul kartu statistik
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nominal statistik
          FittedBox(
            child: Text(
              _isSaldoVisible ? currencyFormat.format(amount) : 'Rp •••••',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
