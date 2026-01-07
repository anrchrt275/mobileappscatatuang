class NotificationMessage {
  final int id;
  final int userId;
  final String title;
  final String content;
  final DateTime createdAt;

  NotificationMessage({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['date']),
    );
  }
}
