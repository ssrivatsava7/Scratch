import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/controller_helper.dart';
import '../../widgets/dopamine_app_bar.dart';
import '../../models/media_item.dart';
import '../../routes/app_routes.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = Get.parameters['name'] ?? Get.arguments?['name'] ?? '';
    
    if (name.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Error', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('Playlist name not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Obx(() {
      final playlist = Controllers.playlist.playlists.firstWhere((p) => p['name'] == name, orElse: () => {});

      if (playlist.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: DopamineAppBar(title: name),
          body: const Center(child: Text('Playlist not found', style: TextStyle(color: Colors.white54))),
        );
      }

      final itemsKey = playlist.containsKey('items') ? 'items' : 'tracks';
      final items = playlist[itemsKey] ?? [];

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: DopamineAppBar(title: name),
        body: items.isEmpty
            ? const Center(child: Text('No tracks in this playlist', style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final mediaItem = MediaItem.fromJson(item);

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        mediaItem.thumbnailUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(width: 60, height: 60, color: Colors.grey[800], child: const Icon(Icons.music_note, color: Colors.white54)),
                      ),
                    ),
                    title: Text(mediaItem.title, style: const TextStyle(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(mediaItem.channelName, style: const TextStyle(color: Colors.white54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.purpleAccent),
                          onPressed: () async {
                            Controllers.history.addToHistory(item);
                            await Controllers.mediaSwitch.loadMedia(
                              title: mediaItem.title,
                              thumbnail: mediaItem.thumbnailUrl,
                              audio: mediaItem.audioUrl,
                              video: mediaItem.videoUrl,
                            );
                            Get.toNamed(Routes.AUDIO_PLAYER, arguments: item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.videocam, color: Colors.purpleAccent),
                          onPressed: () async {
                            await Controllers.mediaSwitch.loadMedia(title: mediaItem.title, thumbnail: mediaItem.thumbnailUrl, audio: mediaItem.audioUrl, video: mediaItem.videoUrl);
                            Controllers.mediaSwitch.switchToVideo();
                            Get.toNamed(Routes.VIDEO_PLAYER, arguments: item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.playlist_remove, color: Colors.red),
                          onPressed: () => _showRemoveDialog(name, item),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    });
  }

  void _showRemoveDialog(String playlistName, Map<String, dynamic> item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Remove from Playlist', style: TextStyle(color: Colors.white)),
        content: Text('Remove "${item['title']}" from "$playlistName"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              Get.back();
              Controllers.playlist.removeFromPlaylist(playlistName, item);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
