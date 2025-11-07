import 'package:get/get.dart';
import '../models/video_item.dart';
import '../services/storage_service.dart';

class FavoritesController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<VideoItem> favorites = <VideoItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    try {
      await _storage.init();
      final loadedFavorites = await _storage.getFavorites();
      favorites.value = loadedFavorites;
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addFavorite(VideoItem video) async {
    try {
      final success = await _storage.addFavorite(video);
      if (success) {
        favorites.insert(0, video);
        Get.snackbar(
          'Added to Favorites',
          video.title,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return success;
    } catch (e) {
      print('Error adding favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to add to favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> removeFavorite(String videoId) async {
    try {
      final success = await _storage.removeFavorite(videoId);
      if (success) {
        favorites.removeWhere((v) => v.id == videoId);
        Get.snackbar(
          'Removed from Favorites',
          'Video removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return success;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(VideoItem video) async {
    final isFav = await isFavorite(video.id);
    if (isFav) {
      return await removeFavorite(video.id);
    } else {
      return await addFavorite(video);
    }
  }

  Future<bool> isFavorite(String videoId) async {
    return favorites.any((v) => v.id == videoId);
  }

  bool isFavoriteSync(String videoId) {
    return favorites.any((v) => v.id == videoId);
  }
}
