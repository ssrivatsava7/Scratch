import 'package:get/get.dart';

class MiniPlayerController extends GetxController {
  final isVisible = false.obs;
  final currentPlaylist = <MediaItem>[].obs;
  final currentIndex = 0.obs;

  void show() {
    isVisible.value = true;
  }

  void hide() {
    isVisible.value = false;
  }

  void toggle() {
    isVisible.value = !isVisible.value;
  }

  /// Play a list of media items starting from a specific index
  void playMediaList(List<MediaItem> mediaList, int startIndex) {
    if (mediaList.isEmpty) return;

    currentPlaylist.value = List<MediaItem>.from(mediaList);
    currentIndex.value = startIndex.clamp(0, mediaList.length - 1);

    final mediaItem = mediaList[currentIndex.value];
    playMedia(mediaItem);
  }

  void playMedia(MediaItem mediaItem) {
    // Implementation for playing a single media item
  }
}

class MediaItem {
  // MediaItem class implementation
}
