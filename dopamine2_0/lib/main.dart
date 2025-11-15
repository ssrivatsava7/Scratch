import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:get_storage/get_storage.dart';

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

    /// Initialize MediaKit
    MediaKit.ensureInitialized();
    
    /// Initialize GetStorage
    await GetStorage.init();

    /// Initialize all controllers
    Get.put(FavoritesController());
    Get.put(PlaylistController());
    Get.put(DownloadController());
    Get.put(MiniPlayerController());
    Get.put(MediaSwitchController());
    Get.put(HistoryController());
    Get.put(search.SearchController());
    Get.put(NavController());

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
