import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'dashboard_view.dart'; // Mengimport tampilan dashboard utama
import 'transaksi_page.dart'; // Mengimport halaman transaksi
import 'artikel_page.dart'; // Mengimport halaman artikel
import 'notifikasi_page.dart'; // Mengimport halaman notifikasi
import 'profil_page.dart'; // Mengimport halaman profil
import 'package:shared_preferences/shared_preferences.dart'; // Mengimport library untuk penyimpanan data lokal

// Kelas utama DashboardPage sebagai StatefulWidget
class DashboardPage extends StatefulWidget {
  @override
  // Membuat state untuk DashboardPage
  _DashboardPageState createState() => _DashboardPageState();
}

// State class untuk mengatur logika dan tampilan Dashboard
class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0; // Index halaman yang aktif saat ini
  String _userName = ''; // Variabel penyimpan nama user

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Fungsi untuk memuat nama user dari SharedPreferences
  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
    });
  }

  // Daftar halaman yang akan ditampilkan di BottomNavigationBar
  final List<Widget> _pages = [
    DashboardView(), // Halaman Beranda (Index 0)
    TransaksiPage(), // Halaman Transaksi (Index 1)
    ArtikelPage(), // Halaman Artikel (Index 2)
    NotifikasiPage(), // Halaman Notifikasi (Index 3)
    ProfilPage(), // Halaman Profil (Index 4)
  ];

  // Fungsi untuk menangani perubahan tab saat ditekan
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Update index halaman aktif
    });

    // Melakukan refresh halaman Transaksi saat berpindah ke tab tersebut
    if (index == 1) {
      setState(() {
        _pages[1] = TransaksiPage(); // Re-assign widget untuk trigger refresh
      });
    }

    // Melakukan refresh tampilan Dashboard saat kembali ke tab Beranda
    if (index == 0) {
      setState(() {
        _pages[0] = DashboardView(); // Re-assign widget untuk trigger refresh
      });
    }
  }

  @override
  // Membangun kerangka tampilan utama dashboard
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna latar belakang halaman
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CATATUANG', // Judul aplikasi di App Bar
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ), // Gaya teks judul
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Halo, $_userName!', // Sapaan user di sebelah kanan
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        backgroundColor: Colors.white, // Warna background App Bar
        foregroundColor: Colors.black87, // Warna teks/ikon di App Bar
        elevation: 0, // Menghilangkan bayangan di bawah App Bar
        automaticallyImplyLeading: false, // Menghilangkan tombol back otomatis
      ),
      body:
          _pages[_currentIndex], // Menampilkan halaman sesuai index yang dipilih
      // Bagian bawah navigasi aplikasi dengan gaya melayang (Floating)
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ), // Memberikan jarak dari tepi agar melayang
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24), // Sudut melengkung penuh
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10), // Bayangan jatuh ke bawah
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _currentIndex == _currentIndex ? _onTabTapped : null,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey[400],
              showSelectedLabels:
                  false, // Menghilangkan label agar lebih minimalis
              showUnselectedLabels: false,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_rounded),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
