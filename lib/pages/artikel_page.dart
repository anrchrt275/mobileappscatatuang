import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/article.dart';
import '../services/api_config.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage>
    with TickerProviderStateMixin {
  final _apiService = ApiService();
  List<Article> _articles = [];
  bool _isLoading = true;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadArticles();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _loadArticles() async {
    try {
      final data = await _apiService.getArticles();
      if (!mounted) return;
      setState(() {
        _articles = data;
        _isLoading = false;
        _fabController.forward();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showAddArticleDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final imageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Add listener to update preview
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
                        'Tambah Artikel Baru',
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
                        await _apiService.addArticle(
                          titleController.text,
                          contentController.text,
                          imageController.text,
                        );
                        if (!mounted) return;
                        Navigator.pop(dialogContext);
                        _loadArticles();
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
                        'Publish Artikel',
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

  void _showEditArticleDialog(Article article) {
    final titleController = TextEditingController(text: article.title);
    final contentController = TextEditingController(text: article.content);
    final imageController = TextEditingController(text: article.imageUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Add listener to update preview
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
                        'Edit Artikel',
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
                        await _apiService.updateArticle(
                          article.id,
                          titleController.text,
                          contentController.text,
                          imageController.text,
                        );
                        if (!mounted) return;
                        Navigator.pop(dialogContext);
                        _loadArticles();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Artikel berhasil diperbarui'),
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
                        'Simpan Perubahan',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Artikel Terbaru',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            ),
            actions: [
              IconButton(
                onPressed: () => _loadArticles(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                                Icons.article_outlined,
                                size: 100,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Belum ada artikel',
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
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final a = _articles[index];
                      return FadeInUp(
                        delay: Duration(
                          milliseconds: 100 * (index > 5 ? 5 : index),
                        ),
                        child: _ArticleCard(
                          article: a,
                          index: index,
                          onDelete: () => _deleteArticle(a.id),
                          onEdit: () => _showEditArticleDialog(a),
                        ),
                      );
                    }, childCount: _articles.length),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddArticleDialog,
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Tulis Artikel',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  void _deleteArticle(int id) async {
    // Show confirmation dialog
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Artikel?'),
            content: const Text('Artikel ini akan dihapus secara permanen.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await _apiService.deleteArticle(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus')),
        );
        _loadArticles();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus artikel: $e')));
      }
    }
  }
}

class _ArticleCard extends StatefulWidget {
  final Article article;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ArticleCard({
    required this.article,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scale;

  // Curated list of high-quality financial/business images from Unsplash
  final List<String> _defaultImages = [
    'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=80',
    'https://images.unsplash.com/photo-1579621970563-ebec7560ff3e?w=800&q=80',
    'https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&q=80',
    'https://images.unsplash.com/photo-1454165205744-3b78555e5572?w=800&q=80',
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    'https://images.unsplash.com/photo-1591696208162-a97b7059744c?w=800&q=80',
  ];

  String get _displayImage {
    if (widget.article.imageUrl.isNotEmpty) {
      return ApiConfig.normalizeUrl(widget.article.imageUrl);
    }
    // Use index to consistently pick the same image for the same article in the list
    return _defaultImages[widget.index % _defaultImages.length];
  }

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 1, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _showDetailDialog() {
    showDialog(
      context: context,
      builder: (context) => ZoomIn(
        duration: const Duration(milliseconds: 300),
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Hero(
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
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onEdit();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onDelete();
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
                              onPressed: () => Navigator.pop(context),
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
                        const Divider(),
                        const SizedBox(height: 24),
                        Text(
                          widget.article.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.7,
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _showDetailDialog,
                onHover: (h) =>
                    h ? _hoverController.forward() : _hoverController.reverse(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag: 'article_image_${widget.article.id}',
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
                          Text(
                            widget.article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                              const Spacer(),
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

Widget _buildSharedImagePlaceholder(
  BuildContext context, {
  required IconData icon,
  required String label,
  String? sublabel,
  double height = 150,
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
