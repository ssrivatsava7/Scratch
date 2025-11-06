import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/youtube_media_controller.dart';
import '../controllers/audio_controller.dart';
import '../widgets/quality_selector.dart';

class SettingsScreen extends StatelessWidget {
  final YouTubeMediaController mediaController = Get.find<YouTubeMediaController>();
  final AudioController audioController = Get.find<AudioController>();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Playback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            return SwitchListTile(
              secondary: const Icon(Icons.play_circle_outline),
              title: const Text('Background Playback'),
              subtitle: const Text('Keep playing audio when app is minimized'),
              value: audioController.backgroundPlaybackEnabled.value,
              onChanged: (value) {
                audioController.toggleBackgroundPlayback();
              },
            );
          }),
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Video Quality',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            return ListTile(
              leading: const Icon(Icons.hd),
              title: const Text('Default Video Quality'),
              subtitle: Text('Current: ${mediaController.selectedQuality.value}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final qualities = ['360p', '480p', '720p', '1080p'];
                final selected = await QualitySelector.show(
                  currentQuality: mediaController.selectedQuality.value,
                  availableQualities: qualities,
                );
                
                if (selected != null) {
                  await mediaController.setQualityPreference(selected);
                  Get.snackbar(
                    'Quality Updated',
                    'Default quality set to $selected',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            );
          }),
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0+1'),
          ),
          const ListTile(
            leading: Icon(Icons.description),
            title: Text('Dopamine 2.0'),
            subtitle: Text('YouTube Audio & Video Player with Enhanced Features'),
          ),
          const ListTile(
            leading: Icon(Icons.stars),
            title: Text('Features'),
            subtitle: Text('Favorites • Playlists • History • Downloads • Background Playback'),
          ),
        ],
      ),
    );
  }
}
