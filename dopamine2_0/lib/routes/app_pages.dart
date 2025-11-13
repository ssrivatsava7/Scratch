import 'package:get/get.dart';
import 'app_routes.dart';

import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/history_screen.dart';
import '../screens/downloads_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/video_player_screen.dart';
import '../screens/playlist_detail_screen.dart';
import '../screens/playlists_screen.dart';

class AppPages {
  AppPages._();

  // 🚀 INITIAL ROUTE (required by GetMaterialApp)
  static const initial = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: Routes.FAVORITES,
      page: () => FavoritesScreen(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => HistoryScreen(),
    ),
    GetPage(
      name: Routes.DOWNLOADS,
      page: () => DownloadsScreen(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
    GetPage(
  name: Routes.VIDEO_PLAYER,
  page: () {
    final url = Get.arguments['url'] as String;
    return VideoPlayerScreen(url: url);
  },
),
    GetPage(
      name: Routes.PLAYLIST_DETAIL,
      page: () => PlaylistDetailScreen(),
    ),
    GetPage(
      name: Routes.PLAYLISTS,
      page: () => PlaylistsScreen(),
    ),
  ];
}
