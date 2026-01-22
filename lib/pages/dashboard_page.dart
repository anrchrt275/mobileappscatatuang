import 'package:flutter/material.dart'; // Mengimport paket material design Flutter
import 'dashboard_view.dart'; // Mengimport tampilan dashboard utama
import 'transaksi_page.dart'; // Mengimport halaman transaksi
import 'artikel_page.dart'; // Mengimport halaman artikel
import 'notifikasi_page.dart'; // Mengimport halaman notifikasi
import 'profil_page.dart'; // Mengimport halaman profil

// Kelas utama DashboardPage sebagai StatefulWidget
class DashboardPage extends StatefulWidget {
  @override
  // Membuat state untuk DashboardPage
  _DashboardPageState createState() => _DashboardPageState();
}

// State class untuk mengatur logika dan tampilan Dashboard
class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0; // Index halaman yang aktif saat ini

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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              'CATATUANG', // Judul aplikasi di App Bar
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ), // Gaya teks judul
            ),
            SizedBox(width: 8),
            Text(
              'AfriYudha, M. Kom', // Nama Programmer
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ), // Gaya teks nama programmer (lebih kecil)
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
      // Bagian bawah navigasi aplikasi
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.05,
              ), // Bayangan halus di atas Nav Bar
              blurRadius: 20,
              offset: const Offset(0, -5), // Arah bayangan ke atas
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex, // Index yang sedang terpilih
          type: BottomNavigationBarType.fixed, // Tipe bar tetap (tidak geser)
          backgroundColor: Colors.white, // Warna background Nav Bar
          selectedItemColor: Theme.of(
            context,
          ).colorScheme.primary, // Warna saat item dipilih
          unselectedItemColor:
              Colors.grey[400], // Warna saat item tidak dipilih
          showSelectedLabels: true, // Tampilkan label teks yang terpilih
          showUnselectedLabels:
              true, // Tampilkan label teks yang tidak terpilih
          elevation: 0, // Tanpa bayangan internal
          items: const [
            // Definisi masing-masing item navigasi
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), // Ikon garis luar
              activeIcon: Icon(Icons.grid_view_rounded), // Ikon saat aktif
              label: 'Beranda', // Teks label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Artikel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Notif',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          onTap: _onTabTapped, // Menghubungkan klik dengan fungsi ganti tab
        ),
      ),
    );
  }
}
