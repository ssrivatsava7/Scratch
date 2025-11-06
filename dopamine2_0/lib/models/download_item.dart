import 'video_item.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
}

class DownloadItem {
  final String id;
  final VideoItem video;
  DownloadStatus status;
  double progress;
  String? filePath;
  String? errorMessage;
  final DateTime createdAt;
  DateTime? completedAt;
  final String quality;
  final bool isAudioOnly;

  DownloadItem({
    required this.id,
    required this.video,
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    this.filePath,
    this.errorMessage,
    DateTime? createdAt,
    this.completedAt,
    this.quality = '720p',
    this.isAudioOnly = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video': video.toJson(),
      'status': status.name,
      'progress': progress,
      'filePath': filePath,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'quality': quality,
      'isAudioOnly': isAudioOnly,
    };
  }

  // Create from JSON
  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'],
      video: VideoItem.fromJson(json['video']),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.pending,
      ),
      progress: json['progress'] ?? 0.0,
      filePath: json['filePath'],
      errorMessage: json['errorMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      quality: json['quality'] ?? '720p',
      isAudioOnly: json['isAudioOnly'] ?? false,
    );
  }
}
