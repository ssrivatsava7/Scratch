import 'package:get/get.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/download_controller.dart';
import '../controllers/mini_player_controller.dart';
import '../controllers/media_switch_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/search_controller.dart' as search_ctrl;
import '../controllers/nav_controller.dart';

/// Helper class to access all controllers from any screen
class Controllers {
  static FavoritesController get favorites => Get.find<FavoritesController>();
  static PlaylistController get playlist => Get.find<PlaylistController>();
  static DownloadController get download => Get.find<DownloadController>();
  static MiniPlayerController get miniPlayer => Get.find<MiniPlayerController>();
  static MediaSwitchController get mediaSwitch => Get.find<MediaSwitchController>();
  static HistoryController get history => Get.find<HistoryController>();
  static search_ctrl.SearchController get search => Get.find<search_ctrl.SearchController>();
  static NavController get nav => Get.find<NavController>();
}
