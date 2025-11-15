import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/search_controller.dart' as my_search;
import '../../controllers/media_switch_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/favorites_controller.dart';
import '../../controllers/download_controller.dart';

import '../../widgets/playlist_picker_sheet.dart';
import '../../routes/app_routes.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<my_search.SearchController>();
    final fav = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search Results', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          );
        }

        if (controller.results.isEmpty && controller.hasSearched.value) {
          return const Center(
            child: Text(
              'No results found.',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.results.length,
          itemBuilder: (context, index) {
            final item = controller.results[index];

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.thumbnailUrl,
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
                item.title,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.channelName,
                style: const TextStyle(color: Colors.white54),
              ),
              onTap: () => _openAudio(item),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: Colors.grey[900],
                onSelected: (value) {
                  final mapData = {
                    "id": item.videoUrl,
                    "title": item.title,
                    "thumbnail": item.thumbnailUrl,
                    "author": item.channelName,
                    "audioUrl": item.videoUrl,
                    "videoUrl": item.videoUrl,
                  };
                  
                  if (value == "audio") {
                    _openAudio(item);
                  } else if (value == "video") {
                    _openVideo(item);
                  } else if (value == "playlist") {
                    _openAddToPlaylist(item);
                  } else if (value == "favorite") {
                    fav.toggleFavorite(mapData);
                  } else if (value == "download") {
                    _downloadMedia(item, isVideo: false);
                  } else if (value == "download_video") {
                    _downloadMedia(item, isVideo: true);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "audio",
                    child: Row(
                      children: [
                        Icon(Icons.music_note, color: Colors.white70),
                        SizedBox(width: 12),
                        Text("Play Audio", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "video",
                    child: Row(
                      children: [
                        Icon(Icons.video_library, color: Colors.white70),
                        SizedBox(width: 12),
                        Text("Play Video", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "playlist",
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add, color: Colors.white70),
                        SizedBox(width: 12),
                        Text("Add to Playlist", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: "favorite",
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.white70),
                        SizedBox(width: 12),
                        Text("Toggle Favorite", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),                      const PopupMenuItem(
                        value: "download",
                        child: Row(
                          children: [
                            Icon(Icons.download, color: Colors.white70),
                            SizedBox(width: 12),
                            Text("Download Audio", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "download_video",
                        child: Row(
                          children: [
                            Icon(Icons.video_file, color: Colors.white70),
                            SizedBox(width: 12),
                            Text("Download Video", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // -----------------------------------------------------
  // OPEN AUDIO
  // -----------------------------------------------------
  void _openAudio(dynamic item) async {
    final media = Get.find<MediaSwitchController>();
    final history = Get.find<HistoryController>();

    // Show loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    try {
      // Extract video ID from URL
      final videoId = item.videoUrl.split('v=').last.split('&').first;
      
      // Get actual stream URLs
      final controller = Get.find<my_search.SearchController>();
      final streams = await controller.getStreamUrls(videoId);
      
      final audioUrl = streams['audioUrl'];
      final videoUrl = streams['videoUrl'];

      Get.back(); // Close loading dialog

      if (audioUrl == null || audioUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Could not get audio stream',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final mapData = {
        "id": item.videoUrl,
        "title": item.title,
        "thumbnail": item.thumbnailUrl,
        "author": item.channelName,
        "audioUrl": audioUrl,
        "videoUrl": videoUrl ?? audioUrl,
      };

      history.addToHistory(mapData);

      media.loadMedia(
        title: item.title,
        thumbnail: item.thumbnailUrl,
        audio: audioUrl,
        video: videoUrl ?? audioUrl,
      );

      Get.toNamed(Routes.AUDIO_PLAYER, arguments: mapData);
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to load media: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // -----------------------------------------------------
  // OPEN VIDEO
  // -----------------------------------------------------
  void _openVideo(dynamic item) async {
    final media = Get.find<MediaSwitchController>();
    final history = Get.find<HistoryController>();

    // Show loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      barrierDismissible: false,
    );

    try {
      // Extract video ID from URL
      final videoId = item.videoUrl.split('v=').last.split('&').first;
      
      // Get actual stream URLs
      final controller = Get.find<my_search.SearchController>();
      final streams = await controller.getStreamUrls(videoId);
      
      final audioUrl = streams['audioUrl'];
      final videoUrl = streams['videoUrl'];

      Get.back(); // Close loading dialog

      if (videoUrl == null || videoUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Could not get video stream',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final mapData = {
        "id": item.videoUrl,
        "title": item.title,
        "thumbnail": item.thumbnailUrl,
        "author": item.channelName,
        "audioUrl": audioUrl ?? videoUrl,
        "videoUrl": videoUrl,
      };

      history.addToHistory(mapData);

      media.loadMedia(
        title: item.title,
        thumbnail: item.thumbnailUrl,
        audio: audioUrl ?? videoUrl,
        video: videoUrl,
      );

      // Switch to video mode
      await media.switchToVideo();

      Get.toNamed(Routes.VIDEO_PLAYER, arguments: mapData);
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to load video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // -----------------------------------------------------
  // ADD TO PLAYLIST
  // -----------------------------------------------------
  void _openAddToPlaylist(dynamic item) {
    final mapData = {
      "id": item.videoUrl,
      "title": item.title,
      "thumbnail": item.thumbnailUrl,
      "author": item.channelName,
      "audioUrl": item.videoUrl,
      "videoUrl": item.videoUrl,
    };

    Get.to(
      () => PlaylistPickerSheet(item: mapData),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    );
  }

  // -----------------------------------------------------
  // DOWNLOAD MEDIA
  // -----------------------------------------------------
  Future<void> _downloadMedia(dynamic item, {bool isVideo = false}) async {
    final downloads = Get.find<DownloadController>();

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.white)),
      barrierDismissible: false,
    );

    try {
      final videoId = item.videoUrl.split('v=').last.split('&').first;
      final controller = Get.find<my_search.SearchController>();
      final streams = await controller.getStreamUrls(videoId);
      
      final audioUrl = streams['audioUrl'];
      final videoUrl = streams['videoUrl'];

      Get.back();

      if (isVideo && (videoUrl == null || videoUrl.isEmpty)) {
        Get.snackbar('Error', 'Could not get video download URL',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      if (!isVideo && (audioUrl == null || audioUrl.isEmpty)) {
        Get.snackbar('Error', 'Could not get audio download URL',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      final downloadData = {
        "id": item.videoUrl,
        "title": item.title,
        "thumbnail": item.thumbnailUrl,
        "author": item.channelName,
        "audioUrl": audioUrl ?? '',
        "videoUrl": videoUrl ?? audioUrl ?? '',
        "downloadUrl": isVideo ? (videoUrl ?? '') : (audioUrl ?? ''),
        "type": isVideo ? "video" : "audio",
      };

      await downloads.startDownload(downloadData);

      Get.snackbar(
        isVideo ? 'Video Download Started' : 'Audio Download Started',
        item.title,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Failed to start download: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
