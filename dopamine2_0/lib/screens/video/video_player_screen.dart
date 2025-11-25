import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'dart:async';

import '../../utils/controller_helper.dart';
import '../../services/download_service.dart';
import '../../routes/app_routes.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final RxBool _showControls = true.obs;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      _showControls.value = false;
    });
  }

  void _toggleControls() {
    _showControls.value = !_showControls.value;
    if (_showControls.value) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _onUserInteraction() {
    if (!_showControls.value) {
      _showControls.value = true;
    }
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final media = Controllers.mediaSwitch;
    final args = Get.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // Video Player
            Center(
              child: Video(
                controller: media.videoController,
                controls: NoVideoControls,
              ),
            ),

            // Loading Indicator
            Obx(() {
              if (media.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Obx(() => AnimatedOpacity(
                opacity: _showControls.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls.value,
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
                          // Quality selector button
                          Obx(() => IconButton(
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.settings, color: Colors.white, size: 24),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.purpleAccent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      media.currentVideoQuality.value.replaceAll('p', '').replaceAll(' (4K)', '').replaceAll(' (2K)', ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              _onUserInteraction();
                              if (args != null) {
                                _showQualitySelector(args);
                              }
                            },
                            tooltip: 'Video Quality (${media.currentVideoQuality.value})',
                          )),
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
                              _onUserInteraction();
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
                              _onUserInteraction();
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
                              _onUserInteraction();
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
              )),
            ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(() => AnimatedOpacity(
                opacity: _showControls.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls.value,
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
                              value: media.position.value.inSeconds.toDouble().clamp(
                                0.0, 
                                media.duration.value.inSeconds > 0 ? media.duration.value.inSeconds.toDouble() : 1.0
                              ),
                              max: media.duration.value.inSeconds > 0
                                  ? media.duration.value.inSeconds.toDouble()
                                  : 1.0,
                              onChanged: (value) {
                                _onUserInteraction();
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
                                  _onUserInteraction();
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
                                    _onUserInteraction();
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
                                  _onUserInteraction();
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
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualitySelector(Map<String, dynamic> args) async {
    final videoId = args['id'] ?? args['videoId'] ?? '';
    if (videoId.isEmpty) {
      Get.snackbar(
        'Error',
        'Video ID not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final media = Controllers.mediaSwitch;
    final search = Controllers.search;

    // Use cached qualities if available to avoid delay
    List<String> qualities = [];
    if (media.availableQualities.isNotEmpty) {
      qualities = media.availableQualities;
    } else {
      // Show loading indicator if fetching is needed
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
        barrierDismissible: false,
      );
      try {
        qualities = await search.getAvailableQualities(videoId);
        Get.back(); // Close loading
      } catch (e) {
        Get.back(); // Close loading
        Get.snackbar(
          'Error',
          'Failed to fetch available qualities: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Show quality selector dialog
    Get.dialog(
      Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Row(
                children: [
                  Icon(Icons.high_quality, color: Colors.purpleAccent),
                  SizedBox(width: 12),
                  Text(
                    'Video Quality',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Quality options list - Wrapped in Flexible to prevent overflow
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: qualities.map((quality) {
                      final currentQuality = media.currentVideoQuality.value;
                      final isSelected = quality == currentQuality;
                      
                      // Determine quality badge color
                      Color badgeColor = Colors.grey;
                      String badgeText = '';
                      
                      if (quality.contains('2160') || quality.contains('4K')) {
                        badgeColor = Colors.red;
                        badgeText = '4K ULTRA HD';
                      } else if (quality.contains('1440') || quality.contains('2K')) {
                        badgeColor = Colors.deepOrange;
                        badgeText = '2K QHD';
                      } else if (quality.contains('1080')) {
                        badgeColor = Colors.blue;
                        badgeText = 'FULL HD';
                      } else if (quality.contains('720')) {
                        badgeColor = Colors.green;
                        badgeText = 'HD';
                      } else if (quality.contains('480')) {
                        badgeText = 'SD';
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purpleAccent.withOpacity(0.2) : Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.purpleAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? Colors.purpleAccent : Colors.white70,
                            size: 28,
                          ),
                          title: Row(
                            children: [
                              Text(
                                quality,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                              if (badgeText.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            isSelected ? 'Currently playing' : 'Tap to switch',
                            style: TextStyle(
                              color: isSelected ? Colors.purpleAccent.withOpacity(0.8) : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            if (!isSelected) {
                              Get.back(); // Close quality dialog immediately
                              
                              // Show non-blocking feedback
                              Get.snackbar(
                                'Switching Quality',
                                'Switching to $quality...',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.black54,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 1),
                              );
                              
                              // Perform switch in background
                              search.getStreamUrls(
                                videoId,
                                videoQuality: quality,
                              ).then((streams) async {
                                if (streams['videoUrl'] != null) {
                                  await media.changeVideoQuality(
                                    quality,
                                    streams['videoUrl']!,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to load $quality stream',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              }).catchError((e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to change quality: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Close button
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
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

