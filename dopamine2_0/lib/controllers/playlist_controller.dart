import 'package:get/get.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../services/storage_service.dart';

class PlaylistController extends GetxController {
  final StorageService _storage = StorageService();
  final RxList<Playlist> playlists = <Playlist>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    isLoading.value = true;
    try {
      await _storage.init();
      final loadedPlaylists = await _storage.getPlaylists();
      playlists.value = loadedPlaylists;
    } catch (e) {
      print('Error loading playlists: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPlaylist(String name, {String? description}) async {
    try {
      final playlist = Playlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
      );
      
      final success = await _storage.addPlaylist(playlist);
      if (success) {
        playlists.add(playlist);
        Get.snackbar(
          'Playlist Created',
          name,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return success;
    } catch (e) {
      print('Error creating playlist: $e');
      Get.snackbar(
        'Error',
        'Failed to create playlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> deletePlaylist(String playlistId) async {
    try {
      final success = await _storage.deletePlaylist(playlistId);
      if (success) {
        playlists.removeWhere((p) => p.id == playlistId);
        Get.snackbar(
          'Playlist Deleted',
          'Playlist has been deleted',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return success;
    } catch (e) {
      print('Error deleting playlist: $e');
      return false;
    }
  }

  Future<bool> updatePlaylistInfo(String playlistId, String name, {String? description}) async {
    try {
      final playlist = playlists.firstWhere((p) => p.id == playlistId);
      playlist.name = name;
      playlist.description = description;
      playlist.updatedAt = DateTime.now();
      
      final success = await _storage.updatePlaylist(playlist);
      if (success) {
        playlists.refresh();
      }
      return success;
    } catch (e) {
      print('Error updating playlist: $e');
      return false;
    }
  }

  Future<bool> addVideoToPlaylist(String playlistId, VideoItem video) async {
    try {
      final playlist = playlists.firstWhere((p) => p.id == playlistId);
      
      if (playlist.videos.any((v) => v.id == video.id)) {
        Get.snackbar(
          'Already in Playlist',
          'Video is already in this playlist',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      
      playlist.addVideo(video);
      final success = await _storage.updatePlaylist(playlist);
      
      if (success) {
        playlists.refresh();
        Get.snackbar(
          'Added to Playlist',
          '${video.title} added to ${playlist.name}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return success;
    } catch (e) {
      print('Error adding video to playlist: $e');
      Get.snackbar(
        'Error',
        'Failed to add video to playlist',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> removeVideoFromPlaylist(String playlistId, String videoId) async {
    try {
      final playlist = playlists.firstWhere((p) => p.id == playlistId);
      playlist.removeVideo(videoId);
      
      final success = await _storage.updatePlaylist(playlist);
      if (success) {
        playlists.refresh();
      }
      return success;
    } catch (e) {
      print('Error removing video from playlist: $e');
      return false;
    }
  }

  Playlist? getPlaylist(String playlistId) {
    try {
      return playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }
}
