import 'package:get/get.dart';
import '../routes/app_routes.dart';

class NavController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    
    switch (index) {
      case 0:
        Get.offAllNamed(Routes.HOME);
        break;
      case 1:
        Get.toNamed(Routes.PLAYLISTS);
        break;
      case 2:
        Get.toNamed(Routes.FAVORITES);
        break;
      case 3:
        Get.toNamed(Routes.DOWNLOADS);
        break;
      case 4:
        Get.toNamed(Routes.SETTINGS);
        break;
    }
  }
}
