import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/controller_helper.dart';
import '../../routes/app_routes.dart';

class AuroraMiniPlayer extends StatefulWidget {
  const AuroraMiniPlayer({super.key});

  @override
  State<AuroraMiniPlayer> createState() => _AuroraMiniPlayerState();
}

class _AuroraMiniPlayerState extends State<AuroraMiniPlayer> {
  double xPosition = 0; // Will be calculated in build
  double yPosition = 50; // 50px from bottom - well above controls
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final media = Controllers.mediaSwitch;
    
    // Initialize position to bottom right on first build
    if (!_initialized) {
      xPosition = MediaQuery.of(context).size.width - 75; // 75px from right edge
      _initialized = true;
    }

    return Obx(() {
      // Don't show if no media is playing
      if (media.currentTitle.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: xPosition,
        bottom: yPosition,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              xPosition += details.delta.dx;
              yPosition -= details.delta.dy; // Subtract because bottom uses opposite direction
              
              // Keep within screen bounds (65px is the width of the mini player)
              xPosition = xPosition.clamp(0.0, MediaQuery.of(context).size.width - 65);
              yPosition = yPosition.clamp(50.0, MediaQuery.of(context).size.height - 100);
            });
          },
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            elevation: 8,
            child: InkWell(
              onTap: () {
                print('=== MINI PLAYER TAP DEBUG ===');
                print('Title: ${media.currentTitle.value}');
                print('isVideo: ${media.isVideo.value}');
                print('Thumbnail: ${media.currentThumbnail.value}');
                
                if (media.isVideo.value) {
                  print('Navigating to VIDEO_PLAYER');
                  Get.toNamed(Routes.VIDEO_PLAYER);
                } else {
                  print('Navigating to AUDIO_PLAYER');
                  Get.toNamed(Routes.AUDIO_PLAYER);
                }
                print('=== END DEBUG ===');
              },
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                width: 65, // Smaller width
                height: 65, // Smaller square shape
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        media.currentThumbnail.value,
                        height: 38,
                        width: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 38,
                            width: 38,
                            color: Colors.grey.withOpacity(0.3),
                            child: const Icon(Icons.music_note, color: Colors.white, size: 18),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 3),
                    
                    // Play / Pause Button
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        print('Play/Pause button tapped!');
                        if (media.isPlaying.value) {
                          media.pause();
                        } else {
                          media.play();
                        }
                      },
                      child: Icon(
                        media.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.purpleAccent,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
