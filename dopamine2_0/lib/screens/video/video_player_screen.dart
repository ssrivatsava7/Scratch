import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../utils/controller_helper.dart';
import '../../services/download_service.dart';
import '../../routes/app_routes.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = Controllers.mediaSwitch;
    final args = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          Center(
            child: Video(
              controller: media.videoController,
            ),
          ),

          // Top Bar with back button and switch to audio
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Get.back(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white, size: 28),
                      onPressed: () => Get.offAllNamed('/'),
                      tooltip: 'Home',
                    ),
                    const Spacer(),
                    // Favorite button
                    IconButton(
                      icon: Icon(
                        args != null && Controllers.favorites.favorites.any(
                          (fav) => (fav['id'] == (args['id'] ?? args['videoId'])) ||
                                   (fav['videoId'] == (args['id'] ?? args['videoId']))
                        ) ? Icons.favorite : Icons.favorite_border,
                        color: args != null && Controllers.favorites.favorites.any(
                          (fav) => (fav['id'] == (args['id'] ?? args['videoId'])) ||
                                   (fav['videoId'] == (args['id'] ?? args['videoId']))
                        ) ? Colors.red : Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        if (args != null) {
                          Controllers.favorites.toggleFavorite(args);
                        }
                      },
                      tooltip: 'Toggle Favorite',
                    ),
                    // Add to playlist
                    IconButton(
                      icon: const Icon(Icons.playlist_add, color: Colors.white, size: 24),
                      onPressed: () {
                        if (args != null) {
                          _showAddToPlaylistDialog(args);
                        }
                      },
                      tooltip: 'Add to Playlist',
                    ),
                    // Download
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white, size: 24),
                      onPressed: () {
                        if (args != null) {
                          _downloadMedia(args);
                        }
                      },
                      tooltip: 'Download',
                    ),
                    // Switch to audio
                    IconButton(
                      icon: const Icon(Icons.music_note, color: Colors.white, size: 28),
                      onPressed: () {
                        media.switchToAudio();
                        Get.back();
                        Get.toNamed(Routes.AUDIO_PLAYER, arguments: args);
                      },
                      tooltip: 'Switch to Audio',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      media.currentTitle.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: Colors.purpleAccent,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.purpleAccent,
                      ),
                      child: Slider(
                        value: media.position.value.inSeconds.toDouble(),
                        max: media.duration.value.inSeconds > 0
                            ? media.duration.value.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          media.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),

                    // Time Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(media.position.value),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(media.duration.value),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                          onPressed: () {
                            final newPos = media.position.value - const Duration(seconds: 10);
                            media.seek(newPos < Duration.zero ? Duration.zero : newPos);
                          },
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.purpleAccent, Colors.deepPurple],
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              media.isPlaying.value ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              if (media.isPlaying.value) {
                                media.pause();
                              } else {
                                media.play();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                          onPressed: () {
                            final newPos = media.position.value + const Duration(seconds: 10);
                            media.seek(newPos > media.duration.value ? media.duration.value : newPos);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(Map<String, dynamic> item) {
    final playlists = Controllers.playlist.playlists;
    
    if (playlists.isEmpty) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('No Playlists', style: TextStyle(color: Colors.white)),
          content: const Text(
            'You don\'t have any playlists yet. Create one first!',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK', style: TextStyle(color: Colors.purpleAccent)),
            ),
          ],
        ),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Add to Playlist', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                title: Text(
                  playlist['name'] ?? 'Unnamed Playlist',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.add, color: Colors.purpleAccent),
                onTap: () {
                  Controllers.playlist.addToPlaylist(
                    playlist['name'],
                    item,
                  );
                  Get.back();
                  Get.snackbar(
                    'Added',
                    'Added to ${playlist['name']}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _downloadMedia(Map<String, dynamic> item) async {
    final videoId = item['id'] ?? item['videoId'] ?? '';
    final title = item['title'] ?? 'Unknown';
    final thumbnail = item['thumbnail'] ?? '';
    
    if (videoId.isEmpty) {
      Get.snackbar(
        'Download Error',
        'Missing video ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Check if already downloaded
    if (Controllers.download.downloads.any((d) => d.videoId == videoId)) {
      Get.snackbar(
        'Already Downloaded',
        'This media is already in your downloads',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Create download item and start download
    final downloadItem = {
      'videoId': videoId,
      'title': title,
      'thumbnail': thumbnail,
      'artist': item['author'] ?? item['channelName'],
      'album': item['album'],
      'duration': item['duration'],
    };

    // Add to downloads - this will trigger actual file download
    await Controllers.download.addDownload(downloadItem);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

