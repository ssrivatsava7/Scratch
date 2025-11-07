import 'package:get/get.dart';
import '../models/video_item.dart';
import '../services/storage_service.dart';

class HistoryController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<VideoItem> history = <VideoItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      await _storage.init();
      final loadedHistory = await _storage.getHistory();
      history.value = loadedHistory;
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToHistory(VideoItem video) async {
    try {
      await _storage.addToHistory(video);
      
      // Update local list
      history.removeWhere((v) => v.id == video.id);
      history.insert(0, video);
      
      // Keep only last 100 items
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }
    } catch (e) {
      print('Error adding to history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      await _storage.clearHistory();
      history.clear();
      Get.snackbar(
        'History Cleared',
        'All history has been cleared',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error clearing history: $e');
      Get.snackbar(
        'Error',
        'Failed to clear history',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeFromHistory(String videoId) async {
    try {
      history.removeWhere((v) => v.id == videoId);
      await _storage.saveHistory(history);
    } catch (e) {
      print('Error removing from history: $e');
    }
  }
}
