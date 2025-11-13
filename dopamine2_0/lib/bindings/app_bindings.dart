import 'package:get/get.dart';
import '../controllers/audio_controller.dart';
import '../controllers/youtube_media_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AudioController(), fenix: true);
    Get.lazyPut(() => YouTubeMediaController(), fenix: true);
  }
}
