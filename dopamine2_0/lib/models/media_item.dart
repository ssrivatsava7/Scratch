class MediaItem {
  final String videoUrl;
  final String audioUrl;
  final String title;
  final String thumbnailUrl;
  final String channelName;
  final Duration duration;

  MediaItem({
    required this.videoUrl,
    required this.audioUrl,
    required this.title,
    required this.thumbnailUrl,
    required this.channelName,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        "videoUrl": videoUrl,
        "audioUrl": audioUrl,
        "title": title,
        "thumbnail": thumbnailUrl,
        "author": channelName,
        "duration": duration.inSeconds
      };

  static MediaItem fromJson(Map<String, dynamic> json) {
    return MediaItem(
      videoUrl: json["videoUrl"],
      audioUrl: json["audioUrl"],
      title: json["title"],
      thumbnailUrl: json["thumbnail"],
      channelName: json["author"],
      duration: Duration(seconds: json["duration"] ?? 0),
    );
  }
}
