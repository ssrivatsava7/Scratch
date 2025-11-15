import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:dopamine2_0/controllers/download_controller.dart';
import 'package:dopamine2_0/controllers/media_switch_controller.dart';
import 'package:dopamine2_0/controllers/history_controller.dart';

import 'package:dopamine2_0/models/media_item.dart';
import 'package:dopamine2_0/routes/app_routes.dart';
import 'package:dopamine2_0/theme/midnight_aurora_theme.dart';


class DownloadsScreen extends StatelessWidget {
  DownloadsScreen({super.key});

  final downloads = Get.find<DownloadController>();
  final media = Get.find<MediaSwitchController>();
  final history = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Downloads"),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
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
              final json = items[i];
              final item = MediaItem.fromJson(json);

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(item.thumbnailUrl, height: 50, width: 50),
                ),
                title: Text(item.title,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.channelName,
                    style: const TextStyle(color: Colors.white60)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                onTap: () async {
                  history.addToHistory(json);

                  await media.loadMedia(
                    title: item.title,
                    thumbnail: item.thumbnailUrl,
                    audio: item.audioUrl,
                    video: item.videoUrl,
                  );

                  Get.toNamed(Routes.AUDIO_PLAYER, arguments: json);
                },
                onLongPress: () async {
                  await media.loadMedia(
                    title: item.title,
                    thumbnail: item.thumbnailUrl,
                    audio: item.audioUrl,
                    video: item.videoUrl,
                  );
                  media.switchToVideo();
                  Get.toNamed(Routes.VIDEO_PLAYER, arguments: json);
                },
              );
            },
          );
        }),
      ),
    );
  }
}
