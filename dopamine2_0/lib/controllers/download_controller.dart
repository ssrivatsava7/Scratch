import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../services/storage_service.dart';

class DownloadController extends GetxController {
  final downloads = <Map<String, dynamic>>[].obs;
  final downloadProgress = <String, double>{}.obs;

  final dio = Dio();

  final String backendUrl = "http://192.168.1.5:5000/yt/audio?url=";

  @override
  void onInit() {
    super.onInit();
    try {
      final data = StorageService.getDownloads();
      downloads.value = List<Map<String, dynamic>>.from(
        data.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}),
      );
    } catch (e) {
      print('Error loading downloads: $e');
      downloads.value = [];
    }
  }

  Future<String> _appDownloadDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory("${dir.path}/downloads");

    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }
    return downloadDir.path;
  }

  Future<void> addDownload(Map<String, dynamic> video) async {
    // Avoid duplicates
    if (downloads.any((e) => e["id"] == video["id"])) {
      Get.snackbar("Already Downloaded", video["title"]);
      return;
    }

    try {
      final url = "https://www.youtube.com/watch?v=${video["id"]}";
      final response = await http.get(Uri.parse("$backendUrl$url"));

      if (response.statusCode != 200) {
        Get.snackbar("Error", "Failed to download from backend");
        return;
      }

      final data = jsonDecode(response.body);

      final String fileName = data["filename"];
      final String filePath = data["path"];
      final File downloadedFile = File(filePath);

      // Move file into app download directory
      final String saveDir = await _appDownloadDir();
      final File savedFile =
          await downloadedFile.rename("$saveDir/$fileName");

      final entry = {
        "id": video["id"],
        "title": video["title"],
        "author": video["author"],
        "thumbnail": video["thumbnail"],
        "localPath": savedFile.path,
      };

      downloads.insert(0, entry);
      StorageService.saveDownloads(downloads);

      Get.snackbar("Downloaded", video["title"]);
    } catch (e) {
      Get.snackbar("Error", "Download failed: $e");
    }
  }

  Future<void> downloadAudio(Map<String, dynamic> video) async {
    // Alias method for addDownload
    await addDownload(video);
  }

  void removeDownload(Map item) {
    downloads.removeWhere((e) => e["id"] == item["id"]);
    StorageService.saveDownloads(downloads);
  }

  Future<void> startDownload(Map<String, dynamic> item) async {
    // Check if already downloading
    if (downloads.any((e) => e["id"] == item["id"])) {
      Get.snackbar(
        "Already Downloaded",
        "${item["title"]} is already in your downloads",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Add to downloads list
    downloads.insert(0, item);
    StorageService.saveDownloads(downloads);
    downloads.refresh();

    // Note: Actual file download would require additional implementation
    // For now, we're just adding to the downloads list
    print('Download started for: ${item["title"]}');
  }
}
