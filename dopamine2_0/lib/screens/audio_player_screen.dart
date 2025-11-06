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
            onPressed: () {
              Get.to(() => SettingsScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
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

          // Error display
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

          // Loading indicator
          Obx(() {
            if (audioController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          }),

          // Playback controls
          Obx(() {
            if (audioController.isPlaying.value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause, size: 32),
                    onPressed: () => audioController.togglePlayback(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 32),
                    onPressed: () => audioController.stopPlayback(),
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.play_arrow, size: 48),
                onPressed: () => audioController.togglePlayback(),
              );
            }
          }),

          // Display search results
          Expanded(
            child: Obx(() {
              if (audioController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "Search for songs to get started!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: audioController.searchResults.length,
                itemBuilder: (context, index) {
                  var video = audioController.searchResults[index];
                  return _buildVideoCard(context, video);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

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
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Play Audio'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'video',
              child: Row(
                children: [
                  Icon(Icons.video_library),
                  SizedBox(width: 8),
                  Text('Play Video'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(Icons.favorite),
                  SizedBox(width: 8),
                  Text('Add to Favorites'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'playlist',
              child: Row(
                children: [
                  Icon(Icons.playlist_add),
                  SizedBox(width: 8),
                  Text('Add to Playlist'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'play':
                audioController.loadAudio(
                  video.id.toString(),
                  title: video.title,
                  author: video.author,
                );
                break;
              case 'video':
                Get.to(() => VideoPlayerScreen(
                      videoId: video.id.toString(),
                      videoTitle: video.title,
                    ));
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
        onTap: () {
          audioController.loadAudio(
            video.id.toString(),
            title: video.title,
            author: video.author,
          );
        },
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, VideoItem video) {
    if (playlistController.playlists.isEmpty) {
      Get.snackbar(
        'No Playlists',
        'Create a playlist first',
        snackPosition: SnackPosition.BOTTOM,
      );
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
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, VideoItem video) {
    String selectedQuality = '720p';
    bool isAudioOnly = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Download'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedQuality,
                  decoration: const InputDecoration(
                    labelText: 'Quality',
                  ),
                  items: ['360p', '480p', '720p', '1080p']
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child: Text(q),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedQuality = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isAudioOnly,
                  title: const Text('Audio Only'),
                  onChanged: (value) {
                    setState(() => isAudioOnly = value ?? false);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  downloadController.startDownload(
                    video,
                    quality: selectedQuality,
                    isAudioOnly: isAudioOnly,
                  );
                  Get.back();
                },
                child: const Text('Download'),
              ),
            ],
          );
        },
      ),
    );
  }
}

  AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dopamine 2.0 - YouTube Audio Player"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar
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

          // Error display
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

          // Loading indicator
          Obx(() {
            if (audioController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          }),

          // Playback controls
          Obx(() {
            if (audioController.isPlaying.value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause, size: 32),
                    onPressed: () => audioController.togglePlayback(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 32),
                    onPressed: () => audioController.stopPlayback(),
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.play_arrow, size: 48),
                onPressed: () => audioController.togglePlayback(),
              );
            }
          }),

          // Display search results
          Expanded(
            child: Obx(() {
              if (audioController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "Search for songs to get started!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: audioController.searchResults.length,
                itemBuilder: (context, index) {
                  var video = audioController.searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
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
                            icon: const Icon(Icons.video_library),
                            onPressed: () {
                              Get.to(() => VideoPlayerScreen(
                                    videoId: video.id.toString(),
                                    videoTitle: video.title,
                                  ));
                            },
                          ),
                          const Icon(Icons.play_arrow),
                        ],
                      ),
                      onTap: () {
                        audioController.loadAudio(video.id.toString());
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
