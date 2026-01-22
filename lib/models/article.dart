// Kelas model untuk data Artikel
class Article {
  final int id; // ID unik artikel
  final String title; // Judul artikel
  final String content; // Isi atau konten artikel
  final String imageUrl; // URL gambar sampul artikel
  final DateTime createdAt; // Tanggal artikel dibuat

  // Konstruktor untuk inisialisasi objek Article
  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  // Fungsi factory untuk mengubah data dari format JSON ke objek Article
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      // Konversi ID ke integer secara aman
      id: int.parse(json['id'].toString()),
      title: json['title'],
      content: json['content'],
      // Jika image_url null, berikan string kosong
      imageUrl: json['image_url'] ?? '',
      // Parsing tanggal dari format string ke objek DateTime
      createdAt: DateTime.parse(json['date']),
    );
  }
}
