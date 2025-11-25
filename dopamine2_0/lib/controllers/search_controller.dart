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

  // Get stream URLs for a video with quality selection (supports 1080p, 4K, etc.)
  Future<Map<String, String?>> getStreamUrls(String videoId, {String videoQuality = '720p'}) async {
    try {
      // Normalize quality string (remove special labels like "(4K)" and "(2K)")
      final normalizedQuality = videoQuality
          .replaceAll(' (4K)', '')
          .replaceAll(' (2K)', '');
      
      return await YouTubeService.getStreamUrls(videoId, videoQuality: normalizedQuality);
    } catch (e) {
      print('Error getting stream URLs: $e');
      return {'audioUrl': null, 'videoUrl': null};
    }
  }

  // Get available video qualities (including 1080p, 4K)
  Future<List<String>> getAvailableQualities(String videoId) async {
    try {
      return await YouTubeService.getAvailableQualities(videoId);
    } catch (e) {
      print('Error getting available qualities: $e');
      return ['1080p', '720p', '480p', '360p']; // Updated default fallback
    }
  }
}
