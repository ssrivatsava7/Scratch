import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/playlist.dart';
import '../models/video_item.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/audio_controller.dart';
import 'video_player_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  final PlaylistController playlistController = Get.find<PlaylistController>();
  final AudioController audioController = Get.find<AudioController>();

  PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        backgroundColor: Colors.green,
      ),
      body: Obx(() {
        // Refresh playlist from controller
        final currentPlaylist = playlistController.getPlaylist(playlist.id);
        
        if (currentPlaylist == null) {
          return const Center(child: Text('Playlist not found'));
        }

        if (currentPlaylist.videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.playlist_play, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No videos in this playlist',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add videos from search results',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Playlist info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const Icon(Icons.playlist_play, size: 48, color: Colors.green),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentPlaylist.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentPlaylist.description != null)
                          Text(
                            currentPlaylist.description!,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        Text(
                          '${currentPlaylist.videos.length} videos',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Video list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: currentPlaylist.videos.length,
                itemBuilder: (context, index) {
                  final video = currentPlaylist.videos[index];
                  return _buildVideoCard(context, video, currentPlaylist.id, index);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoItem video, String playlistId, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
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
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                playlistController.removeVideoFromPlaylist(playlistId, video.id);
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
