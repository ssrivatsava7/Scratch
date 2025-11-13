import 'video.dart';

class Playlist {
  final String id;
  final String title;
  final List<Video> videos;

  Playlist({
    required this.id,
    required this.title,
    required this.videos,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        videos: (json['videos'] as List<dynamic>?)
                ?.map((v) => Video.fromJson(v))
                .toList() ??
            [],
      );
}
