import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

class AudioController extends GetxController {
  late final Player player;
  RxBool isPlaying = false.obs;

  // Title for UI
  String _currentTitle = "";
  String get currentTitle => _currentTitle;

  @override
  void onInit() {
    super.onInit();
    _initPlayer();
  }

  void _initPlayer() {
    // Must NOT be awaited
    MediaKit.ensureInitialized();
    player = Player();
  }

  /// Updates the UI title
  void setTitle(String title) {
    _currentTitle = title;
    update();
  }

  /// Main play function
  Future<void> play(String url, {String title = ""}) async {
    if (title.isNotEmpty) {
      setTitle(title);
    }

    await player.open(Media(url));
    isPlaying.value = true;
  }

  /// Alias so screens calling playAudio() don't break
  void playAudio(String url, {String title = ""}) {
    play(url, title: title);
  }

  void pause() {
    player.pause();
    isPlaying.value = false;
  }

  void resume() {
    player.play();
    isPlaying.value = true;
  }

  /// Needed by audio_player_screen
  void togglePlayback() {
    if (isPlaying.value) {
      pause();
    } else {
      resume();
    }
  }

  /// Needed by audio_player_screen
  void stop() {
    player.stop();
    isPlaying.value = false;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
