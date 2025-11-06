import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/video_item.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/audio_controller.dart';
import 'video_player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoritesController favoritesController = Get.put(FavoritesController());
  final AudioController audioController = Get.find<AudioController>();

  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.red,
      ),
      body: Obx(() {
        if (favoritesController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (favoritesController.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add videos to favorites to see them here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: favoritesController.favorites.length,
          itemBuilder: (context, index) {
            final video = favoritesController.favorites[index];
            return _buildVideoCard(context, video);
          },
        );
      }),
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoItem video) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.music_note, color: Colors.white),
        ),
        title: Text(
          video.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(video.author),
            if (video.duration != null)
              Text(
                "${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.video_library, color: Colors.blue),
              onPressed: () {
                Get.to(() => VideoPlayerScreen(
                      videoId: video.id,
                      videoTitle: video.title,
                    ));
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                favoritesController.removeFavorite(video.id);
              },
            ),
          ],
        ),
        onTap: () {
          audioController.loadAudio(
            video.id,
            title: video.title,
            author: video.author,
          );
        },
      ),
    );
  }
}
