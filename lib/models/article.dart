class Article {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.parse(json['date']),
    );
  }
}
