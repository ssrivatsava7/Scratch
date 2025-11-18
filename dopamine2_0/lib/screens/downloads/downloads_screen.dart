import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dopamine2_0/utils/controller_helper.dart';
import 'package:dopamine2_0/widgets/dopamine_app_bar.dart';
import 'package:dopamine2_0/models/download_item.dart';
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
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[900],
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.network(
                          item.thumbnail ?? '',
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
                              color: item.isCompleted ? Colors.green : 
                                     item.isDownloading ? Colors.blue :
                                     item.isFailed ? Colors.red : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              item.isCompleted ? Icons.download_done :
                              item.isDownloading ? Icons.downloading :
                              item.isFailed ? Icons.error : Icons.pending,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.artist != null)
                        Text(
                          item.artist!,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      if (item.isDownloading)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: item.progress,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(item.progress * 100).toStringAsFixed(0)}% - ${downloads.getFormattedFileSize(item.downloadedBytes)}',
                              style: const TextStyle(color: Colors.blue, fontSize: 11),
                            ),
                          ],
                        ),
                      if (item.isCompleted && item.fileSize != null)
                        Text(
                          'Size: ${downloads.getFormattedFileSize(item.fileSize!)}',
                          style: const TextStyle(color: Colors.green, fontSize: 11),
                        ),
                      if (item.isCompleted && item.filePath != null)
                        const Text(
                          '📁 Downloaded locally',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                        ),
                      if (item.isFailed)
                        Text(
                          'Failed: ${item.error ?? "Unknown error"}',
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.isCompleted) ...[
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.purpleAccent),
                          onPressed: () => _playDownload(item),
                          tooltip: 'Play',
                        ),
                      ],
                      if (item.isDownloading)
                        IconButton(
                          icon: const Icon(Icons.pause, color: Colors.orange),
                          onPressed: () => downloads.pauseDownload(item),
                          tooltip: 'Pause',
                        ),
                      if (item.isPaused)
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.blue),
                          onPressed: () => downloads.resumeDownload(item),
                          tooltip: 'Resume',
                        ),
                      if (item.isFailed)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.orange),
                          onPressed: () {
                            downloads.retryDownload(item);
                            Get.snackbar(
                              'Retrying',
                              'Retrying download for ${item.title}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.blue,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          tooltip: 'Retry Download',
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(item),
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

  void _playDownload(DownloadItem item) async {
    final media = Controllers.mediaSwitch;
    final history = Controllers.history;
    
    // Create a map for history and navigation
    final itemMap = {
      'id': item.videoId,
      'videoId': item.videoId,
      'title': item.title,
      'thumbnail': item.thumbnail,
      'author': item.artist,
      'channelName': item.artist,
    };
    
    history.addToHistory(itemMap);
    
    // If file exists locally, play from local path
    if (item.filePath != null && item.isCompleted) {
      await media.loadMedia(
        title: item.title,
        thumbnail: item.thumbnail ?? '',
        audio: 'file://${item.filePath}',
        video: '',
      );
    }
    
    Get.toNamed(Routes.AUDIO_PLAYER, arguments: itemMap);
  }

  void _showDeleteConfirmation(DownloadItem item) async {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Download', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${item.title}" from downloads?${item.isCompleted ? '\n\nThis will also delete the downloaded file from your device.' : ''}',
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
              
              try {
                // Remove from downloads list (will also delete file if completed)
                await Controllers.download.removeDownload(item, deleteFile: item.isCompleted);
                
                Get.snackbar(
                  'Deleted',
                  '${item.title} has been deleted',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete: $e',
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
