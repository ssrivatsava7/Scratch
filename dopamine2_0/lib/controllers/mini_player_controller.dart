import 'package:get/get.dart';

class MiniPlayerController extends GetxController {
  final isVisible = false.obs;

  void show() {
    isVisible.value = true;
  }

  void hide() {
    isVisible.value = false;
  }

  void toggle() {
    isVisible.value = !isVisible.value;
  }
}
