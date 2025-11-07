import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/download_controller.dart';
import '../models/download_item.dart';

class DownloadsScreen extends StatelessWidget {
  final DownloadController downloadController = Get.put(DownloadController());

  DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.orange,
        actions: [
          Obx(() {
            return FutureBuilder<String>(
              future: downloadController.getTotalDownloadSize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (downloadController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (downloadController.downloads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No downloads yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Downloaded videos will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: downloadController.downloads.length,
          itemBuilder: (context, index) {
            final download = downloadController.downloads[index];
            return _buildDownloadCard(context, download);
          },
        );
      }),
    );
  }

  Widget _buildDownloadCard(BuildContext context, DownloadItem download) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        download.video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        download.video.author,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _getStatusIcon(download.status),
              ],
            ),
            const SizedBox(height: 8),
            
            // Progress bar for downloading
            if (download.status == DownloadStatus.downloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: download.progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(download.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            
            // Status text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStatusText(download),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(download.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (download.status == DownloadStatus.downloading)
                      TextButton.icon(
                        onPressed: () {
                          downloadController.cancelDownload(download.video.id);
                        },
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      ),
                    if (download.status == DownloadStatus.completed ||
                        download.status == DownloadStatus.failed)
                      TextButton.icon(
                        onPressed: () {
                          _showDeleteDialog(context, download);
                        },
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        label: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
                      ),
                  ],
                ),
              ],
            ),
            
            // Error message
            if (download.status == DownloadStatus.failed && 
                download.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  download.errorMessage!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case DownloadStatus.downloading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case DownloadStatus.failed:
        return const Icon(Icons.error, color: Colors.red);
      case DownloadStatus.paused:
        return const Icon(Icons.pause_circle, color: Colors.orange);
      case DownloadStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
    }
  }

  String _getStatusText(DownloadItem download) {
    switch (download.status) {
      case DownloadStatus.completed:
        return 'Downloaded • ${download.quality}${download.isAudioOnly ? " (Audio)" : ""}';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.failed:
        return 'Download failed';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.pending:
        return 'Waiting...';
    }
  }

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.downloading:
        return Colors.orange;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.pending:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, DownloadItem download) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Delete "${download.video.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              downloadController.deleteDownload(download.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
