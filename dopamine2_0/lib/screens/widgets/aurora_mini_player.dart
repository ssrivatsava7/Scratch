import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/controller_helper.dart';
import '../../routes/app_routes.dart';

class AuroraMiniPlayer extends StatelessWidget {
  const AuroraMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final media = Controllers.mediaSwitch;

    return GestureDetector(
      onTap: () {
        if (media.isVideo.value) {
          Get.toNamed(Routes.VIDEO_PLAYER);
        } else {
          Get.toNamed(Routes.AUDIO_PLAYER);
        }
      },
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.purpleAccent.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Obx(() {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  media.currentThumbnail.value,
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                ),
              );
            }),

            const SizedBox(width: 12),

            // Title
            Expanded(
              child: Obx(() {
                return Text(
                  media.currentTitle.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                );
              }),
            ),

            const SizedBox(width: 12),

            // Play / Pause Button
            Obx(() {
              final playing = media.isPlaying.value;

              return IconButton(
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () => playing ? media.pause() : media.play(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
