import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart' hide Response;
import '../models/download_item.dart';
import '../models/video_item.dart';

class DownloadService {
  final Dio _dio = Dio();
  final RxMap<String, double> downloadProgress = <String, double>{}.obs;
  final RxMap<String, CancelToken> cancelTokens = <String, CancelToken>{}.obs;

  Future<String> getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/dopamine_downloads');
    
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    
    return downloadDir.path;
  }

  Future<String> downloadVideo({
    required String url,
    required VideoItem video,
    required String quality,
    bool isAudioOnly = false,
    Map<String, String>? headers,
    Function(double)? onProgress,
  }) async {
    try {
      final downloadDir = await getDownloadDirectory();
      final extension = isAudioOnly ? 'webm' : 'mp4';
      final safeTitle = video.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final fileName = '${safeTitle}_${video.id}.$extension';
      final filePath = '$downloadDir/$fileName';

      // Create cancel token for this download
      final cancelToken = CancelToken();
      cancelTokens[video.id] = cancelToken;

      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: headers ?? {},
          receiveTimeout: const Duration(minutes: 30),
        ),
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress[video.id] = progress;
            onProgress?.call(progress);
          }
        },
      );

      // Clean up
      cancelTokens.remove(video.id);
      downloadProgress.remove(video.id);

      return filePath;
    } catch (e) {
      cancelTokens.remove(video.id);
      downloadProgress.remove(video.id);
      
      if (e is DioException && e.type == DioExceptionType.cancel) {
        throw Exception('Download cancelled');
      }
      
      throw Exception('Download failed: ${e.toString()}');
    }
  }

  void cancelDownload(String videoId) {
    final cancelToken = cancelTokens[videoId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('User cancelled download');
    }
  }

  Future<bool> deleteDownloadedFile(String filePath) async {
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

  Future<List<FileSystemEntity>> getDownloadedFiles() async {
    try {
      final downloadDir = await getDownloadDirectory();
      final directory = Directory(downloadDir);
      
      if (await directory.exists()) {
        return directory.listSync();
      }
      return [];
    } catch (e) {
      print('Error listing downloaded files: $e');
      return [];
    }
  }

  Future<int> getTotalDownloadSize() async {
    try {
      final files = await getDownloadedFiles();
      int totalSize = 0;
      
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('Error calculating download size: $e');
      return 0;
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
