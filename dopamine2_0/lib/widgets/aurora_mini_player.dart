import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mini_player_controller.dart';
import '../theme/midnight_aurora_theme.dart';

class AuroraMiniPlayer extends StatelessWidget {
  AuroraMiniPlayer({super.key});

  final mini = Get.find<MiniPlayerController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!mini.isVisible.value) return const SizedBox.shrink();

      return Positioned(
        left: mini.dx.value,
        top: mini.dy.value,
        child: GestureDetector(
          onPanUpdate: (details) {
            mini.updateDrag(
              mini.dx.value + details.delta.dx,
              mini.dy.value + details.delta.dy,
            );
          },
          onTap: () {
            // Expand back into full video screen
            Get.toNamed('/video_player', arguments: {
              'url': mini.url.value,
              'title': mini.title.value,
            });

            mini.isVisible.value = false;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: 240,
            padding: const EdgeInsets.all(12),
            decoration: MidnightAuroraTheme.glass.copyWith(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 22,
                  spreadRadius: 3,
                )
              ],
            ),
            child: Row(
              children: [
                // Thumbnail with neon border
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    mini.thumbnail.value,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 10),

                // Title + playback buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mini.title.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: mini.togglePlayback,
                            child: Obx(() {
                              return Icon(
                                mini.isPlaying.value
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: const Color(0xFF4FD1C5),
                                size: 26,
                              );
                            }),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: mini.hideMiniPlayer,
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white70, size: 22),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
