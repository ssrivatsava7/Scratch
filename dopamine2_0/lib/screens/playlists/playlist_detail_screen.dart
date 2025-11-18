import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playlist_controller.dart';
import '../../controllers/mini_player_controller.dart';
import '../../controllers/mini_player_controller.dart' show MediaItem;
import '../../theme/midnight_aurora_theme.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlaylistController playlistController = Get.find();
    
    // Get playlist name from route parameters
    final String playlistName = Get.parameters['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(playlistName),
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              final tracks = playlistController.getPlaylistTracks(playlistName);
              if (tracks.isNotEmpty) {
                // Play first track
                Get.toNamed('/audio-player', arguments: tracks[0]);
              }
            },
            tooltip: 'Play All',
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              final tracks = playlistController.getPlaylistTracks(playlistName);
              if (tracks.isNotEmpty) {
                tracks.shuffle();
                // Play first shuffled track
                Get.toNamed('/audio-player', arguments: tracks[0]);
              }
            },
            tooltip: 'Shuffle',
          ),
        ],
      ),
      body: Obx(() {
        final tracks = playlistController.getPlaylistTracks(playlistName);
        
        if (tracks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No tracks in this playlist',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: tracks.length,
          padding: const EdgeInsets.only(bottom: 100),
          itemBuilder: (context, index) {
            final track = tracks[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
                  ),
                ),
                child: track['thumbnail'] != null || track['thumbnailUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          track['thumbnail'] ?? track['thumbnailUrl'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.music_note, color: Colors.white);
                          },
                        ),
                      )
                    : const Icon(Icons.music_note, color: Colors.white),
              ),
              title: Text(
                track['title'] ?? 'Unknown Track',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                track['artist'] ?? track['channelTitle'] ?? 'Unknown Artist',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red.withOpacity(0.7),
                    onPressed: () {
                      playlistController.removeFromPlaylist(playlistName, track);
                    },
                    tooltip: 'Remove from playlist',
                  ),
                ],
              ),
              onTap: () {
                // Navigate to audio player with the track
                Get.toNamed('/audio-player', arguments: track);
              },
            );
          },
        );
      }),
    );
  }
}