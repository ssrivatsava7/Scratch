import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MiniPlayerController extends GetxController {
  // Whether mini-player is active
  RxBool isVisible = false.obs;

  // Current video info
  RxString title = "".obs;
  RxString thumbnail = "".obs;
  RxString url = "".obs;

  // Dragging position
  RxDouble dx = 20.0.obs;
  RxDouble dy = 520.0.obs;

  // Player state
  RxBool isPlaying = true.obs;

  void showMiniPlayer({
    required String videoUrl,
    required String videoTitle,
    required String thumbUrl,
  }) {
    url.value = videoUrl;
    title.value = videoTitle;
    thumbnail.value = thumbUrl;

    isVisible.value = true;
  }

  void hideMiniPlayer() {
    isVisible.value = false;
  }

  void togglePlayback() {
    isPlaying.value = !isPlaying.value;
  }

  void updateDrag(double globalDx, double globalDy) {
    dx.value = globalDx;
    dy.value = globalDy;
  }
}
