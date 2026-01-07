import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage>
    with WidgetsBindingObserver {
  final _apiService = ApiService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'income';
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  double _totalPemasukan = 0.0;
  double _totalPengeluaran = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTransactions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      _loadTransactions();
    }
  }

  void _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    print('DEBUG: Loading transactions for user_id: $userId');

    try {
      // Load transactions
      final data = await _apiService.getTransactions(userId);
      print('DEBUG: Got ${data.length} transactions');

      // Load stats
      final stats = await _apiService.getDashboardStats(userId);
      print('DEBUG: Got stats: $stats');

      if (mounted) {
        setState(() {
          _transactions = data.reversed.toList(); // Newest first
          _totalPemasukan = _parseDouble(stats['pemasukan']?.toString() ?? '0');
          _totalPengeluaran = _parseDouble(
            stats['pengeluaran']?.toString() ?? '0',
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error loading transactions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      print('Error parsing double: $value, error: $e');
      return 0.0;
    }
  }

  void _addTransaction() async {
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
      final response = await _apiService.addTransaction(
        userId,
        _type,
        double.parse(_amountController.text),
        _noteController.text.isEmpty ? '' : _noteController.text,
      );

      print('DEBUG: Add transaction response: $response');

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        _amountController.clear();
        _noteController.clear();
        Navigator.pop(context);

        // Force refresh with a small delay to ensure UI updates
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadTransactions();
          }
        });
      } else {
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

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

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
            child: Text(
              currencyFormat.format(amount),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionSheet() {
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
                'Tambah Transaksi Baru',
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

  @override
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
              setState(() => _isLoading = true);
              _loadTransactions();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(
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
              onRefresh: () async => _loadTransactions(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Income & Expense Cards
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
                  // Transaction List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final t = _transactions[index];
                        final isPemasukan = t.type == 'income';
                        final isPengeluaran = t.type == 'expense';
                        return FadeInUp(
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
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
                              subtitle: Text(
                                DateFormat(
                                  'dd MMM yyyy, HH:mm',
                                ).format(t.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
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
