// Kelas model untuk data Pesan Notifikasi (NotificationMessage)
class NotificationMessage {
  final int id; // ID unik notifikasi
  final int userId; // ID pengguna pemilik notifikasi
  final String title; // Judul notifikasi
  final String content; // Isi atau pesan notifikasi
  final DateTime createdAt; // Waktu notifikasi dibuat

  // Konstruktor untuk membuat objek NotificationMessage
  NotificationMessage({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Fungsi factory untuk memetakan data JSON dari API ke dalam objek NotificationMessage
  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      // Konversi ID ke integer
      id: int.parse(json['id'].toString()),
      // Konversi User ID ke integer
      userId: int.parse(json['user_id'].toString()),
      title: json['title'],
      content: json['content'],
      // Parsing string tanggal menjadi objek DateTime
      createdAt: DateTime.parse(json['date']),
    );
  }
}
