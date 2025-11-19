import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:just_audio/just_audio.dart' as ja;

class MediaSwitchController extends GetxController {
  late final Player player; // For video only
  late final VideoController videoController;
  late final ja.AudioPlayer audioPlayer; // For audio only

  final currentTitle = ''.obs;
  final currentThumbnail = ''.obs;
  final currentArtist = ''.obs;
  final isPlaying = false.obs;
  final isVideo = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final isLoading = false.obs;
  
  final currentAudioUrl = ''.obs;
  final currentVideoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize video player
    player = Player();
    videoController = VideoController(player);
    
    // Initialize audio player
    audioPlayer = ja.AudioPlayer();

    // Listen to video player streams
    player.stream.playing.listen((playing) {
      if (isVideo.value) {
        isPlaying.value = playing;
      }
    });

    player.stream.duration.listen((d) {
      if (isVideo.value) {
        duration.value = d;
      }
    });

    player.stream.position.listen((p) {
      if (isVideo.value) {
        position.value = p;
      }
    });

    player.stream.buffering.listen((buffering) {
      if (isVideo.value) {
        isLoading.value = buffering;
      }
    });
    
    player.stream.error.listen((error) {
      print('Player error: $error');
    });
    
    // Listen to audio player streams
    audioPlayer.playingStream.listen((playing) {
      if (!isVideo.value) {
        isPlaying.value = playing;
      }
    });
    
    audioPlayer.durationStream.listen((d) {
      if (!isVideo.value && d != null) {
        duration.value = d;
      }
    });
    
    audioPlayer.positionStream.listen((p) {
      if (!isVideo.value) {
        position.value = p;
      }
    });
    
    audioPlayer.processingStateStream.listen((state) {
      if (!isVideo.value) {
        isLoading.value = state == ja.ProcessingState.loading || state == ja.ProcessingState.buffering;
      }
    });
    
    audioPlayer.playerStateStream.listen((state) {
      print('Audio player state: ${state.playing}');
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
      isVideo.value = false;

      print('Loading audio: $audio');

      // Use just_audio for audio (Windows compatible!)
      await audioPlayer.setVolume(1.0); // Full volume
      await audioPlayer.setUrl(audio);
      await audioPlayer.play();
      
      print('Audio loaded and playing at full volume');
    } catch (e) {
      print('Error loading audio: $e');
      Get.snackbar(
        'Error',
        'Failed to load audio',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> switchToVideo() async {
    if (currentVideoUrl.value.isNotEmpty) {
      isVideo.value = true;
      final currentPos = position.value;
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
      await player.open(Media(currentAudioUrl.value), play: false);
      if (currentPos.inSeconds > 0) {
        await player.seek(currentPos);
      }
      await player.play();
    }
  }
  
  Future<void> play() async {
    if (isVideo.value) {
      await player.play();
    } else {
      await audioPlayer.play();
    }
  }
  
  Future<void> pause() async {
    if (isVideo.value) {
      await player.pause();
    } else {
      await audioPlayer.pause();
    }
  }
  
  Future<void> seek(Duration position) async {
    if (isVideo.value) {
      await player.seek(position);
    } else {
      await audioPlayer.seek(position);
    }
  }
  
  Future<void> stop() async {
    await player.stop();
    await audioPlayer.stop();
    currentTitle.value = '';
    currentThumbnail.value = '';
    currentAudioUrl.value = '';
    currentVideoUrl.value = '';
  }

  @override
  void onClose() {
    player.dispose();
    audioPlayer.dispose();
    super.onClose();
  }
}
