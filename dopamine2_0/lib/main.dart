import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/audio_controller.dart';

void main() {
  runApp(DopamineApp());
}

class DopamineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dopamine 2.0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dopamine 2.0 - YouTube Audio Player"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar for entering song name
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
                  icon: Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.trim().isNotEmpty) {
                      audioController.searchVideos(
                        searchController.text.trim(),
                      );
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
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        audioController.currentError.value,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => audioController.clearError(),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // Loading indicator
          Obx(() {
            if (audioController.isLoading.value) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Loading audio..."),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // Playback controls (when audio is loaded)
          Obx(() {
            if (audioController.isPlaying.value) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.pause, size: 32),
                      onPressed: () => audioController.togglePlayback(),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.stop, size: 32),
                      onPressed: () => audioController.stopPlayback(),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // Display search results
          Expanded(
            child: Obx(() {
              if (audioController.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.music_note, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
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
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: audioController.searchResults.length,
                itemBuilder: (context, index) {
                  var video = audioController.searchResults[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: Icon(Icons.play_arrow),
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
