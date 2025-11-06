import 'package:get/get.dart';
import '../models/download_item.dart';
import '../models/video_item.dart';
import '../services/download_service.dart';
import '../services/storage_service.dart';
import 'youtube_media_controller.dart';

class DownloadController extends GetxController {
  final StorageService _storage = StorageService();
  final DownloadService _downloadService = DownloadService();
  final RxList<DownloadItem> downloads = <DownloadItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDownloads();
  }

  Future<void> loadDownloads() async {
    isLoading.value = true;
    try {
      await _storage.init();
      final loadedDownloads = await _storage.getDownloads();
      downloads.value = loadedDownloads;
    } catch (e) {
      print('Error loading downloads: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startDownload(
    VideoItem video, {
    String quality = '720p',
    bool isAudioOnly = false,
  }) async {
    try {
      // Check if already downloading or downloaded
      final existing = downloads.firstWhereOrNull((d) => d.video.id == video.id);
      if (existing != null) {
        if (existing.status == DownloadStatus.completed) {
          Get.snackbar(
            'Already Downloaded',
            'This video is already downloaded',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        if (existing.status == DownloadStatus.downloading) {
          Get.snackbar(
            'Download in Progress',
            'This video is currently downloading',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      // Create download item
      final downloadItem = DownloadItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        video: video,
        quality: quality,
        isAudioOnly: isAudioOnly,
        status: DownloadStatus.pending,
      );

      downloads.add(downloadItem);
      await _storage.addDownload(downloadItem);

      // Get video URL
      final youtubeController = Get.find<YouTubeMediaController>();
      final videoDetails = await youtubeController.getVideoDetails(video.id);

      // Update status to downloading
      downloadItem.status = DownloadStatus.downloading;
      downloads.refresh();
      await _storage.updateDownload(downloadItem);

      // Start download
      final filePath = await _downloadService.downloadVideo(
        url: videoDetails['url'],
        video: video,
        quality: quality,
        isAudioOnly: isAudioOnly,
        headers: videoDetails['headers'],
        onProgress: (progress) {
          downloadItem.progress = progress;
          downloads.refresh();
        },
      );

      // Update status to completed
      downloadItem.status = DownloadStatus.completed;
      downloadItem.filePath = filePath;
      downloadItem.completedAt = DateTime.now();
      downloadItem.progress = 1.0;
      downloads.refresh();
      await _storage.updateDownload(downloadItem);

      Get.snackbar(
        'Download Complete',
        video.title,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Download error: $e');
      
      // Update status to failed
      final downloadItem = downloads.firstWhereOrNull((d) => d.video.id == video.id);
      if (downloadItem != null) {
        downloadItem.status = DownloadStatus.failed;
        downloadItem.errorMessage = e.toString();
        downloads.refresh();
        await _storage.updateDownload(downloadItem);
      }

      Get.snackbar(
        'Download Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void cancelDownload(String videoId) {
    try {
      _downloadService.cancelDownload(videoId);
      
      final downloadItem = downloads.firstWhereOrNull((d) => d.video.id == videoId);
      if (downloadItem != null) {
        downloadItem.status = DownloadStatus.paused;
        downloads.refresh();
        _storage.updateDownload(downloadItem);
      }
    } catch (e) {
      print('Error cancelling download: $e');
    }
  }

  Future<void> deleteDownload(String downloadId) async {
    try {
      final downloadItem = downloads.firstWhereOrNull((d) => d.id == downloadId);
      if (downloadItem != null) {
        // Delete file if exists
        if (downloadItem.filePath != null) {
          await _downloadService.deleteDownloadedFile(downloadItem.filePath!);
        }
        
        // Remove from list and storage
        downloads.removeWhere((d) => d.id == downloadId);
        await _storage.removeDownload(downloadId);
        
        Get.snackbar(
          'Download Deleted',
          'Download has been removed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error deleting download: $e');
      Get.snackbar(
        'Error',
        'Failed to delete download',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String> getTotalDownloadSize() async {
    final size = await _downloadService.getTotalDownloadSize();
    return _downloadService.formatBytes(size);
  }

  DownloadItem? getDownload(String videoId) {
    return downloads.firstWhereOrNull((d) => d.video.id == videoId);
  }
}
