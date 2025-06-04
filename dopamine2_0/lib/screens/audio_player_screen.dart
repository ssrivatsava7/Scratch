import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import 'video_player_screen.dart';

class AudioPlayerScreen extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());
  final TextEditingController searchController = TextEditingController();

  AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dopamine 2.0 - YouTube Audio Player"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for a song...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.trim().isNotEmpty) {
                      audioController.searchVideos(searchController.text.trim());
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  audioController.searchVideos(value.trim());
                }
              },
            ),
          ),

          // Error display
          Obx(() {
            if (audioController.currentError.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        audioController.currentError.value,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => audioController.clearError(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Loading indicator
          Obx(() {
            if (audioController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          }),

          // Playback controls
          Obx(() {
            if (audioController.isPlaying.value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.pause, size: 32),
                    onPressed: () => audioController.togglePlayback(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.stop, size: 32),
                    onPressed: () => audioController.stopPlayback(),
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.play_arrow, size: 48),
                onPressed: () => audioController.togglePlayback(),
              );
            }
          }),

          // Display search results
          Expanded(
            child: Obx(() {
              if (audioController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "Search for songs to get started!",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: audioController.searchResults.length,
                itemBuilder: (context, index) {
                  var video = audioController.searchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.music_note, color: Colors.white),
                      ),
                      title: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(video.author),
                          if (video.duration != null)
                            Text(
                              "${video.duration!.inMinutes}:${(video.duration!.inSeconds % 60).toString().padLeft(2, '0')}",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.video_library),
                            onPressed: () {
                              Get.to(() => VideoPlayerScreen(
                                    videoId: video.id.toString(),
                                    videoTitle: video.title,
                                  ));
                            },
                          ),
                          const Icon(Icons.play_arrow),
                        ],
                      ),
                      onTap: () {
                        audioController.loadAudio(video.id.toString());
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
