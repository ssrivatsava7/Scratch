import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/controller_helper.dart';
import '../routes/app_routes.dart';

class AuroraMiniPlayer extends StatelessWidget {
  const AuroraMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final media = Controllers.mediaSwitch;

      // Don't show mini player if no media is loaded
      if (media.currentTitle.value.isEmpty || media.currentThumbnail.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () {
            print('=== MINI PLAYER TAPPED ===');
            print('isVideo: ${media.isVideo.value}');
            if (media.isVideo.value) {
              Get.toNamed('/video-player');
            } else {
              Get.toNamed('/audio-player');
            }
          },
          child: Container(
            height: 70,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    media.currentThumbnail.value,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.music_note, color: Colors.white),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Title - Single line only, no Column to avoid overflow
                Expanded(
                  child: Text(
                    media.currentTitle.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // Play/Pause button
                GestureDetector(
                  onTap: () {
                    if (media.isPlaying.value) {
                      media.pause();
                    } else {
                      media.play();
                    }
                  },
                  child: Icon(
                    media.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
