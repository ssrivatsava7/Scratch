import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

import 'controllers/youtube_media_controller.dart';
import 'screens/audio_player_screen.dart';
import 'screens/video_player_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // Initialize media_kit
  runApp(DopamineApp());
}

class DopamineApp extends StatelessWidget {
  const DopamineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dopamine 2.0',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MediaHomeScreen(),
    );
  }
}

class MediaHomeScreen extends StatelessWidget {
  final YouTubeMediaController ytController = YouTubeMediaController();
  final TextEditingController searchController = TextEditingController();
  final RxList videos = [].obs;

  MediaHomeScreen({super.key});

  void searchVideos(String query) async {
    videos.value = await ytController.searchVideos(query);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Dopamine 2.0"),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.music_note), text: "Audio"),
              Tab(icon: Icon(Icons.video_library), text: "Video"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AudioPlayerScreen(), // Existing audio functionality
            videoTab(), // New video tab functionality
          ],
        ),
      ),
    );
  }

  Widget videoTab() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search for videos...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (searchController.text.trim().isNotEmpty) {
                  searchVideos(searchController.text.trim());
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              searchVideos(value.trim());
            }
          },
        ),
      ),
      Expanded(
        child: Obx(() {
          if (videos.isEmpty) {
            return Center(
              child: Text(
                "Search videos to get started!",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (_, index) {
              var video = videos[index];
              return ListTile(
                leading: Icon(Icons.video_collection),
                title: Text(video.title),
                subtitle: Text(video.author),
                trailing: Icon(Icons.play_arrow),
                onTap: () async {
                  try {
                    Get.to(() => VideoPlayerScreen(
                      videoId: video.id.value,
                      videoTitle: video.title,
                    ));
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to play video: ${e.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              );
            },
          );
        }),
      ),
    ],
  );
}
