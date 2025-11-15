import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/media_switch_controller.dart';
import '../routes/app_routes.dart';

class AuroraMiniPlayer extends StatelessWidget {
  const AuroraMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final media = Get.find<MediaSwitchController>();

    return Obx(() {
      // Don't show mini player if no media is loaded
      if (media.currentTitle.value.isEmpty || media.currentThumbnail.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: GestureDetector(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    media.currentThumbnail.value,
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 45,
                        width: 45,
                        color: Colors.grey[800],
                        child: const Icon(Icons.music_note, color: Colors.white54),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Text(
                    media.currentTitle.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Play / Pause Button
                IconButton(
                  icon: Icon(
                    media.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () => media.isPlaying.value ? media.pause() : media.play(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
