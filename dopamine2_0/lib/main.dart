import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/download_controller.dart';
import 'controllers/mini_player_controller.dart';
import 'controllers/audio_controller.dart';
import 'controllers/youtube_media_controller.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/playlist_controller.dart';

import 'theme/midnight_aurora_theme.dart';
import 'routes/app_pages.dart';
import 'widgets/aurora_mini_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ REGISTER ALL CONTROLLERS HERE
  Get.put(AudioController());             // Audio Player
  Get.put(YouTubeMediaController());      // YouTube Search / Results
  Get.put(FavoritesController());         // Favorites
  Get.put(HistoryController());           // History
  Get.put(PlaylistController());          // Playlists

  // Existing controllers
  Get.put(MiniPlayerController());        // Mini Player Overlay
  Get.put(DownloadController());          // Downloads

  runApp(const DopamineApp());
}

class DopamineApp extends StatelessWidget {
  const DopamineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Dopamine Player",
      debugShowCheckedModeBanner: false,
      theme: MidnightAuroraTheme.theme,
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,

      // Global overlay: mini player stays on all screens
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            AuroraMiniPlayer(),
          ],
        );
      },
    );
  }
}
