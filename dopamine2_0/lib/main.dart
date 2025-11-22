import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io' show Platform;

import 'controllers/favorites_controller.dart';
import 'controllers/playlist_controller.dart';
import 'controllers/download_controller.dart';
import 'controllers/mini_player_controller.dart';
import 'controllers/media_switch_controller.dart';
import 'controllers/history_controller.dart';
import 'controllers/search_controller.dart' as search;
import 'controllers/nav_controller.dart';
import 'theme/midnight_aurora_theme.dart';
import 'routes/app_pages.dart';
import 'widgets/aurora_mini_player.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    /// Initialize MediaKit for video playback
    MediaKit.ensureInitialized();
    
    /// Initialize just_audio (ensures Windows audio backend is ready)
    if (Platform.isWindows) {
      print('Initializing Windows audio backend...');
      // Pre-initialize audio player to ensure Windows audio session is ready
      final testPlayer = AudioPlayer();
      await testPlayer.setVolume(1.0);
      await testPlayer.dispose();
      print('Windows audio backend initialized');
    }
    
    /// Initialize GetStorage
    await GetStorage.init();

    /// Initialize all controllers as permanent for global access
    Get.put(FavoritesController(), permanent: true);
    Get.put(PlaylistController(), permanent: true);
    Get.put(DownloadController(), permanent: true);
    Get.put(MiniPlayerController(), permanent: true);
    Get.put(MediaSwitchController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(search.SearchController(), permanent: true);
    Get.put(NavController(), permanent: true);

    runApp(const DopamineApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      ),
    ));
  }
}

class DopamineApp extends StatelessWidget {
  const DopamineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dopamine Player',
      theme: MidnightAuroraTheme.theme,
      getPages: AppPages.routes,
      initialRoute: AppPages.initial,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox(),
            const AuroraMiniPlayer(),
          ],
        );
      },
    );
  }
}
