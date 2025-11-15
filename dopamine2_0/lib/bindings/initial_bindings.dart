import 'package:get/get.dart';

import '../controllers/nav_controller.dart';
import '../controllers/mini_player_controller.dart';
import '../controllers/media_switch_controller.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/playlist_controller.dart';
import '../controllers/download_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Global controllers used everywhere
    Get.put(NavController(), permanent: true);
    Get.put(MiniPlayerController(), permanent: true);
    Get.put(MediaSwitchController(), permanent: true);

    // Persistent data controllers
    Get.put(FavoritesController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(PlaylistController(), permanent: true);
    Get.put(DownloadController(), permanent: true);

    // Search controller is NOT global → loaded only on search screen
  }
}
