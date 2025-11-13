class Favorite {
  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final String? thumbnailUrl;

  Favorite({
    required this.id,
    required this.title,
    required this.author,
    this.duration,
    this.thumbnailUrl,
  });

  /// Convert to JSON map for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'duration': duration?.inSeconds,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  /// Recreate from JSON map
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}
