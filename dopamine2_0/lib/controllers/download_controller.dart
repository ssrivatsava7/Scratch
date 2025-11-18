import 'package:get/get.dart';

import '../models/download_item.dart';
import '../services/download_manager.dart';
import '../services/storage_service.dart';

class DownloadController extends GetxController {
  final downloads = <DownloadItem>[].obs;
  final DownloadManager _downloadManager = DownloadManager();
  final isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDownloads();
  }

  void _loadDownloads() {
    try {
      final data = StorageService.getDownloads();
      downloads.value = data
          .map((e) => e is Map ? DownloadItem.fromJson(Map<String, dynamic>.from(e)) : null)
          .whereType<DownloadItem>()
          .toList();
      
      // Check file existence for completed downloads
      _verifyDownloadedFiles();
    } catch (e) {
      print('Error loading downloads: $e');
      downloads.value = [];
    }
  }

  Future<void> _verifyDownloadedFiles() async {
    for (var download in downloads) {
      if (download.isCompleted) {
        final exists = await _downloadManager.checkIfFileExists(download.filePath);
        if (!exists) {
          download.status = 'failed';
          download.error = 'File not found';
        }
      }
    }
    _saveDownloads();
  }

  void _saveDownloads() {
    final data = downloads.map((e) => e.toJson()).toList();
    StorageService.saveDownloads(data);
    downloads.refresh();
  }

  Future<void> addDownload(Map<String, dynamic> item) async {
    try {
      // Check for duplicates
      final videoId = item['videoId'] ?? item['id'];
      if (downloads.any((e) => e.videoId == videoId)) {
        Get.snackbar('Already Added', 'This item is already in downloads');
        return;
      }

      // Create download item
      final downloadItem = DownloadItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        videoId: videoId,
        title: item['title'] ?? 'Unknown',
        thumbnail: item['thumbnail'],
        artist: item['artist'] ?? item['channelTitle'],
        album: item['album'],
        duration: item['duration'],
      );

      // Add to list
      downloads.insert(0, downloadItem);
      _saveDownloads();

      Get.snackbar('Download Added', 'Starting download: ${downloadItem.title}');

      // Start download
      await _startDownload(downloadItem);
    } catch (e) {
      print('Error adding download: $e');
      Get.snackbar('Error', 'Failed to add download: $e');
    }
  }

  Future<void> _startDownload(DownloadItem item) async {
    isDownloading.value = true;
    
    await _downloadManager.startDownload(
      item,
      (updatedItem) {
        // On progress
        final index = downloads.indexWhere((e) => e.id == updatedItem.id);
        if (index != -1) {
          downloads[index] = updatedItem;
          _saveDownloads();
        }
      },
      (completedItem) {
        // On complete
        final index = downloads.indexWhere((e) => e.id == completedItem.id);
        if (index != -1) {
          downloads[index] = completedItem;
          _saveDownloads();
        }
        Get.snackbar('Download Complete', completedItem.title);
        _checkAndStartNextDownload();
      },
      (failedItem, error) {
        // On error
        final index = downloads.indexWhere((e) => e.id == failedItem.id);
        if (index != -1) {
          downloads[index] = failedItem;
          _saveDownloads();
        }
        Get.snackbar('Download Failed', error);
        _checkAndStartNextDownload();
      },
    );
  }

  void _checkAndStartNextDownload() {
    // Check if there are pending downloads
    final pendingDownloads = downloads.where((e) => e.isPending).toList();
    if (pendingDownloads.isNotEmpty) {
      _startDownload(pendingDownloads.first);
    } else {
      isDownloading.value = false;
    }
  }

  Future<void> pauseDownload(DownloadItem item) async {
    await _downloadManager.pauseDownload(item.id);
    final index = downloads.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      downloads[index].status = 'paused';
      _saveDownloads();
    }
  }

  Future<void> resumeDownload(DownloadItem item) async {
    item.status = 'pending';
    _saveDownloads();
    await _startDownload(item);
  }

  Future<void> retryDownload(DownloadItem item) async {
    item.status = 'pending';
    item.progress = 0.0;
    item.error = null;
    _saveDownloads();
    await _startDownload(item);
  }

  Future<void> removeDownload(DownloadItem item, {bool deleteFile = false}) async {
    if (deleteFile && item.filePath != null) {
      await _downloadManager.deleteDownloadedFile(item.filePath);
    }
    
    if (item.isDownloading) {
      await _downloadManager.cancelDownload(item.id);
    }
    
    downloads.removeWhere((e) => e.id == item.id);
    _saveDownloads();
  }

  Future<void> clearCompleted() async {
    downloads.removeWhere((e) => e.isCompleted);
    _saveDownloads();
  }

  Future<void> clearFailed() async {
    downloads.removeWhere((e) => e.isFailed);
    _saveDownloads();
  }

  List<DownloadItem> get completedDownloads =>
      downloads.where((e) => e.isCompleted).toList();

  List<DownloadItem> get activeDownloads =>
      downloads.where((e) => e.isDownloading || e.isPending).toList();

  List<DownloadItem> get failedDownloads =>
      downloads.where((e) => e.isFailed).toList();

  String getFormattedFileSize(int? bytes) {
    if (bytes == null) return 'Unknown';
    return _downloadManager.formatFileSize(bytes);
  }

  String getDownloadSpeed(DownloadItem item) {
    // This is a simple estimation, you can improve it with time tracking
    if (item.downloadedBytes == 0 || !item.isDownloading) return '';
    return '${_downloadManager.formatFileSize(item.downloadedBytes)}/s';
  }
}
