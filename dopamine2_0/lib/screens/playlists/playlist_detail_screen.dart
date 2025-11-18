import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/media_item.dart';
import '../../widgets/dopamine_app_bar.dart';
import '../../utils/controller_helper.dart';
import '../../widgets/dopamine_app_bar.dart';
import '../../models/media_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/midnight_aurora_theme.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistController = Controllers.playlist;
    final String playlistName = Get.arguments as String;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: DopamineAppBar(
        title: playlistName,
        showHomeButton: true,
      ),
      body: Obx(() {
        final playlist = playlistController.playlists.firstWhereOrNull(
          (e) => e["name"] == playlistName,
        );

        if (playlist == null) {
          return const Center(
            child: Text(
              'Playlist not found',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          );
        }

        final itemsList = playlist["items"];
        final items = (itemsList is List) ? itemsList : [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.playlist_add, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'Playlist is empty',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final itemMap = item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{};
            
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  itemMap['thumbnail'] ?? '',
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
                itemMap['title'] ?? 'Unknown',
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                itemMap['author'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.purpleAccent),
                        onPressed: () async {
                          Controllers.history.addToHistory(item);

                          final mediaItem = MediaItem.fromJson(item);
                          await Controllers.mediaSwitch.loadMedia(
                            title: mediaItem.title,
                            thumbnail: mediaItem.thumbnailUrl,
                            audio: mediaItem.audioUrl,
                            video: mediaItem.videoUrl,
                          );

                          Get.toNamed(Routes.AUDIO_PLAYER, arguments: item);
                        },
                        tooltip: 'Play Audio',
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Colors.purpleAccent),
                        onPressed: () async {
                          final mediaItem = MediaItem.fromJson(item);
                          await Controllers.mediaSwitch.loadMedia(
                            title: mediaItem.title,
                            thumbnail: mediaItem.thumbnailUrl,
                            audio: mediaItem.audioUrl,
                            video: mediaItem.videoUrl,
                          );
                          Controllers.mediaSwitch.switchToVideo();
                          Get.toNamed(Routes.VIDEO_PLAYER, arguments: item);
                        },
                        tooltip: 'Play Video',
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          _showRemoveConfirmation(item);
                        },
                        tooltip: 'Remove from Playlist',
                      ),
                    ],
                  ),
              onTap: () => _playMedia(itemMap),
            );
          },
        );
      }),
    );
  }

  Future<void> _playMedia(Map<String, dynamic> item) async {
    final media = Controllers.mediaSwitch;
    final history = Controllers.history;

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );

    try {
      String audioUrl = item['audioUrl'] ?? '';
      String videoUrl = item['videoUrl'] ?? '';

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

  void _showRemoveConfirmation(Map<String, dynamic> item) {
    final playlistName = Get.parameters['name'] ?? '';
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Remove from Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${item['title'] ?? 'this item'}" from "$playlistName"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Controllers.playlist.removeFromPlaylist(playlistName, item);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
