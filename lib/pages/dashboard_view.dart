import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import '../models/transaction.dart';
import 'transaksi_page.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _apiService = ApiService();
  String _userName = '';
  double _saldo = 0;
  double _pemasukan = 0;
  double _pengeluaran = 0;
  bool _isSaldoVisible = true;
  bool _isLoading = true;
  List<Transaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;
    final name = prefs.getString('name') ?? 'User';
    final isVisible = prefs.getBool('is_saldo_visible') ?? true;

    if (mounted) {
      setState(() {
        _userName = name;
        _isSaldoVisible = isVisible;
      });
    }

    try {
      // Load stats
      final stats = await _apiService.getDashboardStats(userId);

      // Load recent transactions
      final transactions = await _apiService.getTransactions(userId);

      if (mounted) {
        setState(() {
          _saldo = _parseDouble(stats['saldo']?.toString() ?? '0');
          _pemasukan = _parseDouble(stats['pemasukan']?.toString() ?? '0');
          _pengeluaran = _parseDouble(stats['pengeluaran']?.toString() ?? '0');
          _recentTransactions = transactions
              .take(3)
              .toList(); // Show only 3 recent
          _isLoading = false;
        });
      }
    } catch (e) {
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

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
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
                                'Total Saldo',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    _isSaldoVisible = !_isSaldoVisible;
                                    prefs.setBool(
                                      'is_saldo_visible',
                                      _isSaldoVisible,
                                    );
                                  });
                                },
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),
                  Text(
                    'Halo, $_userName!',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: FadeInLeft(
                  delay: const Duration(milliseconds: 200),
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
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aktivitas Terakhir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Column(
              children: [
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
                    : _recentTransactions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final t = entry.value;
                        final isPemasukan = t.type == 'income';
                        final isPengeluaran = t.type == 'expense';

                        return FadeInUp(
                          delay: Duration(milliseconds: 500 + (index * 100)),
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
                                          .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
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
                              subtitle: Text(
                                DateFormat('dd MMM, HH:mm').format(t.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
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
              _isSaldoVisible ? currencyFormat.format(amount) : 'Rp •••••',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
