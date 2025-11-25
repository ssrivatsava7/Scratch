import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/controller_helper.dart';
import '../../widgets/dopamine_app_bar.dart';
import '../../widgets/video_quality_selector.dart';
import '../../services/download_service.dart';
import '../../routes/app_routes.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = Controllers.mediaSwitch;
    final args = Get.arguments as Map<String, dynamic>?;

    // Initialize audio playback when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (args != null) {
        _initializeAudio(args);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: DopamineAppBar(
        title: 'Audio Player',
        showHomeButton: true,
        actions: [
          // Video quality button
          Obx(() {
            if (media.isVideo.value && args != null) {
              return IconButton(
                icon: const Icon(Icons.high_quality, color: Colors.blue),
                onPressed: () {
                  _showQualitySelector(args);
                },
                tooltip: 'Video Quality',
              );
            }
            return const SizedBox.shrink();
          }),
          // Test audio button
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.amber),
            onPressed: () {
              media.testAudioOutput();
            },
            tooltip: 'Test Audio Output',
          ),
          // Favorite button
          Obx(() {
            final videoId = args != null ? (args['id'] ?? args['videoId'] ?? '') : '';
            if (videoId.isEmpty) {
               return IconButton(
                 icon: const Icon(Icons.favorite_border),
                 onPressed: () {},
               );
            }
            
            final isFavorite = Controllers.favorites.favorites.any(
              (fav) => (fav['id'] == videoId || fav['videoId'] == videoId)
            );
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                if (args != null) {
                  Controllers.favorites.toggleFavorite(args);
                }
              },
              tooltip: 'Toggle Favorite',
            );
          }),
          // Add to playlist button
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              if (args != null) {
                _showAddToPlaylistDialog(args);
              } else {
                Get.snackbar('Error', 'No media information available',
                  snackPosition: SnackPosition.BOTTOM);
              }
            },
            tooltip: 'Add to Playlist',
          ),
          // Download button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              if (args != null) {
                _downloadMedia(args);
              } else {
                Get.snackbar('Error', 'No media information available',
                  snackPosition: SnackPosition.BOTTOM);
              }
            },
            tooltip: 'Download',
          ),
          // Switch to video
          IconButton(
            icon: const Icon(Icons.video_library),
            onPressed: () {
              media.switchToVideo();
              Get.toNamed(Routes.VIDEO_PLAYER, arguments: args);
            },
            tooltip: 'Switch to Video',
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            const Spacer(),

            // Album Art
            Container(
              width: 300,
              height: 300,
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: media.currentThumbnail.value.isNotEmpty
                    ? Image.network(
                        media.currentThumbnail.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.music_note,
                              size: 100,
                              color: Colors.white54,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.music_note,
                          size: 100,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                media.currentTitle.value.isNotEmpty
                    ? media.currentTitle.value
                    : 'No media playing',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 32),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: Colors.purpleAccent,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.purpleAccent,
                    ),
                    child: Slider(
                      value: media.position.value.inSeconds.toDouble().clamp(
                        0.0, 
                        media.duration.value.inSeconds > 0 ? media.duration.value.inSeconds.toDouble() : 1.0
                      ),
                      max: media.duration.value.inSeconds > 0
                          ? media.duration.value.inSeconds.toDouble()
                          : 1.0,
                      onChanged: (value) {
                        media.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(media.position.value),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(media.duration.value),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Controls
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
                  width: 80,
                  height: 80,
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
                      size: 40,
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

            const Spacer(),
          ],
        );
      }),
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

  void _initializeAudio(Map<String, dynamic> item) async {
    var videoId = item['id'] ?? item['videoId'] ?? '';
    final title = item['title'] ?? 'Unknown';
    final thumbnail = item['thumbnail'] ?? item['thumbnails']?[0]?['url'] ?? '';
    
    // Extract video ID from URL if it's a full URL
    if (videoId.contains('youtube.com/watch?v=')) {
      videoId = videoId.split('v=')[1].split('&')[0];
    } else if (videoId.contains('youtu.be/')) {
      videoId = videoId.split('youtu.be/')[1].split('?')[0];
    }
    
    if (videoId.isEmpty) {
      Get.snackbar(
        'Error',
        'Invalid media item',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('=== AUDIO PLAYER: INITIALIZING AUDIO ===');
    print('Video ID (cleaned): $videoId');
    print('Title: $title');

    // Check if already playing or loading this media
    if (Controllers.mediaSwitch.currentTitle.value == title && 
        (Controllers.mediaSwitch.isPlaying.value || Controllers.mediaSwitch.isLoading.value)) {
      print('Media already loaded/loading. Skipping initialization.');
      return;
    }

    // Update media controller with current info
    Controllers.mediaSwitch.currentTitle.value = title;
    Controllers.mediaSwitch.currentThumbnail.value = thumbnail;
    Controllers.mediaSwitch.isVideo.value = false;
    Controllers.mediaSwitch.isLoading.value = true;

    try {
      // Get available qualities first
      final qualities = await Controllers.search.getAvailableQualities(videoId);
      print('Available qualities: $qualities');
      
      // Get stream URLs with default quality (1080p)
      final defaultQuality = qualities.isNotEmpty && qualities.first.contains('1080') 
          ? qualities.first 
          : (qualities.isNotEmpty ? qualities.first : '1080p');
      
      print('Fetching streams at quality: $defaultQuality');
      final streams = await Controllers.search.getStreamUrls(videoId, videoQuality: defaultQuality);
      
      final audioUrl = streams['audioUrl'];
      final videoUrl = streams['videoUrl'];
      
      if (audioUrl == null || videoUrl == null) {
        throw Exception('Failed to get stream URLs');
      }
      
      print('Audio URL: ${audioUrl.substring(0, 100)}...');
      print('Video URL: ${videoUrl.substring(0, 100)}...');
      print('Selected quality: $defaultQuality');

      // Load media using the controller with quality information
      await Controllers.mediaSwitch.loadMedia(
        title: title,
        thumbnail: thumbnail,
        audio: audioUrl,
        video: videoUrl,
        qualities: qualities,
        artist: item['author'],
        initialQuality: defaultQuality,
      );
      
      print('✅ Media loaded with quality: $defaultQuality');
      print('=== AUDIO INITIALIZED SUCCESSFULLY ===');
      
    } catch (e, stackTrace) {
      print('AUDIO PLAYER: Error: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Playback Error',
        'Failed to play audio: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showQualitySelector(Map<String, dynamic> args) {
    final videoId = args['id'] ?? args['videoId'] ?? '';
    
    Get.dialog(
      VideoQualitySelector(
        videoId: videoId,
        onQualitySelected: (quality) {
          print('Quality selected: $quality');
        },
      ),
    );
  }
}