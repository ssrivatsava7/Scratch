import 'package:get/get.dart';
import '../models/media_item.dart';
import '../services/youtube_service.dart';

class SearchController extends GetxController {
  final results = <MediaItem>[].obs;
  final isLoading = false.obs;
  final query = ''.obs;
  final hasSearched = false.obs;

  void updateQuery(String value) {
    query.value = value;
  }

  void clearSearch() {
    query.value = '';
    results.clear();
    hasSearched.value = false;
  }

  Future<void> search(String searchQuery) async {
    if (searchQuery.trim().isEmpty) return;

    query.value = searchQuery;
    isLoading.value = true;
    hasSearched.value = true;
    results.clear();

    try {
      final searchResults = await YouTubeService.search(searchQuery);

      results.value = searchResults.map((item) {
        return MediaItem(
          videoUrl: item['videoUrl'] ?? '',
          title: item['title'] ?? '',
          thumbnailUrl: item['thumbnail'] ?? '',
          channelName: item['author'] ?? '',
          audioUrl: item['videoUrl'] ?? '',
          duration: Duration(seconds: item['duration'] ?? 0),
        );
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get stream URLs for a video
  Future<Map<String, String?>> getStreamUrls(String videoId) async {
    try {
      return await YouTubeService.getStreamUrls(videoId);
    } catch (e) {
      return {'audioUrl': null, 'videoUrl': null};
    }
  }
}
