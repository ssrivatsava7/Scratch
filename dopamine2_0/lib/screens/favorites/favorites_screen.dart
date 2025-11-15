import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorites_controller.dart';
import '../../controllers/media_switch_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/search_controller.dart' as my_search;
import '../../routes/app_routes.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Favorites', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (fav.favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: fav.favorites.length,
          itemBuilder: (context, index) {
            final item = fav.favorites[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['thumbnail'] ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note, color: Colors.white54),
                    );
                  },
                ),
              ),
              title: Text(
                item['title'] ?? 'Unknown',
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item['author'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  fav.removeFavorite(item);
                },
              ),
              onTap: () => _playMedia(item),
            );
          },
        );
      }),
    );
  }

  Future<void> _playMedia(Map<String, dynamic> item) async {
    final media = Get.find<MediaSwitchController>();
    final history = Get.find<HistoryController>();

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );

    try {
      String audioUrl = item['audioUrl'] ?? '';
      String videoUrl = item['videoUrl'] ?? '';

      if (audioUrl.contains('youtube.com') || audioUrl.contains('youtu.be')) {
        final videoId = audioUrl.split('v=').last.split('&').first;
        final controller = Get.find<my_search.SearchController>();
        final streams = await controller.getStreamUrls(videoId);
        audioUrl = streams['audioUrl'] ?? '';
        videoUrl = streams['videoUrl'] ?? audioUrl;

        item['audioUrl'] = audioUrl;
        item['videoUrl'] = videoUrl;
      }

      Get.back();

      if (audioUrl.isEmpty) {
        Get.snackbar('Error', 'Could not get audio stream',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      history.addToHistory(item);

      media.loadMedia(
        title: item['title'] ?? '',
        thumbnail: item['thumbnail'] ?? '',
        audio: audioUrl,
        video: videoUrl,
      );

      Get.toNamed(Routes.AUDIO_PLAYER, arguments: item);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to load media: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
