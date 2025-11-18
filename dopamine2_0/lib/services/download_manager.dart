// filepath: c:\Users\snigd\Downloads\Scratch-main\Scratch-main\dopamine2_0\lib\services\download_manager.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/download_item.dart';

// Create a simple CancelToken class for our use
class CancelToken {
  bool _isCancelled = false;
  
  bool get isCancelled => _isCancelled;
  
  void cancel([String? reason]) {
    _isCancelled = true;
  }
}

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Map<String, CancelToken> _cancelTokens = {};
  YoutubeExplode? _yt;

  Future<YoutubeExplode> _getYoutubeExplode() async {
    _yt ??= YoutubeExplode();
    return _yt!;
  }

  void dispose() {
    _yt?.close();
  }

  // Download using youtube_explode's stream method (handles authentication properly)
  Future<void> _downloadWithYoutubeExplode(
    YoutubeExplode yt,
    dynamic streamInfo,
    String filePath,
    DownloadItem item,
    Function(DownloadItem) onProgress,
  ) async {
    final stream = yt.videos.streamsClient.get(streamInfo);
    final file = File(filePath);
    final output = file.openWrite();
    
    int received = 0;
    final total = streamInfo.size.totalBytes;
    item.fileSize = total;
    
    print('Starting stream download... Total size: ${formatFileSize(total)}');
    
    await for (final chunk in stream) {
      // Check if cancelled
      if (_cancelTokens[item.id]?.isCancelled ?? false) {
        await output.close();
        throw Exception('Download cancelled');
      }
      
      output.add(chunk);
      received += chunk.length;
      
      // Update progress
      item.progress = received / total;
      item.downloadedBytes = received;
      onProgress(item);
      
      // Log progress every MB
      if (received % (1024 * 1024) < chunk.length) {
        print('Downloaded: ${formatFileSize(received)} / ${formatFileSize(total)} (${(item.progress * 100).toStringAsFixed(1)}%)');
      }
    }
    
    await output.flush();
    await output.close();
    
    print('Stream download completed!');
  }

  Future<String> get _downloadPath async {
    Directory? directory;
    
    // For Windows desktop development - use a specific local path
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Use the specific path you provided
      final downloadDir = Directory('C:\\Users\\snigd\\Downloads\\Scratch-main\\Scratch-main\\dopamine2_0\\lib\\download_av');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir.path;
    }
    
    if (Platform.isAndroid) {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
      
      // Try to get external storage directory
      directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Create a Dopamine/Music folder
        final musicDir = Directory('${directory.path}/Dopamine/Music');
        if (!await musicDir.exists()) {
          await musicDir.create(recursive: true);
        }
        return musicDir.path;
      }
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${directory.path}/Music');
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }
      return musicDir.path;
    }
    
    // Fallback
    directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> startDownload(
    DownloadItem item,
    Function(DownloadItem) onProgress,
    Function(DownloadItem) onComplete,
    Function(DownloadItem, String) onError,
  ) async {
    print('Starting download for: ${item.title} (${item.videoId})');
    
    try {
      // Prepare file path
      final downloadPath = await _downloadPath;
      final fileName = _sanitizeFileName(item.title);
      final filePath = '$downloadPath\\$fileName.m4a';
      
      print('Download path: $downloadPath');
      print('File will be saved as: $filePath');

      // Create cancel token
      final cancelToken = CancelToken();
      _cancelTokens[item.id] = cancelToken;

      // Update status to downloading
      item.status = 'downloading';
      onProgress(item);

      print('Starting download...');
      
      // Use youtube_explode's built-in stream download instead of Dio
      // This handles the authentication and headers properly
      try {
        final yt = await _getYoutubeExplode();
        final manifest = await yt.videos.streamsClient.getManifest(item.videoId);
        
        print('Manifest retrieved, looking for audio streams...');
        
        // Get the best audio stream
        final audioStreams = manifest.audioOnly;
        if (audioStreams.isEmpty) {
          print('No audio-only streams, trying all audio streams...');
          final allAudio = manifest.audio;
          if (allAudio.isEmpty) {
            throw Exception('No audio streams available for this video');
          }
          final sortedAll = allAudio.toList()
            ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
          final bestAudio = sortedAll.first;
          print('Best audio stream: ${bestAudio.bitrate} bitrate');
          
          // Download using youtube_explode's stream
          await _downloadWithYoutubeExplode(yt, bestAudio, filePath, item, onProgress);
        } else {
          final sortedStreams = audioStreams.toList()
            ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
          final bestAudio = sortedStreams.first;
          print('Best audio stream: ${bestAudio.bitrate} bitrate');
          
          // Download using youtube_explode's stream
          await _downloadWithYoutubeExplode(yt, bestAudio, filePath, item, onProgress);
        }
      } catch (e) {
        print('Error during download: $e');
        throw Exception('Failed to download: $e');
      }

      print('Download completed successfully!');
      
      // Download completed
      item.status = 'completed';
      item.progress = 1.0;
      item.filePath = filePath;
      item.completedDate = DateTime.now();
      
      // Get file size
      final file = File(filePath);
      if (await file.exists()) {
        item.fileSize = await file.length();
        item.downloadedBytes = item.fileSize!;
        print('File saved: $filePath (${formatFileSize(item.fileSize!)})');
      } else {
        print('Warning: File does not exist after download!');
      }

      _cancelTokens.remove(item.id);
      onComplete(item);
    } catch (e) {
      print('Download error: $e');
      
      // Check if it was cancelled
      if (_cancelTokens[item.id]?.isCancelled ?? false) {
        item.status = 'paused';
        item.error = 'Download cancelled';
      } else {
        item.status = 'failed';
        item.error = e.toString();
      }
      _cancelTokens.remove(item.id);
      onError(item, item.error ?? 'Unknown error');
    }
  }

  Future<void> pauseDownload(String downloadId) async {
    final cancelToken = _cancelTokens[downloadId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Paused by user');
    }
  }

  Future<void> resumeDownload(
    DownloadItem item,
    Function(DownloadItem) onProgress,
    Function(DownloadItem) onComplete,
    Function(DownloadItem, String) onError,
  ) async {
    // For simplicity, restart the download
    // In a production app, you'd implement proper resume functionality
    await startDownload(item, onProgress, onComplete, onError);
  }

  Future<void> cancelDownload(String downloadId) async {
    final cancelToken = _cancelTokens[downloadId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Cancelled by user');
    }
    _cancelTokens.remove(downloadId);
  }

  Future<void> deleteDownloadedFile(String? filePath) async {
    if (filePath == null) return;
    
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for Windows file names
    String sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'[\x00-\x1F]'), '') // Remove control characters
        .trim();
    
    // Replace multiple spaces with single space
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    // Limit length
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }
    
    // Ensure filename is not empty
    if (sanitized.isEmpty) {
      sanitized = 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return sanitized;
  }

  Future<bool> checkIfFileExists(String? filePath) async {
    if (filePath == null) return false;
    final file = File(filePath);
    return await file.exists();
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
