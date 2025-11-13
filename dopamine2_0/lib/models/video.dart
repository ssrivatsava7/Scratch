class Video {
  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final Duration duration;

  Video({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    required this.duration,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'thumbnailUrl': thumbnailUrl,
        'duration': duration.inSeconds,
      };
}
