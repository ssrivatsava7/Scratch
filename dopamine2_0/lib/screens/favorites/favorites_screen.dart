import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/controller_helper.dart';
import '../../widgets/dopamine_app_bar.dart';
import '../../controllers/search_controller.dart' as my_search;
import '../../routes/app_routes.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = Controllers.favorites;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: DopamineAppBar(
        title: 'Favorites',
        showHomeButton: true,
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
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showRemoveConfirmation(item);
                },
                tooltip: 'Remove from favorites',
              ),
              onTap: () => _playMedia(item),
            );
          },
        );
      }),
    );
  }

  void _playMedia(Map<String, dynamic> item) {
    final media = Controllers.mediaSwitch;
    final history = Controllers.history;

    try {
      // Extract video ID
      String videoId = item['id'] ?? item['videoId'] ?? '';
      
      // If ID is missing but URL is present, extract from URL
      if (videoId.isEmpty) {
          final url = item['videoUrl'] ?? item['audioUrl'] ?? '';
          if (url.contains('v=')) {
              videoId = url.split('v=').last.split('&').first;
          }
      }

      if (videoId.isEmpty) {
          Get.snackbar('Error', 'Invalid media ID', snackPosition: SnackPosition.BOTTOM);
          return;
      }

      history.addToHistory(item);

      // Navigate immediately
      Get.toNamed(Routes.AUDIO_PLAYER, arguments: item);

      // Load media in background
      media.loadMediaFromId(
        videoId: videoId,
        title: item['title'] ?? '',
        thumbnail: item['thumbnail'] ?? '',
        author: item['author'] ?? '',
        isVideoMode: false,
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to load media: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showRemoveConfirmation(Map<String, dynamic> item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Remove from Favorites', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${item['title']}" from favorites?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Controllers.favorites.removeFavorite(item);
              Get.back();
              Get.snackbar(
                'Removed',
                '${item['title']} removed from favorites',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
