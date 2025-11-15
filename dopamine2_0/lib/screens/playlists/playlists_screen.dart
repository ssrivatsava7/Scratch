import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/playlist_controller.dart';
import '../../routes/app_routes.dart';

class PlaylistsScreen extends StatelessWidget {
  PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistController = Get.find<PlaylistController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Playlists', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreatePlaylistDialog(playlistController),
          ),
        ],
      ),
      body: Obx(() {
        if (playlistController.playlists.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.playlist_play, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text(
                  'No playlists yet',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to create a playlist',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: playlistController.playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlistController.playlists[index];
            final playlistName = playlist["name"] ?? "Unknown";
            final items = playlist["items"];
            final trackCount = (items is List) ? items.length : 0;

            return ListTile(
              leading: const Icon(Icons.folder, color: Colors.purpleAccent, size: 40),
              title: Text(
                playlistName,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              subtitle: Text(
                '$trackCount tracks',
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeletePlaylistDialog(playlistController, playlistName),
              ),
              onTap: () {
                Get.toNamed(Routes.PLAYLIST_DETAIL, arguments: playlistName);
              },
            );
          },
        );
      }),
    );
  }

  void _showCreatePlaylistDialog(PlaylistController controller) {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Create Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.createPlaylist(textController.text.trim());
                Get.back();
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  void _showDeletePlaylistDialog(PlaylistController controller, String playlistName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$playlistName"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              controller.deletePlaylist(playlistName);
              Get.back();
              Get.snackbar(
                'Deleted',
                '"$playlistName" has been deleted',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
