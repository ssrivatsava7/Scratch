import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/media_switch_controller.dart';
import '../../routes/app_routes.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = Get.find<MediaSwitchController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library, color: Colors.white),
            onPressed: () {
              media.switchToVideo();
              Get.toNamed(Routes.VIDEO_PLAYER);
            },
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
                      value: media.position.value.inSeconds.toDouble(),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
