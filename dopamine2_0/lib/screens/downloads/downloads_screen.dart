import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dopamine2_0/utils/controller_helper.dart';
import 'package:dopamine2_0/widgets/dopamine_app_bar.dart';
import 'package:dopamine2_0/services/download_service.dart';

import 'package:dopamine2_0/models/media_item.dart';
import 'package:dopamine2_0/routes/app_routes.dart';
import 'package:dopamine2_0/theme/midnight_aurora_theme.dart';


class DownloadsScreen extends StatelessWidget {
  DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloads = Controllers.download;
    final media = Controllers.mediaSwitch;
    final history = Controllers.history;

    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: DopamineAppBar(
          title: "Downloads",
          showHomeButton: true,
        ),
        body: Obx(() {
          final items = downloads.downloads;

          if (items.isEmpty) {
            return const Center(
              child: Text("No downloads yet",
                  style: TextStyle(color: Colors.white54)),
            );
          }        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final json = items[i];
            final item = MediaItem.fromJson(json);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[900],
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.network(
                        item.thumbnailUrl,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white54),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.download_done,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(item.title,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.channelName,
                        style: const TextStyle(color: Colors.white60)),
                    if (json['fileSize'] != null || json['audioFileSize'] != null)
                      Text(
                        'Size: ${((json['fileSize'] ?? json['audioFileSize'] ?? 0.0)).toStringAsFixed(2)} MB',
                        style: const TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    if (json['localAudioPath'] != null)
                      const Text(
                        '📁 Downloaded locally',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.purpleAccent),
                      onPressed: () async {
                        history.addToHistory(json);

                        await media.loadMedia(
                          title: item.title,
                          thumbnail: item.thumbnailUrl,
                          audio: item.audioUrl,
                          video: item.videoUrl,
                        );

                        Get.toNamed(Routes.AUDIO_PLAYER, arguments: json);
                      },
                      tooltip: 'Play Audio',
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.purpleAccent),
                      onPressed: () async {
                        await media.loadMedia(
                          title: item.title,
                          thumbnail: item.thumbnailUrl,
                          audio: item.audioUrl,
                          video: item.videoUrl,
                        );
                        media.switchToVideo();
                        Get.toNamed(Routes.VIDEO_PLAYER, arguments: json);
                      },
                      tooltip: 'Play Video',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(json, i);
                      },
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          },
        );
        }),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> item, int index) async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Download', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${item['title']}" from downloads?\n\nThis will also delete the downloaded files from your device.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              
              // Show deleting dialog
              Get.dialog(
                const AlertDialog(
                  backgroundColor: Colors.transparent,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text('Deleting files...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );
              
              try {
                final downloadService = DownloadService();
                
                // Delete local files
                if (item['localAudioPath'] != null) {
                  await downloadService.deleteFile(item['localAudioPath']);
                }
                if (item['localVideoPath'] != null) {
                  await downloadService.deleteFile(item['localVideoPath']);
                }
                if (item['localThumbnailPath'] != null) {
                  await downloadService.deleteFile(item['localThumbnailPath']);
                }
                
                // Remove from downloads list
                Controllers.download.removeDownload(item);
                
                Get.back(); // Close deleting dialog
                
                Get.snackbar(
                  'Deleted',
                  '${item['title']} and its files have been deleted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } catch (e) {
                Get.back(); // Close deleting dialog
                
                Get.snackbar(
                  'Error',
                  'Failed to delete files: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
