import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport library untuk penyimpanan data lokal
import 'package:intl/intl.dart'; // Mengimport library untuk format mata uang dan tanggal
import 'package:animate_do/animate_do.dart'; // Mengimport library untuk animasi UI
import '../services/api_service.dart'; // Mengimport layanan API
import '../models/transaction.dart'; // Mengimport model data transaksi

// Kelas halaman Transaksi sebagai StatefulWidget
class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  // Membuat state untuk halaman transaksi
  _TransaksiPageState createState() => _TransaksiPageState();
}

// State class dengan WidgetsBindingObserver untuk memantau status aplikasi
class _TransaksiPageState extends State<TransaksiPage>
    with WidgetsBindingObserver {
  final _apiService = ApiService(); // Instansiasi layanan API
  final _amountController =
      TextEditingController(); // Controller untuk input nominal uang
  final _noteController =
      TextEditingController(); // Controller untuk input catatan transaksi
  String _type =
      'income'; // Menentukan jenis transaksi (income/expense), default income
  List<Transaction> _transactions = []; // List untuk menyimpan daftar transaksi
  bool _isLoading = true; // Status loading saat data sedang dimuat
  double _totalPemasukan = 0.0; // Menyimpan total uang masuk
  double _totalPengeluaran = 0.0; // Menyimpan total uang keluar

  @override
  // Fungsi inisialisasi state awal
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      this,
    ); // Menambahkan observer status aplikasi
    _loadTransactions(); // Memuat data transaksi dari server
  }

  @override
  // Fungsi pembersihan saat widget dihancurkan
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Menghapus observer
    _amountController.dispose(); // Menghapus controller nominal
    _noteController.dispose(); // Menghapus controller catatan
    super.dispose();
  }

  @override
  // Fungsi yang dipicu saat status lifecycle aplikasi berubah (misal: kembali dari background)
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //Refresh data saat aplikasi kembali aktif di layar depan
      _loadTransactions();
    }
  }

  // Fungsi asinkron untuk memuat data transaksi dan statistik dari API
  void _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0; // Mengambil user ID yang aktif
    print('DEBUG: Loading transactions for user_id: $userId');

    try {
      // Mengambil daftar transaksi lewat API
      final data = await _apiService.getTransactions(userId);
      print('DEBUG: Got ${data.length} transactions');

      // Mengambil ringkasan statistik (in/out) lewat API
      final stats = await _apiService.getDashboardStats(userId);
      print('DEBUG: Got stats: $stats');

      if (mounted) {
        setState(() {
          _transactions = data.reversed
              .toList(); // Urutkan dari yang terbaru (dibalik)
          // Parsing nilai statistik dari server ke tipe data double
          _totalPemasukan = _parseDouble(stats['pemasukan']?.toString() ?? '0');
          _totalPengeluaran = _parseDouble(
            stats['pengeluaran']?.toString() ?? '0',
          );
          _isLoading = false; // Matikan status loading
        });
      }
    } catch (e) {
      print('DEBUG: Error loading transactions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi pembantu untuk konversi string ke double dengan aman
  double _parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      print('Error parsing double: $value, error: $e');
      return 0.0; // Kembalikan 0 jika gagal konversi
    }
  }

  // Fungsi untuk mengirim data transaksi baru ke server
  void _addTransaction() async {
    // Validasi input nominal tidak boleh kosong
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jumlah harus diisi')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    print('DEBUG: Adding transaction for user_id: $userId');

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User tidak valid, silakan login kembali'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Memanggil API tambah transaksi
      final response = await _apiService.addTransaction(
        userId,
        _type,
        double.parse(_amountController.text),
        _noteController.text.isEmpty ? '' : _noteController.text,
      );

      print('DEBUG: Add transaction response: $response');

      if (response['status'] == 'success') {
        // Jika berhasil, tampilkan notifikasi hijau
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        _amountController.clear(); // Kosongkan input
        _noteController.clear(); // Kosongkan catatan
        Navigator.pop(context); // Tutup bottom sheet tambah transaksi

        // Refresh data setelah jeda singkat agar API sempat memproses
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadTransactions();
          }
        });
      } else {
        // Tampilkan pesan gagal jika respons bukan success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menambahkan transaksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error adding transaction: $e');
    }
  }

  // Fungsi untuk memperbarui data transaksi yang sudah ada
  void _updateTransaction(int transactionId) async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jumlah harus diisi')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      final response = await _apiService.updateTransaction(
        transactionId,
        userId,
        _type,
        double.parse(_amountController.text),
        _noteController.text,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        _amountController.clear();
        _noteController.clear();
        Navigator.pop(context);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadTransactions();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal memperbarui transaksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menghapus transaksi
  void _deleteTransaction(int transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      final response = await _apiService.deleteTransaction(
        transactionId,
        userId,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTransactions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menghapus transaksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Dialog konfirmasi sebelum menghapus
  void _showDeleteConfirmation(int transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Tutup bottom sheet
              _deleteTransaction(transactionId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Format standar mata uang Rupiah
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  // Fungsi widget pembuat kartu statistik (untuk pemasukan/pengeluaran)
  Widget _buildStatCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            // Menampilkan nominal dengan format Rupiah
            child: Text(
              currencyFormat.format(amount),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Menampilkan lembar input (Bottom Sheet) untuk tambah transaksi
  void _showAddTransactionSheet() {
    _amountController.clear();
    _noteController.clear();
    setState(() => _type = 'income');

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Membuat sheet bisa menjulang saat keyboard muncul
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Transaksi Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Input nominal uang
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  hintText: 'Jumlah (Rp)',
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number, // Keyboard angka saja
              ),
              const SizedBox(height: 15),
              // Input catatan opsional
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Catatan/Keterangan',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 15),
              // Baris pemilihan tipe: Pemasukan atau Pengeluaran
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setStateSheet(() => _type = 'income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 'income'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _type == 'income'
                                ? Colors.green
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              color: _type == 'income'
                                  ? Colors.green
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () => setStateSheet(() => _type = 'expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 'expense'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _type == 'expense'
                                ? Colors.red
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              color: _type == 'expense'
                                  ? Colors.red
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Tombol aksi simpan
              ElevatedButton(
                onPressed: _addTransaction,
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Menampilkan lembar input (Bottom Sheet) untuk edit transaksi
  void _showEditTransactionSheet(Transaction t) {
    _amountController.text = t.amount.toString();
    _noteController.text = t.note;
    setState(() => _type = t.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Transaksi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  hintText: 'Jumlah (Rp)',
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Catatan/Keterangan',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setStateSheet(() => _type = 'income'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 'income'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _type == 'income'
                                ? Colors.green
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              color: _type == 'income'
                                  ? Colors.green
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () => setStateSheet(() => _type = 'expense'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _type == 'expense'
                              ? Colors.red.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _type == 'expense'
                                ? Colors.red
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              color: _type == 'expense'
                                  ? Colors.red
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _updateTransaction(t.id),
                child: const Text(
                  'Perbarui Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              // Tombol Hapus
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(t.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Hapus Transaksi',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // Membangun tampilan utama halaman daftar transaksi
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Tombol refresh manual
              setState(() => _isLoading = true);
              _loadTransactions();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Tampilkan loader jika data sedang dimuat
          : _transactions.isEmpty
          ? Center(
              // Tampilan jika data transaksi kosong
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan transaksi pertama kamu!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  _loadTransactions(), // Tarik ke bawah untuk refresh
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Menampilkan Kartu Statistik Pemasukan & Pengeluaran
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Pemasukan',
                            _totalPemasukan,
                            Colors.green,
                            Icons.arrow_upward_rounded,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatCard(
                            'Pengeluaran',
                            _totalPengeluaran,
                            Colors.red,
                            Icons.arrow_downward_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Membangun daftar riwayat transaksi
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final t = _transactions[index];
                        final isPemasukan = t.type == 'income';
                        final isPengeluaran = t.type == 'expense';
                        return FadeInUp(
                          // Animasi kemunculan item dari bawah
                          delay: Duration(
                            milliseconds: 100 * (index > 10 ? 10 : index),
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
                              onTap: () => _showEditTransactionSheet(t),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              // Bagian kiri: Ikon status transaksi
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      (isPemasukan ? Colors.green : Colors.red)
                                          .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPemasukan
                                      ? Icons.add_rounded
                                      : Icons.remove_rounded,
                                  color: isPemasukan
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              // Judul catatan atau jenis transaksi
                              title: Text(
                                t.note.isEmpty
                                    ? (isPemasukan
                                          ? 'Pemasukan'
                                          : 'Pengeluaran')
                                    : t.note,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              // Tanggal dan waktu transaksi
                              subtitle: Text(
                                DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(t.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              // Nominal transaksi dengan tanda +/-
                              trailing: Text(
                                isPemasukan
                                    ? '+ ${currencyFormat.format(t.amount)}'
                                    : isPengeluaran
                                    ? '- ${currencyFormat.format(t.amount)}'
                                    : '? ${currencyFormat.format(t.amount)}',
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
                      },
                    ),
                  ),
                ],
              ),
            ),
      // Tombol melayang untuk menambah transaksi baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionSheet,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
