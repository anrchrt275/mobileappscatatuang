import 'package:flutter/material.dart'; // Mengimport paket material design dari Flutter
import 'package:animate_do/animate_do.dart'; // Mengimport paket untuk animasi
import 'package:intl/intl.dart'; // Mengimport paket untuk format tanggal dan waktu
import '../services/api_service.dart'; // Mengimport layanan API yang sudah dibuat
import '../models/article.dart'; // Mengimport model data Artikel
import '../services/api_config.dart'; // Mengimport konfigurasi API
import 'package:google_fonts/google_fonts.dart'; // Mengimport paket Google Fonts

// Kelas Utama untuk halaman Artikel menggunakan StatefulWidget
class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key}); // Konstruktor kelas ArtikelPage

  @override
  // Membuat state untuk ArtikelPage
  State<ArtikelPage> createState() => _ArtikelPageState();
}

// State class untuk ArtikelPage dengan TickerProvider untuk animasi
class _ArtikelPageState extends State<ArtikelPage>
    with TickerProviderStateMixin {
  final _apiService =
      ApiService(); // Instance dari ApiService untuk memanggil API
  List<Article> _articles = []; // List untuk menyimpan daftar artikel
  bool _isLoading = true; // Boolean untuk status loading data
  late AnimationController
  _fabController; // Controller untuk animasi Floating Action Button

  @override
  // Fungsi yang dijalankan pertama kali saat widget dibuat
  void initState() {
    super.initState(); // Memanggil initState dari super class
    // Inisialisasi controller animasi FAB
    _fabController = AnimationController(
      vsync: this, // Menghubungkan durasi animasi dengan layar
      duration: const Duration(milliseconds: 400), // Durasi animasi 400ms
    );
    _loadArticles(); // Memanggil fungsi untuk memuat artikel dari API
  }

  @override
  // Fungsi yang dijalankan saat widget dihancurkan
  void dispose() {
    _fabController.dispose(); // Membuang controller animasi untuk hemat memori
    super.dispose(); // Memanggil dispose dari super class
  }

  // Fungsi asynchronous untuk mengambil data artikel dari API
  void _loadArticles() async {
    try {
      final data = await _apiService
          .getArticles(); // Mengambil data artikel lewat API
      if (!mounted) return; // Jika widget sudah tidak aktif, jangan lanjutkan
      setState(() {
        _articles = data; // Simpan data ke variabel list
        _isLoading = false; // Set loading jadi false
        _fabController.forward(); // Jalankan animasi FAB muncul
      });
    } catch (e) {
      if (!mounted) return; // Jika widget sudah tidak aktif, jangan lanjutkan
      setState(
        () => _isLoading = false,
      ); // Set loading false jika terjadi error
    }
  }

  // Fungsi untuk menampilkan dialog tambah artikel
  void _showAddArticleDialog() {
    final titleController = TextEditingController(); // Controller input judul
    final contentController =
        TextEditingController(); // Controller input konten
    final imageController =
        TextEditingController(); // Controller input URL gambar

    // Menampilkan Bottom Sheet (dialog dari bawah)
    showModalBottomSheet(
      context: context, // Menggunakan context saat ini
      isScrollControlled: true, // Membuat dialog bisa discroll jika panjang
      backgroundColor: Colors.transparent, // Latar belakang transparan
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Menambah pendengar perubahan pada input gambar untuk preview
          imageController.addListener(() {
            if (context.mounted)
              setModalState(() {}); // Update tampilan preview gambar
          });

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Warna putih untuk latar dialog
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(32),
              ), // Lengkungan atas
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                dialogContext,
              ).viewInsets.bottom, // Penyesuaian keyboard
              left: 24, // Padding kiri
              right: 24, // Padding kanan
              top: 32, // Padding atas
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // Efek scroll memantul
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ukuran kolom minimal
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Jarak antara elemen
                    children: [
                      const Text(
                        'Tambah Artikel Baru', // Judul dialog
                        style: TextStyle(
                          fontSize: 24, // Ukuran font
                          fontWeight: FontWeight.bold, // Tebal font
                          letterSpacing: -0.5, // Jarak antar huruf
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext), // Tombol tutup dialog
                        icon: const Icon(Icons.close_rounded), // Ikon silang
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.grey[100], // Background tombol abu-abu
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24), // Jarak pemisah
                  // Cek jika field input gambar tidak kosong untuk menampilkan preview
                  if (imageController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                      ), // Jarak bawah preview
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview Gambar:', // Label preview
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8), // Jarak label ke gambar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Lengkungan gambar
                            child: Image.network(
                              ApiConfig.normalizeUrl(
                                imageController.text,
                              ), // Load gambar dari URL
                              height: 150, // Tinggi gambar preview
                              width: double.infinity, // Lebar penuh
                              fit: BoxFit.cover, // Gambar memenuhi area
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null)
                                      return child; // Gambat selesai dimuat
                                    return Container(
                                      height: 150,
                                      color: Colors
                                          .grey[50], // Loading placeholder
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2, // Ketebalan loading
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildSharedImagePlaceholder(
                                    context,
                                    icon: Icons
                                        .broken_image_outlined, // Ikon jika error
                                    label: 'Preview Error', // Teks error
                                    sublabel: error.toString(), // Detail error
                                    height: 150,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Field input untuk Judul Artikel
                  _buildTextField(
                    controller: titleController,
                    label: 'Judul Artikel',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16), // Jarak antar field
                  // Field input untuk Konten Artikel
                  _buildTextField(
                    controller: contentController,
                    label: 'Isi Konten Artikel',
                    icon: Icons.article_outlined,
                    maxLines: 4, // Isi konten bisa 4 baris
                  ),
                  const SizedBox(height: 16), // Jarak antar field
                  // Field input untuk URL Gambar
                  _buildTextField(
                    controller: imageController,
                    label: 'URL Gambar Luar (misal: https://...)',
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 32), // Jarak ke tombol submit
                  SizedBox(
                    width: double.infinity, // Lebar tombol penuh
                    height: 56, // Tinggi tombol
                    child: ElevatedButton(
                      onPressed: () async {
                        // Validasi input tidak boleh kosong
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Judul dan isi tidak boleh kosong',
                              ), // Pesan error
                              behavior:
                                  SnackBarBehavior.floating, // Pesan melayang
                            ),
                          );
                          return;
                        }
                        // Memanggil API tambah artikel
                        await _apiService.addArticle(
                          titleController.text,
                          contentController.text,
                          imageController.text,
                        );
                        if (!mounted) return;
                        Navigator.pop(
                          dialogContext,
                        ); // Tutup dialog setelah berhasil
                        _loadArticles(); // Refresh daftar artikel
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary, // Warna tema utama
                        foregroundColor: Colors.white, // Warna teks putih
                        elevation: 0, // Tanpa bayangan
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            16,
                          ), // Lengkungan tombol
                        ),
                      ),
                      child: const Text(
                        'Publish Artikel', // Teks tombol
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Jarak bawah dialog
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Fungsi untuk menampilkan dialog edit artikel
  void _showEditArticleDialog(Article article) {
    final titleController = TextEditingController(
      text: article.title,
    ); // Isi input dengan judul lama
    final contentController = TextEditingController(
      text: article.content,
    ); // Isi input dengan konten lama
    final imageController = TextEditingController(
      text: article.imageUrl,
    ); // Isi input dengan URL lama

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          imageController.addListener(() {
            if (context.mounted) setModalState(() {});
          });

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Artikel', // Judul dialog edit
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (imageController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview Gambar:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              ApiConfig.normalizeUrl(imageController.text),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[50],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildSharedImagePlaceholder(
                                    context,
                                    icon: Icons.broken_image_outlined,
                                    label: 'Preview Error',
                                    sublabel: error.toString(),
                                    height: 150,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildTextField(
                    controller: titleController,
                    label: 'Judul Artikel',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: contentController,
                    label: 'Isi Konten Artikel',
                    icon: Icons.article_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: imageController,
                    label: 'URL Gambar Luar (misal: https://...)',
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Judul dan isi tidak boleh kosong'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        // Panggil API update artikel
                        await _apiService.updateArticle(
                          article.id,
                          titleController.text,
                          contentController.text,
                          imageController.text,
                        );
                        if (!mounted) return;
                        Navigator.pop(dialogContext); // Tutup dialog
                        _loadArticles(); // Refresh data
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Artikel berhasil diperbarui',
                            ), // Notifikasi berhasil
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan', // Teks tombol simpan
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget helper untuk membuat input text field yang konsisten
  Widget _buildTextField({
    required TextEditingController controller, // Controller input
    required String label, // Label teks input
    required IconData icon, // Ikon input
    int maxLines = 1, // Jumlah baris input (default 1)
  }) {
    return TextField(
      controller: controller, // Menghubungkan controller
      maxLines: maxLines, // Jumlah baris
      decoration: InputDecoration(
        labelText: label, // Label di atas input
        prefixIcon: Icon(icon, color: Colors.grey[400]), // Ikon di kiri input
        filled: true, // Latar input berwarna
        fillColor: Colors.grey[50], // Warna latar abu sangat muda
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Lengkungan sudut
          borderSide: BorderSide.none, // Tanpa garis pinggir
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
          ), // Garis saat tidak fokus
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.5), // Garis saat fokus
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  // Membangun tampilan utama halaman
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna latar halaman belakang
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // Scroll memantul gaya iOS
        slivers: [
          // App bar yang bisa mengecil saat discroll
          SliverAppBar(
            expandedHeight: 120, // Tinggi maksimal saat terbuka
            floating: true, // Muncul kembali saat scroll ke atas sedikit
            pinned: true, // Menetap di atas saat discroll jauh
            elevation: 0, // Tanpa bayangan
            backgroundColor: Colors.white, // Baground putih
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Artikel Terbaru', // Judul app bar
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false, // Judul tidak di tengah
              titlePadding: const EdgeInsets.only(
                left: 24,
                bottom: 16,
              ), // Jarak judul
            ),
            actions: [
              IconButton(
                onPressed: () => _loadArticles(), // Tombol refresh
                icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              100,
            ), // Padding daftar
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ), // Loading tengah layar
                    ),
                  )
                : _articles.isEmpty
                ? SliverFillRemaining(
                    child: FadeIn(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.5,
                              child: Icon(
                                Icons.article_outlined, // Ikon jika kosong
                                size: 100,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Belum ada artikel', // Teks jika kosong
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mulai tambahkan artikel keuangan pertama Anda',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    // Delegasi untuk membangun item dalam list
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final a = _articles[index]; // Ambil data tiap index
                      return FadeInUp(
                        // Animasi muncul dari bawah
                        delay: Duration(
                          milliseconds:
                              100 * (index > 5 ? 5 : index), // Delay bertahap
                        ),
                        child: _ArticleCard(
                          article: a, // Kirim data artikel ke widget card
                          index: index, // Kirim index
                          onDelete: () => _deleteArticle(a.id), // Fungsi hapus
                          onEdit: () =>
                              _showEditArticleDialog(a), // Fungsi edit
                        ),
                      );
                    }, childCount: _articles.length), // Jumlah item
                  ),
          ),
        ],
      ),
      // Tombol tambah melayang di pojok
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController, // Animasi skala tombol
          curve: Curves.elasticOut, // Efek memantul
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddArticleDialog, // Panggil dialog tambah
          backgroundColor: Theme.of(context).colorScheme.primary, // Warna tema
          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
          ), // Ikon tambah
          label: const Text(
            'Tulis Artikel', // Label tombol
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Bentuk tombol lonjong
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menghapus artikel dengan konfirmasi
  void _deleteArticle(int id) async {
    // Memunculkan dialog konfirmasi
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Artikel?'),
            content: const Text('Artikel ini akan dihapus secara permanen.'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false), // Tutup dan kirim false
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, true), // Tutup dan kirim true
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ), // Tombol warna merah
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false; // Default false jika dialog terbatal

    if (confirm) {
      try {
        await _apiService.deleteArticle(id); // Panggil API hapus
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel berhasil dihapus'),
          ), // Alert berhasil
        );
        _loadArticles(); // Refresh daftar artikel
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus artikel: $e')),
        ); // Alert gagal
      }
    }
  }
}

// Widget internal untuk menampilkan satu kartu artikel
class _ArticleCard extends StatefulWidget {
  final Article article; // Objek data artikel
  final int index; // Index urutan artikel
  final VoidCallback onDelete; // Fungsi callback hapus
  final VoidCallback onEdit; // Fungsi callback edit

  const _ArticleCard({
    required this.article,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  // Membuat state untuk kartu artikel
  State<_ArticleCard> createState() => _ArticleCardState();
}

// State untuk kartu artikel dengan TickerProvider tunggal
class _ArticleCardState extends State<_ArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController; // Controller untuk efek hover
  late Animation<double> _scale; // Animasi skala saat disentuh/hover

  // Daftar gambar default dari Unsplash jika URL tidak tersedia
  final List<String> _defaultImages = [
    'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=80',
    'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800&q=80',
    'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&q=80',
    'https://images.unsplash.com/photo-1454165205744-3b78555e5572?w=800&q=80',
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    'https://images.unsplash.com/photo-1591696208162-a97b7059744c?w=800&q=80',
  ];

  // Getter untuk menentukan gambar mana yang akan ditampilkan
  String get _displayImage {
    if (widget.article.imageUrl.isNotEmpty) {
      return ApiConfig.normalizeUrl(widget.article.imageUrl); // Pakai URL user
    }
    // Pakai gambar default berdasarkan sisa bagi index agar bervariasi
    return _defaultImages[widget.index % _defaultImages.length];
  }

  @override
  // Inisialisasi state animasi hover
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ), // Durasi transisi hover cepat
    );

    // Animasi perubahan skala dari 100% ke 102%
    _scale = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  // Buang controller saat widget dihapus
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  // Menampilkan detail artikel lengkap dalam dialog
  void _showDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => ZoomIn(
        // Efek muncul membesar dari tengah
        duration: const Duration(milliseconds: 300),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // Sudut tumpul dialog
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Hero(
                      // Animasi perpindahan gambar antar layar/dialog
                      tag: 'article_image_${widget.article.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        child: Image.network(
                          _displayImage,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 220,
                              color: Colors.grey[50],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildSharedImagePlaceholder(
                                context,
                                height: 220,
                                icon: Icons.broken_image_rounded,
                                label: 'Gagal Memuat Gambar',
                                sublabel: error.toString(),
                              ),
                        ),
                      ),
                    ),
                    // Tombol aksi melayang (edit, hapus, tutup)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color:
                                    Colors.blueAccent, // Warna bitu untuk edit
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog dulu
                                widget.onEdit(); // Panggil fungsi edit
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color:
                                    Colors.redAccent, // Warna merah untuk hapus
                              ),
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog dulu
                                widget.onDelete(); // Panggil fungsi hapus
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.black87,
                              ),
                              onPressed: () =>
                                  Navigator.pop(context), // Tutup dialog
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip kategori/label artikel
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Financial Insights',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Judul artikel di dalam dialog
                        Text(
                          widget.article.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Info tanggal pembuatan
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat(
                                'dd MMMM yyyy',
                              ).format(widget.article.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(), // Garis pembatas
                        const SizedBox(height: 24),
                        // Isi penuh artikel
                        Text(
                          widget.article.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.7, // Jarak antar baris teks
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  // Membangun tampilan satu kartu artikel
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController, // Mendengarkan perubahan animasi hover
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value, // Ubah skala berdasar animasi
          child: Container(
            margin: const EdgeInsets.only(bottom: 20), // Jarak ke item bawahnya
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.04,
                  ), // Bayangan sangat halus
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip
                  .antiAlias, // Memotong anak widget sesuai sudut melengkung
              child: InkWell(
                onTap: _showDetailDialog, // Aksi saat kartu ditekan
                onHover: (h) => h
                    ? _hoverController.forward()
                    : _hoverController.reverse(), // Jalan animasi saat hover
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag:
                              'article_image_${widget.article.id}', // Tag unikHero
                          child: Image.network(
                            _displayImage,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 180,
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 180,
                                  color: Colors.grey[100],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        // Label "Tips" di atas gambar
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Tips',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul dalam daftar (maks 2 baris)
                          Text(
                            widget.article.title,
                            maxLines: 2,
                            overflow: TextOverflow
                                .ellipsis, // Potong teks jika panjang
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Cuplikan isi dalam daftar (maks 2 baris)
                          Text(
                            widget.article.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tanggal dan link baca selengkapnya
                          Row(
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(widget.article.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(), // Dorong widget berikutnya ke ujung kanan
                              Text(
                                'Baca Selengkapnya',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
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
      },
    );
  }
}

// Widget utilitas untuk menampilkan placeholder/error gambar yang bisa dipakai ulang
Widget _buildSharedImagePlaceholder(
  BuildContext context, {
  required IconData icon, // Ikon pusat
  required String label, // Label utama
  String? sublabel, // Sublabel opsional
  double height = 150, // Tinggi default
}) {
  return Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
    ),
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
        if (sublabel != null) // Jika ada sublabel (pesan error) taring di bawah
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
