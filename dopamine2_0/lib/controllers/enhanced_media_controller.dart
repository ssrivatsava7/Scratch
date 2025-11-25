import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt;

/// Enhanced Media Controller with YouTube Player Support
/// Supports both muxed streams (up to 720p) and dedicated YouTube player (up to 4K)
class EnhancedMediaController extends GetxController {
  // Players
  late final mk.Player videoPlayer; // Media Kit for muxed streams
  late final VideoController videoController;
  late final ja.AudioPlayer audioPlayer; // just_audio for audio-only
  yt.YoutubePlayerController? youtubeController; // YouTube player for high quality

  // Observables
  final currentTitle = ''.obs;
  final currentThumbnail = ''.obs;
  final currentArtist = ''.obs;
  final isPlaying = false.obs;
  final isVideo = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final isLoading = false.obs;
  
  final currentVideoId = ''.obs;
  final currentAudioUrl = ''.obs;
  final currentVideoUrl = ''.obs;
  final currentVideoQuality = '1080p'.obs; // Default to 1080p now
  final availableQualities = <String>[].obs;
  final useYouTubePlayer = false.obs; // Track which player is active

  @override
  void onInit() {
    super.onInit();
    
    print('🎮 Initializing EnhancedMediaController with YouTube player support...');
    
    // Initialize MediaKit player (for muxed streams and audio)
    videoPlayer = mk.Player(
      configuration: const mk.PlayerConfiguration(
        title: 'Dopamine Player',
      ),
    );
    videoController = VideoController(videoPlayer);
    
    // Initialize audio player
    audioPlayer = ja.AudioPlayer();
    
    // Setup listeners
    _setupVideoListeners();
    _setupAudioListeners();
    
    print('✅ EnhancedMediaController initialized with dual player support');
  }

  void _setupVideoListeners() {
    videoPlayer.stream.playing.listen((playing) {
      if (isVideo.value && !useYouTubePlayer.value) {
        isPlaying.value = playing;
      }
    });

    videoPlayer.stream.duration.listen((d) {
      if (isVideo.value && !useYouTubePlayer.value) {
        duration.value = d;
      }
    });

    videoPlayer.stream.position.listen((p) {
      if (isVideo.value && !useYouTubePlayer.value) {
        position.value = p;
      }
    });

    videoPlayer.stream.buffering.listen((buffering) {
      if (isVideo.value && !useYouTubePlayer.value) {
        isLoading.value = buffering;
      }
    });
  }

  void _setupAudioListeners() {
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
  }

  /// Load media with automatic player selection
  Future<void> loadMedia({
    required String videoId,
    required String title,
    required String thumbnail,
    String? artist,
    required String audio,
    required String video,
    List<String>? qualities,
    String? initialQuality,
  }) async {
    try {
      print('🎵 Loading media: $title');
      print('Video ID: $videoId');
      
      currentVideoId.value = videoId;
      currentTitle.value = title;
      currentThumbnail.value = thumbnail;
      currentArtist.value = artist ?? '';
      currentAudioUrl.value = audio;
      currentVideoUrl.value = video;
      availableQualities.value = qualities ?? ['1080p', '720p', '480p', '360p'];
      
      // Set initial quality
      if (initialQuality != null && initialQuality.isNotEmpty) {
        currentVideoQuality.value = initialQuality;
      } else if (qualities != null && qualities.isNotEmpty) {
        // Prefer 1080p if available
        if (qualities.any((q) => q.contains('1080'))) {
          currentVideoQuality.value = qualities.firstWhere((q) => q.contains('1080'));
        } else {
          currentVideoQuality.value = qualities.first;
        }
      }
      
      print('🎬 Set video quality to: ${currentVideoQuality.value}');
      
      // Start with audio mode
      isVideo.value = false;
      useYouTubePlayer.value = false;
      
      // Stop any existing playback
      await audioPlayer.stop();
      await videoPlayer.stop();
      if (youtubeController != null) {
        await youtubeController!.stopVideo();
      }
      
      isLoading.value = true;

      // Load audio
      print('⏳ Loading audio stream...');
      await audioPlayer.setVolume(1.0);
      await audioPlayer.setUrl(audio);
      await audioPlayer.play();
      
      isLoading.value = false;
      isPlaying.value = true;
      
      print('✅ Media loaded and playing in audio mode');
    } catch (e) {
      print('❌ Error loading media: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load media: $e',
        snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Switch to video mode with intelligent player selection
  Future<void> switchToVideo({String? quality}) async {
    try {
      print('🎬 Switching to video mode...');
      final currentPos = position.value;
      
      // Determine which player to use based on quality
      final qualityHeight = int.tryParse(
        currentVideoQuality.value
          .replaceAll('p', '')
          .replaceAll(' (4K)', '')
          .replaceAll(' (2K)', '')
      ) ?? 720;
      
      // Use YouTube player for 1080p+ (reliable high quality)
      // Use MediaKit for 720p and below (muxed streams)
      if (qualityHeight >= 1080 && currentVideoId.value.isNotEmpty) {
        print('🎯 Quality ${qualityHeight}p: Using YouTube iframe player (reliable high quality)');
        await _switchToYouTubePlayer(currentPos);
      } else {
        print('🎯 Quality ${qualityHeight}p: Using MediaKit with muxed stream');
        await _switchToMediaKitPlayer(currentPos);
      }
      
      isVideo.value = true;
      isLoading.value = false;
      
      print('✅ Switched to video mode');
    } catch (e) {
      print('❌ Error switching to video: $e');
      isLoading.value = false;
      isVideo.value = false;
      
      Get.snackbar('Error', 'Failed to switch to video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }

  /// Switch to YouTube iframe player for high quality
  Future<void> _switchToYouTubePlayer(Duration startPosition) async {
    print('📺 Initializing YouTube iframe player...');
    
    // Stop audio player
    await audioPlayer.stop();
    
    // Stop MediaKit if running
    await videoPlayer.stop();
    
    // Create YouTube controller if not exists
    if (youtubeController == null) {
      youtubeController = yt.YoutubePlayerController(
        params: const yt.YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
          loop: false,
        ),
      );
      
      // Setup listener for YouTube player
      youtubeController!.listen((event) {
        if (useYouTubePlayer.value) {
          isPlaying.value = event.playerState == yt.PlayerState.playing;
        }
      });
    }
    
    // Load video
    await youtubeController!.loadVideoById(videoId: currentVideoId.value);
    
    // Wait a bit for player to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Seek to saved position
    if (startPosition.inSeconds > 0) {
      print('⏩ Seeking YouTube player to ${startPosition.inSeconds}s');
      await youtubeController!.seekTo(seconds: startPosition.inSeconds.toDouble());
    }
    
    // Play
    await youtubeController!.playVideo();
    
    useYouTubePlayer.value = true;
    print('✅ YouTube iframe player active');
  }

  /// Switch to MediaKit player for muxed streams
  Future<void> _switchToMediaKitPlayer(Duration startPosition) async {
    print('📺 Using MediaKit player with muxed stream...');
    
    // Stop audio player
    await audioPlayer.stop();
    
    // Stop YouTube player if active
    if (youtubeController != null && useYouTubePlayer.value) {
      await youtubeController!.stopVideo();
    }
    
    useYouTubePlayer.value = false;
    
    // Load muxed stream
    await videoPlayer.open(mk.Media(currentVideoUrl.value), play: false);
    
    // Wait for video to load
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Seek to position
    if (startPosition.inSeconds > 0) {
      print('⏩ Seeking MediaKit to ${startPosition.inSeconds}s');
      await videoPlayer.seek(startPosition);
    }
    
    // Play
    await videoPlayer.play();
    
    print('✅ MediaKit player active');
  }

  /// Switch to audio mode
  Future<void> switchToAudio() async {
    try {
      print('🎵 Switching to audio mode...');
      isVideo.value = false;
      
      final currentPos = position.value;
      
      // Stop video players
      if (useYouTubePlayer.value && youtubeController != null) {
        await youtubeController!.pauseVideo();
      } else {
        await videoPlayer.pause();
      }
      
      isLoading.value = true;
      
      // Resume audio
      if (audioPlayer.duration != null) {
        await audioPlayer.seek(currentPos);
        await audioPlayer.play();
      } else {
        await audioPlayer.setUrl(currentAudioUrl.value);
        if (currentPos.inSeconds > 0) {
          await audioPlayer.seek(currentPos);
        }
        await audioPlayer.play();
      }
      
      useYouTubePlayer.value = false;
      isLoading.value = false;
      
      print('✅ Switched to audio mode');
    } catch (e) {
      print('❌ Error switching to audio: $e');
      isLoading.value = false;
    }
  }

  /// Playback controls
  Future<void> play() async {
    try {
      if (isVideo.value) {
        if (useYouTubePlayer.value && youtubeController != null) {
          await youtubeController!.playVideo();
        } else {
          await videoPlayer.play();
        }
      } else {
        await audioPlayer.play();
      }
    } catch (e) {
      print('❌ Play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      if (isVideo.value) {
        if (useYouTubePlayer.value && youtubeController != null) {
          await youtubeController!.pauseVideo();
        } else {
          await videoPlayer.pause();
        }
      } else {
        await audioPlayer.pause();
      }
    } catch (e) {
      print('❌ Pause error: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      if (isVideo.value) {
        if (useYouTubePlayer.value && youtubeController != null) {
          await youtubeController!.seekTo(seconds: position.inSeconds.toDouble());
        } else {
          await videoPlayer.seek(position);
        }
      } else {
        await audioPlayer.seek(position);
      }
    } catch (e) {
      print('❌ Seek error: $e');
    }
  }

  Future<void> stop() async {
    await videoPlayer.stop();
    await audioPlayer.stop();
    if (youtubeController != null) {
      await youtubeController!.stopVideo();
    }
    currentTitle.value = '';
    currentThumbnail.value = '';
    currentVideoId.value = '';
    currentAudioUrl.value = '';
    currentVideoUrl.value = '';
    availableQualities.clear();
    useYouTubePlayer.value = false;
  }

  @override
  void onClose() {
    videoPlayer.dispose();
    audioPlayer.dispose();
    youtubeController?.close();
    super.onClose();
  }
}
