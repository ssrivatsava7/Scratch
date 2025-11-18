import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  late final Dio _dio;
  
  DownloadService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': '*/*',
          'Referer': 'https://www.youtube.com/',
        },
      ),
    );
  }
  
  /// Get the downloads directory path
  Future<String> getDownloadsPath() async {
    Directory? directory;
    
    if (Platform.isWindows) {
      // For Windows, use Documents/Dopamine Downloads
      final homeDir = Platform.environment['USERPROFILE'];
      if (homeDir != null) {
        directory = Directory('$homeDir\\Documents\\Dopamine Downloads');
      }
    } else if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      directory = Directory('${directory!.path}/Dopamine Downloads');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/Downloads');
    }
    
    // Create directory if it doesn't exist
    if (directory != null && !await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory?.path ?? '';
  }
  
  /// Download a file with progress tracking
  Future<String> downloadFile({
    required String url,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      final downloadsPath = await getDownloadsPath();
      final filePath = '$downloadsPath/$fileName';
      
      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      
      // Download the file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total);
            onProgress(progress);
          }
        },
      );
      
      return filePath;
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
  
  /// Download audio file
  Future<String> downloadAudio({
    required String url,
    required String videoId,
    required Function(double) onProgress,
  }) async {
    final fileName = 'audio_$videoId.m4a';
    return await downloadFile(
      url: url,
      fileName: fileName,
      onProgress: onProgress,
    );
  }
  
  /// Download video file
  Future<String> downloadVideo({
    required String url,
    required String videoId,
    required Function(double) onProgress,
  }) async {
    final fileName = 'video_$videoId.mp4';
    return await downloadFile(
      url: url,
      fileName: fileName,
      onProgress: onProgress,
    );
  }
  
  /// Download thumbnail
  Future<String> downloadThumbnail({
    required String url,
    required String videoId,
  }) async {
    final fileName = 'thumb_$videoId.jpg';
    return await downloadFile(
      url: url,
      fileName: fileName,
      onProgress: (_) {}, // No progress tracking for thumbnails
    );
  }
  
  /// Delete downloaded file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
  
  /// Check if file exists locally
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get file size in MB
  Future<double> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024); // Convert to MB
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
