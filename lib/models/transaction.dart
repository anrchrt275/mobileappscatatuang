// Kelas model untuk merepresentasikan data Transaksi
class Transaction {
  final int id; // ID unik transaksi
  final int userId; // ID pengguna yang melakukan transaksi
  final String type; // Jenis transaksi (misal: 'income' atau 'expense')
  final double amount; // Jumlah atau nominal uang dalam transaksi
  final String note; // Catatan atau keterangan tambahan transaksi
  final DateTime createdAt; // Waktu dan tanggal transaksi dilakukan

  // Konstruktor untuk inisialisasi objek Transaction
  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  // Fungsi factory untuk mengubah data JSON dari server menjadi objek Transaction
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      // Konversi ID ke integer
      id: int.parse(json['id'].toString()),
      // Konversi User ID ke integer
      userId: int.parse(json['user_id'].toString()),
      // Jika type null, berikan string kosong
      type: json['type'] ?? '',
      // Memanggil fungsi pembantu untuk memproses nominal uang
      amount: _parseAmount(json['amount']),
      // Jika catatan null, berikan string kosong
      note: json['note'] ?? '',
      // Parsing string tanggal ke objek DateTime
      createdAt: DateTime.parse(json['date']),
    );
  }

  // Fungsi statis internal untuk membantu konversi tipe data nominal ke double secara aman
  static double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0; // Jika data kosong, anggap 0
    try {
      // Mencoba mengubah format data apapun ke double
      return double.parse(amount.toString());
    } catch (e) {
      // Log error jika format ternyata tidak bisa diubah ke angka
      print('Error parsing amount: $amount, error: $e');
      return 0.0;
    }
  }
}
