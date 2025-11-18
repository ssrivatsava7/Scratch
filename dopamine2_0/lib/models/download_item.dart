// filepath: c:\Users\snigd\Downloads\Scratch-main\Scratch-main\dopamine2_0\lib\models\download_item.dart
class DownloadItem {
  final String id;
  final String videoId;
  final String title;
  final String? thumbnail;
  final String? artist;
  final String? album;
  final int? duration;
  String status; // 'pending', 'downloading', 'completed', 'failed', 'paused'
  double progress; // 0.0 to 1.0
  String? filePath;
  String? error;
  int? fileSize;
  int downloadedBytes;
  DateTime addedDate;
  DateTime? completedDate;

  DownloadItem({
    required this.id,
    required this.videoId,
    required this.title,
    this.thumbnail,
    this.artist,
    this.album,
    this.duration,
    this.status = 'pending',
    this.progress = 0.0,
    this.filePath,
    this.error,
    this.fileSize,
    this.downloadedBytes = 0,
    DateTime? addedDate,
    this.completedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'title': title,
      'thumbnail': thumbnail,
      'artist': artist,
      'album': album,
      'duration': duration,
      'status': status,
      'progress': progress,
      'filePath': filePath,
      'error': error,
      'fileSize': fileSize,
      'downloadedBytes': downloadedBytes,
      'addedDate': addedDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
    };
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'] ?? '',
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      artist: json['artist'],
      album: json['album'],
      duration: json['duration'],
      status: json['status'] ?? 'pending',
      progress: (json['progress'] ?? 0.0).toDouble(),
      filePath: json['filePath'],
      error: json['error'],
      fileSize: json['fileSize'],
      downloadedBytes: json['downloadedBytes'] ?? 0,
      addedDate: json['addedDate'] != null 
          ? DateTime.parse(json['addedDate']) 
          : DateTime.now(),
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate']) 
          : null,
    );
  }

  DownloadItem copyWith({
    String? status,
    double? progress,
    String? filePath,
    String? error,
    int? fileSize,
    int? downloadedBytes,
    DateTime? completedDate,
  }) {
    return DownloadItem(
      id: id,
      videoId: videoId,
      title: title,
      thumbnail: thumbnail,
      artist: artist,
      album: album,
      duration: duration,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
      fileSize: fileSize ?? this.fileSize,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      addedDate: addedDate,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isDownloading => status == 'downloading';
  bool get isFailed => status == 'failed';
  bool get isPaused => status == 'paused';
  bool get isPending => status == 'pending';
}
