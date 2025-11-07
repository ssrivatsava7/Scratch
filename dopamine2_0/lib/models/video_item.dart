class VideoItem {
  final String id;
  final String title;
  final String author;
  final String? thumbnailUrl;
  final Duration? duration;
  final DateTime addedAt;

  VideoItem({
    required this.id,
    required this.title,
    required this.author,
    this.thumbnailUrl,
    this.duration,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration?.inSeconds,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
