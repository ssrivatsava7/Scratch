import 'package:get/get.dart';

import '../screens/home/home_screen.dart';
import '../screens/audio/audio_player_screen.dart';
import '../screens/video/video_player_screen.dart';
import '../screens/search/search_screen.dart'; // Ensure this file defines 'SearchScreen'
import '../screens/search/search_results_screen.dart';
import '../screens/playlists/playlists_screen.dart';
import '../screens/playlists/playlist_detail_screen.dart';

import '../screens/favorites/favorites_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/settings/settings_screen.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: () => const SearchScreen(), // Make sure 'SearchScreen' is defined in search_screen.dart
    ),
    GetPage(
      name: Routes.SEARCH_RESULTS,
      page: () => const SearchResultsScreen(),
    ),
    GetPage(
      name: Routes.AUDIO_PLAYER,
      page: () => const AudioPlayerScreen(),
    ),
    GetPage(
      name: Routes.VIDEO_PLAYER,
      page: () => const VideoPlayerScreen(),
    ),
    GetPage(
      name: Routes.PLAYLISTS,
      page: () => PlaylistsScreen(),
    ),
    GetPage(
      name: Routes.PLAYLIST_DETAIL,
      page: () => const PlaylistDetailScreen(),
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
      page: () => SettingsScreen(),
    ),
  ];
}
