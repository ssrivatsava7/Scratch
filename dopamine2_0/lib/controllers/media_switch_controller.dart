import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaSwitchController extends GetxController {
  late final Player player;
  late final VideoController videoController;

  final isPlaying = false.obs;
  final isVideo = false.obs;
  final currentTitle = ''.obs;
  final currentThumbnail = ''.obs;
  final currentAudioUrl = ''.obs;
  final currentVideoUrl = ''.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    player = Player();
    videoController = VideoController(player);

    // Listen to player state
    player.stream.playing.listen((playing) {
      isPlaying.value = playing;
    });

    player.stream.duration.listen((d) {
      duration.value = d;
    });

    player.stream.position.listen((p) {
      position.value = p;
    });

    player.stream.buffering.listen((buffering) {
      isLoading.value = buffering;
    });
  }

  Future<void> loadMedia({
    required String title,
    required String thumbnail,
    required String audio,
    required String video,
  }) async {
    try {
      currentTitle.value = title;
      currentThumbnail.value = thumbnail;
      currentAudioUrl.value = audio;
      currentVideoUrl.value = video;
      isVideo.value = false; // Default to audio mode

      print('Loading media: $audio');

      // Load and play the audio
      await player.open(Media(audio), play: true);
      
      print('Media loaded successfully');
    } catch (e) {
      print('Error loading media: $e');
      Get.snackbar(
        'Playback Error',
        'Failed to play media. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> switchToVideo() async {
    if (currentVideoUrl.value.isNotEmpty) {
      isVideo.value = true;
      final currentPos = position.value;
      await player.pause();
      await player.open(Media(currentVideoUrl.value), play: false);
      if (currentPos.inSeconds > 0) {
        await player.seek(currentPos);
      }
      await player.play();
    }
  }

  Future<void> switchToAudio() async {
    if (currentAudioUrl.value.isNotEmpty) {
      isVideo.value = false;
      final currentPos = position.value;
      await player.pause();
      await player.open(Media(currentAudioUrl.value), play: false);
      if (currentPos.inSeconds > 0) {
        await player.seek(currentPos);
      }
      await player.play();
    }
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> stop() async {
    await player.stop();
    currentTitle.value = '';
    currentThumbnail.value = '';
    currentAudioUrl.value = '';
    currentVideoUrl.value = '';
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
