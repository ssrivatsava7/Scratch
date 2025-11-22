import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/controller_helper.dart';

/// Quality selector dialog for video playback
/// Shows available video qualities (up to 4K) and allows user to switch
class VideoQualitySelector extends StatelessWidget {
  final String videoId;
  final Function(String quality) onQualitySelected;

  const VideoQualitySelector({
    super.key,
    required this.videoId,
    required this.onQualitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final media = Controllers.mediaSwitch;
    final search = Controllers.search;

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Row(
              children: [
                Icon(Icons.high_quality, color: Colors.purpleAccent),
                SizedBox(width: 12),
                Text(
                  'Video Quality',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Quality options
            Obx(() {
              final qualities = media.availableQualities;
              final currentQuality = media.currentVideoQuality.value;
              
              if (qualities.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                );
              }
              
              return SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: qualities.map((quality) {
                      final isSelected = quality == currentQuality;
                      
                      // Determine quality badge
                      Color badgeColor = Colors.grey;
                      String badgeText = '';
                      
                      if (quality.contains('2160') || quality.contains('4K')) {
                        badgeColor = Colors.red;
                        badgeText = '4K ULTRA HD';
                      } else if (quality.contains('1440') || quality.contains('2K')) {
                        badgeColor = Colors.deepOrange;
                        badgeText = '2K QHD';
                      } else if (quality.contains('1080')) {
                        badgeColor = Colors.blue;
                        badgeText = 'FULL HD';
                      } else if (quality.contains('720')) {
                        badgeColor = Colors.green;
                        badgeText = 'HD';
                      } else if (quality.contains('480')) {
                        badgeColor = Colors.orange;
                        badgeText = 'SD';
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.purpleAccent.withOpacity(0.2) : Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.purpleAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined,
                            color: isSelected ? Colors.purpleAccent : Colors.white70,
                            size: 28,
                          ),
                          title: Row(
                            children: [
                              Text(
                                quality,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                              if (badgeText.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            isSelected ? 'Currently playing' : 'Tap to switch',
                            style: TextStyle(
                              color: isSelected ? Colors.purpleAccent.withOpacity(0.8) : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () async {
                            if (!isSelected) {
                              Get.back();
                              
                              // Show loading
                              Get.dialog(
                                const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(color: Colors.purpleAccent),
                                      SizedBox(height: 16),
                                      Text(
                                        'Switching quality...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                barrierDismissible: false,
                              );
                              
                              try {
                                // Fetch new stream URL for selected quality
                                final streams = await search.getStreamUrls(
                                  videoId,
                                  videoQuality: quality,
                                );
                                
                                Get.back(); // Close loading
                                
                                if (streams['videoUrl'] != null) {
                                  // Update quality
                                  await media.changeVideoQuality(
                                    quality,
                                    streams['videoUrl']!,
                                  );
                                  onQualitySelected(quality);
                                  
                                  Get.snackbar(
                                    'Quality Changed',
                                    'Now playing at $quality',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.green.withOpacity(0.8),
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to load $quality stream',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } catch (e) {
                                Get.back(); // Close loading
                                Get.snackbar(
                                  'Error',
                                  'Failed to change quality: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            // Close button
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close', style: TextStyle(color: Colors.white54, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

