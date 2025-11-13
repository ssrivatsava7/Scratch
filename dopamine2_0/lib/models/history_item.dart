class HistoryItem {
  final String id;
  final String title;
  final String author;
  final DateTime playedAt;

  HistoryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'playedAt': playedAt.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      playedAt: DateTime.tryParse(json['playedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
