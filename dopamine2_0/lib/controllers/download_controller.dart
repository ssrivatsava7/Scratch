import 'package:get/get.dart';

import '../services/storage_service.dart';

class DownloadController extends GetxController {
  final downloads = <Map<String, dynamic>>[].obs;

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

  void addDownload(Map<String, dynamic> item) {
    // Check for duplicates by id or videoId
    final id = item['id'] ?? item['videoId'];
    if (downloads.any((e) => (e['id'] == id || e['videoId'] == id))) {
      print('Item already in downloads');
      return;
    }

    // Add to the beginning of the list
    downloads.insert(0, item);
    
    // Save to storage
    StorageService.saveDownloads(downloads);
    
    // Refresh the observable list
    downloads.refresh();
    
    print('Added to downloads: ${item['title']}');
  }

  void removeDownload(Map item) {
    final id = item['id'] ?? item['videoId'];
    downloads.removeWhere((e) => (e['id'] == id || e['videoId'] == id));
    StorageService.saveDownloads(downloads);
    downloads.refresh();
  }
}
