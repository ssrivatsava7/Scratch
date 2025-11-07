import 'package:media_kit/media_kit.dart';

class BackgroundAudioHandler {
  final player = Player();

  Future<void> play(String url) async {
    await player.open(Media(url));
    await player.play();
  }

  Future<void> pause() async => await player.pause();

  Future<void> stop() async => await player.stop();
}
