class Transaction {
  final int id;
  final int userId;
  final String type;
  final double amount;
  final String note;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      type: json['type'] ?? '',
      amount: _parseAmount(json['amount']),
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['date']),
    );
  }

  static double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    try {
      return double.parse(amount.toString());
    } catch (e) {
      print('Error parsing amount: $amount, error: $e');
      return 0.0;
    }
  }
}
