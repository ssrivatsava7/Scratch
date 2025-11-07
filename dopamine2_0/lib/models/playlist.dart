import 'video_item.dart';

class Playlist {
  final String id;
  String name;
  String? description;
  final List<VideoItem> videos;
  final DateTime createdAt;
  DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    List<VideoItem>? videos,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : videos = videos ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'videos': videos.map((v) => v.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((v) => VideoItem.fromJson(v))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  void addVideo(VideoItem video) {
    if (!videos.contains(video)) {
      videos.add(video);
      updatedAt = DateTime.now();
    }
  }

  void removeVideo(String videoId) {
    videos.removeWhere((v) => v.id == videoId);
    updatedAt = DateTime.now();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
