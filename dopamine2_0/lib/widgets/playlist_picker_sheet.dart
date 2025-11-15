import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/playlist_controller.dart';
import '../theme/midnight_aurora_theme.dart';

class PlaylistPickerSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const PlaylistPickerSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final playlist = Get.find<PlaylistController>();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: MidnightAuroraTheme.bottomSheetDecoration,
        padding: const EdgeInsets.all(18),
        child: Obx(() {
          final lists = playlist.playlists;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Text(
                "Add to Playlist",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // LIST OF PLAYLISTS
              if (lists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "No playlists yet. Create one!",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              else
                ...lists.map((p) {
                  return ListTile(
                    leading: const Icon(Icons.folder, color: Colors.white70),
                    title: Text(
                      p["name"],
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      playlist.addToPlaylist(p["name"], item);
                      Get.back(); // Close bottom sheet after adding
                      Get.snackbar(
                        'Added to Playlist',
                        'Added to ${p["name"]}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.withOpacity(0.7),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  );
                }).toList(),

              const Divider(color: Colors.white24),

              // NEW PLAYLIST BUTTON
              TextButton.icon(
                onPressed: () => _createPlaylistDialog(playlist),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Create New Playlist",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _createPlaylistDialog(PlaylistController playlist) {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("New Playlist", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Playlist name",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog only
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                playlist.createPlaylist(textController.text.trim());
                Get.back(); // Close dialog
                Get.snackbar(
                  'Playlist Created',
                  '"${textController.text.trim()}" created successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.7),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }
}
