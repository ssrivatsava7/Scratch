enum DownloadStatus { queued, downloading, paused, pending, completed, failed, canceled }

class DownloadItem {
  final String id;
  final String title;
  final String author;
  final String url;
  final String quality;
  final bool isAudioOnly;
  DownloadStatus status;
  double progress;
  String? errorMessage;

  DownloadItem({
    required this.id,
    required this.title,
    required this.author,
    required this.url,
    required this.quality,
    this.isAudioOnly = false,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.errorMessage,
  });
}
