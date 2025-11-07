import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/download_controller.dart';
import '../models/video_item.dart';
import 'video_player_screen.dart';
import 'settings_screen.dart';

class AudioPlayerScreen extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());
  final FavoritesController favoritesController = Get.put(FavoritesController());
  final PlaylistController playlistController = Get.put(PlaylistController());
  final DownloadController downloadController = Get.put(DownloadController());
  final TextEditingController searchController = TextEditingController();

  AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dopamine 2.0 - YouTube Audio Player"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => SettingsScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a song...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.trim().isNotEmpty) {
                      audioController.searchVideos(searchController.text.trim());
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  audioController.searchVideos(value.trim());
                }
              },
            ),
          ),

          // ❗ Error Display
          Obx(() {
            if (audioController.currentError.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        audioController.currentError.value,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => audioController.clearError(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // ⏳ Loading Indicator
          Obx(() {
            if (audioController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          }),

          // ▶ Playback Controls
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    size: 48,
                  ),
                  onPressed: () => audioController.togglePlayback(),
                ),
                IconButton(
                  icon: const Icon(Icons.stop, size: 32),
                  onPressed: () => audioController.stopPlayback(),
                ),
              ],
            );
          }),

          // 🎵 Display Search Results
          Expanded(
            child: Obx(() {
              final results = audioController.searchResults;

              if (results.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.music_note, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Search for songs to get started!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final video = results[index];
                  return _buildVideoCard(context, video);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🎶 Video Card Builder
  Widget _buildVideoCard(BuildContext context, video) {
    final videoItem = VideoItem(
      id: video.id.toString(),
      title: video.title,
      author: video.author,
      duration: video.duration,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.music_note, color: Colors.white),
        ),
        title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
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
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(value: 'play', child: _menuItem(Icons.play_arrow, "Play Audio")),
            PopupMenuItem(value: 'video', child: _menuItem(Icons.video_library, "Play Video")),
            PopupMenuItem(value: 'favorite', child: _menuItem(Icons.favorite, "Add to Favorites")),
            PopupMenuItem(value: 'playlist', child: _menuItem(Icons.playlist_add, "Add to Playlist")),
            PopupMenuItem(value: 'download', child: _menuItem(Icons.download, "Download")),

          ],
          onSelected: (value) {
            switch (value) {
              case 'play':
                audioController.loadAudio(video.id.toString(), title: video.title, author: video.author);
                break;
              case 'video':
                Get.to(() => VideoPlayerScreen(videoId: video.id.toString(), videoTitle: video.title));
                break;
              case 'favorite':
                favoritesController.addFavorite(videoItem);
                break;
              case 'playlist':
                _showAddToPlaylistDialog(context, videoItem);
                break;
              case 'download':
                _showDownloadDialog(context, videoItem);
                break;
            }
          },
        ),
        onTap: () => audioController.loadAudio(video.id.toString(), title: video.title, author: video.author),
      ),
    );
  }

  static Widget _menuItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // ➕ Playlist Dialog
  void _showAddToPlaylistDialog(BuildContext context, VideoItem video) {
    if (playlistController.playlists.isEmpty) {
      Get.snackbar('No Playlists', 'Create a playlist first', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Add to Playlist'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlistController.playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlistController.playlists[index];
              return ListTile(
                leading: const Icon(Icons.playlist_play),
                title: Text(playlist.name),
                subtitle: Text('${playlist.videos.length} videos'),
                onTap: () {
                  playlistController.addVideoToPlaylist(playlist.id, video);
                  Get.back();
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))],
      ),
    );
  }

  // ⬇ Download Dialog
  void _showDownloadDialog(BuildContext context, VideoItem video) {
    String selectedQuality = '720p';
    bool isAudioOnly = false;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Download'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedQuality,
                decoration: const InputDecoration(labelText: 'Quality'),
                items: ['360p', '480p', '720p', '1080p']
                    .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                    .toList(),
                onChanged: (value) => setState(() => selectedQuality = value ?? '720p'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: isAudioOnly,
                title: const Text('Audio Only'),
                onChanged: (value) => setState(() => isAudioOnly = value ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                downloadController.startDownload(video, quality: selectedQuality, isAudioOnly: isAudioOnly);
                Get.back();
              },
              child: const Text('Download'),
            ),
          ],
        );
      }),
    );
  }
}
