import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/material.dart';

/// Robust Media Switch Controller with resolution selection
/// Inspired by YTDLnis's approach to handling multiple formats and fallbacks
class MediaSwitchController extends GetxController {
  // Players
  late final Player videoPlayer; // Media Kit for video
  late final VideoController videoController;
  late final ja.AudioPlayer audioPlayer; // just_audio for audio

  // Observables
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
  final currentVideoQuality = '1080p'.obs; // Default to 1080p
  final availableQualities = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    print('🎮 Initializing MediaSwitchController...');
    
    // Initialize video player (Media Kit)
    videoPlayer = Player(
      configuration: const PlayerConfiguration(
        title: 'Dopamine Player',
        ready: false,
      ),
    );
    videoController = VideoController(videoPlayer);
    
    // Initialize audio player (just_audio for better Windows support)
    audioPlayer = ja.AudioPlayer();
    
    // Setup listeners
    _setupVideoListeners();
    _setupAudioListeners();
    
    // Configure Windows audio
    _configureWindowsAudioSession();
    
    print('✅ MediaSwitchController initialized');
  }

  void _setupVideoListeners() {
    videoPlayer.stream.playing.listen((playing) {
      if (isVideo.value) {
        isPlaying.value = playing;
        if (playing) print('▶️ Video playing');
      }
    });

    videoPlayer.stream.duration.listen((d) {
      if (isVideo.value) {
        duration.value = d;
        print('⏱️ Video duration: ${d.inSeconds}s');
      }
    });

    videoPlayer.stream.position.listen((p) {
      if (isVideo.value) {
        position.value = p;
      }
    });

    videoPlayer.stream.buffering.listen((buffering) {
      if (isVideo.value) {
        isLoading.value = buffering;
        if (buffering) print('⏳ Video buffering...');
      }
    });
    
    videoPlayer.stream.error.listen((error) {
      print('❌ Video player error: $error');
      Get.snackbar(
        'Video Error',
        error ?? 'Unknown video playback error',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  void _setupAudioListeners() {
    // Playing state
    audioPlayer.playingStream.listen((playing) {
      if (!isVideo.value) {
        isPlaying.value = playing;
        print('🎵 Audio ${playing ? "playing" : "paused"}');
      }
    });
    
    // Duration
    audioPlayer.durationStream.listen((d) {
      if (!isVideo.value && d != null) {
        duration.value = d;
        print('⏱️ Audio duration: ${d.inSeconds}s');
      }
    });
    
    // Position
    audioPlayer.positionStream.listen((p) {
      if (!isVideo.value) {
        position.value = p;
      }
    });
    
    // Processing state (loading, buffering, etc.)
    audioPlayer.processingStateStream.listen((state) {
      if (!isVideo.value) {
        final isLoadingNow = state == ja.ProcessingState.loading || 
                             state == ja.ProcessingState.buffering;
        isLoading.value = isLoadingNow;
        
        if (state == ja.ProcessingState.ready) {
          print('✅ Audio ready to play');
        } else if (state == ja.ProcessingState.completed) {
          print('✅ Audio playback completed');
        }
        print('⚙️ Audio state: $state');
      }
    });
    
    // Player state (combined)
    audioPlayer.playerStateStream.listen((state) {
      print('🎮 Audio player - Playing: ${state.playing}, State: ${state.processingState}');
    });
    
    // Listen for errors
    audioPlayer.playbackEventStream.listen(
      (event) {
        // Event stream for monitoring
      },
      onError: (Object e, StackTrace st) {
        print('❌ Audio playback error: $e');
        print('Stack: $st');
        Get.snackbar(
          'Audio Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      },
    );
  }

  Future<void> _configureWindowsAudioSession() async {
    try {
      print('🔊 Configuring Windows audio session...');
      
      // Set initial volume to maximum
      await audioPlayer.setVolume(1.0);
      
      // Pre-load a tiny silent audio to initialize Windows audio session
      try {
        await audioPlayer.setUrl(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        ).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('⏱️ Audio session timeout (expected)');
            return null;
          },
        );
        await audioPlayer.stop();
      } catch (e) {
        print('ℹ️ Audio session init (non-critical): $e');
      }
      
      print('✅ Windows audio session configured');
    } catch (e) {
      print('⚠️ Audio session config error (non-critical): $e');
    }
  }

  /// Load media with quality selection
  Future<void> loadMedia({
    required String title,
    required String thumbnail,
    required String audio,
    required String video,
    List<String>? qualities,
    String? artist,
    String? initialQuality,
  }) async {
    try {
      print('🎵 ========== LOADING MEDIA ==========');
      print('Title: $title');
      print('Artist: ${artist ?? "Unknown"}');
      print('Audio URL: ${audio.substring(0, 50)}...');
      print('Video URL: ${video.substring(0, 50)}...');
      print('Available Qualities: ${qualities ?? []}');
      print('Initial Quality: ${initialQuality ?? "auto"}');
      
      // Update metadata
      currentTitle.value = title;
      currentThumbnail.value = thumbnail;
      currentArtist.value = artist ?? '';
      currentAudioUrl.value = audio;
      currentVideoUrl.value = video;
      availableQualities.value = qualities ?? ['1080p', '720p', '480p', '360p'];
      
      // Set quality (use provided initialQuality or determine from available)
      if (initialQuality != null && initialQuality.isNotEmpty) {
        currentVideoQuality.value = initialQuality;
      } else if (qualities != null && qualities.isNotEmpty) {
        // Default to 1080p if available, otherwise use highest available
        if (qualities.any((q) => q.contains('1080'))) {
          currentVideoQuality.value = qualities.firstWhere((q) => q.contains('1080'));
        } else {
          currentVideoQuality.value = qualities.first;
        }
      }
      
      print('🎬 Set video quality to: ${currentVideoQuality.value}');
      
      isVideo.value = false; // Start with audio mode
      
      // Stop any existing playback
      await audioPlayer.stop();
      await videoPlayer.stop();
      
      isLoading.value = true;

      // Load audio using just_audio (better Windows support)
      print('⏳ Loading audio stream...');
      await audioPlayer.setVolume(1.0);
      
      final audioDuration = await audioPlayer.setUrl(audio);
      print('✅ Audio loaded! Duration: ${audioDuration?.inSeconds ?? 0}s');
      
      // Start playback
      print('▶️ Starting playback...');
      await audioPlayer.play();
      
      // Verify playback started
      await Future.delayed(const Duration(milliseconds: 500));
      print('🎮 Playback state:');
      print('   - Playing: ${audioPlayer.playing}');
      print('   - Volume: ${audioPlayer.volume}');
      print('   - Position: ${audioPlayer.position.inSeconds}s');
      print('   - Duration: ${audioPlayer.duration?.inSeconds ?? 0}s');
      print('   - State: ${audioPlayer.processingState}');
      
      isLoading.value = false;
      print('✅ ========== MEDIA LOADED ==========');
      
      // Success message
      Get.snackbar(
        'Now Playing',
        title,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      
    } catch (e, stackTrace) {
      print('❌ ========== ERROR LOADING MEDIA ==========');
      print('Error: $e');
      print('Stack: $stackTrace');
      print('❌ ==========================================');
      
      isLoading.value = false;
      
      Get.snackbar(
        'Playback Error',
        'Failed to load media: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Switch to video mode with proper quality
  Future<void> switchToVideo({String? quality}) async {
    if (currentVideoUrl.value.isEmpty) {
      Get.snackbar('Error', 'No video URL available',
        snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    try {
      print('🎬 Switching to video mode...');
      print('Current video quality: ${currentVideoQuality.value}');
      print('Video URL: ${currentVideoUrl.value.substring(0, 100)}...');
      
      isVideo.value = true;
      
      // Save current position
      final currentPos = position.value;
      
      // Stop audio player
      await audioPlayer.pause();
      
      // Load video
      isLoading.value = true;
      print('⏳ Loading video player...');
      await videoPlayer.open(Media(currentVideoUrl.value), play: false);
      
      // Seek to saved position
      if (currentPos.inSeconds > 0) {
        print('⏩ Seeking to ${currentPos.inSeconds}s');
        await videoPlayer.seek(currentPos);
      }
      
      // Start video playback
      print('▶️ Starting video playback...');
      await videoPlayer.play();
      isLoading.value = false;
      
      print('✅ Switched to video mode at ${currentVideoQuality.value}');
    } catch (e) {
      print('❌ Error switching to video: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to switch to video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }

  /// Switch to audio mode
  Future<void> switchToAudio() async {
    if (currentAudioUrl.value.isEmpty) {
      Get.snackbar('Error', 'No audio URL available',
        snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    try {
      print('🎵 Switching to audio mode...');
      isVideo.value = false;
      
      // Save current position
      final currentPos = position.value;
      
      // Stop video player
      await videoPlayer.pause();
      
      // Resume/load audio
      isLoading.value = true;
      
      // If audio is already loaded, just seek and play
      if (audioPlayer.duration != null) {
        await audioPlayer.seek(currentPos);
        await audioPlayer.play();
      } else {
        // Reload audio
        await audioPlayer.setUrl(currentAudioUrl.value);
        if (currentPos.inSeconds > 0) {
          await audioPlayer.seek(currentPos);
        }
        await audioPlayer.play();
      }
      
      isLoading.value = false;
      print('✅ Switched to audio mode');
    } catch (e) {
      print('❌ Error switching to audio: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to switch to audio: $e',
        snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Change video quality with proper error handling
  Future<void> changeVideoQuality(String quality, String newVideoUrl) async {
    try {
      print('🎬 Changing video quality to: $quality');
      print('New video URL: ${newVideoUrl.substring(0, 100)}...');
      
      // Save current position
      final currentPos = position.value;
      
      // Update quality settings
      currentVideoQuality.value = quality;
      currentVideoUrl.value = newVideoUrl;
      
      // Only switch if currently in video mode
      if (isVideo.value) {
        isLoading.value = true;
        
        print('⏸️ Pausing current video...');
        await videoPlayer.pause();
        
        print('⏳ Loading new quality stream...');
        await videoPlayer.open(Media(newVideoUrl), play: false);
        
        print('⏩ Seeking to position: ${currentPos.inSeconds}s');
        await videoPlayer.seek(currentPos);
        
        print('▶️ Resuming playback...');
        await videoPlayer.play();
        
        isLoading.value = false;
        
        print('✅ Quality changed to $quality successfully');
        
        Get.snackbar(
          'Quality Changed',
          'Now playing at $quality',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('ℹ️ Quality updated to $quality (will apply when switching to video mode)');
      }
    } catch (e) {
      print('❌ Error changing quality: $e');
      isLoading.value = false;
      
      Get.snackbar(
        'Quality Change Failed',
        'Failed to change quality: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Playback controls
  Future<void> play() async {
    if (isVideo.value) {
      await videoPlayer.play();
    } else {
      await audioPlayer.play();
    }
  }
  
  Future<void> pause() async {
    if (isVideo.value) {
      await videoPlayer.pause();
    } else {
      await audioPlayer.pause();
    }
  }
  
  Future<void> seek(Duration position) async {
    if (isVideo.value) {
      await videoPlayer.seek(position);
    } else {
      await audioPlayer.seek(position);
    }
  }
  
  Future<void> stop() async {
    await videoPlayer.stop();
    await audioPlayer.stop();
    currentTitle.value = '';
    currentThumbnail.value = '';
    currentAudioUrl.value = '';
    currentVideoUrl.value = '';
    availableQualities.clear();
  }

  /// Test audio output
  Future<void> testAudioOutput() async {
    try {
      print('🧪 ========== TESTING AUDIO OUTPUT ==========');
      
      const testUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
      
      print('🧪 Loading test audio...');
      await audioPlayer.setVolume(1.0);
      final duration = await audioPlayer.setUrl(testUrl);
      
      print('🧪 Test audio loaded. Duration: ${duration?.inSeconds ?? 0}s');
      print('🧪 Starting test playback...');
      
      await audioPlayer.play();
      
      await Future.delayed(const Duration(seconds: 2));
      
      print('🧪 Test state:');
      print('   - Playing: ${audioPlayer.playing}');
      print('   - Position: ${audioPlayer.position.inSeconds}s');
      print('   - Volume: ${audioPlayer.volume}');
      
      if (audioPlayer.playing && audioPlayer.position.inSeconds > 0) {
        print('✅ Audio output WORKS!');
        Get.snackbar(
          'Test Success! ✅',
          'Audio output is working! Issue might be with YouTube URLs.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        print('❌ Audio output test FAILED');
        Get.snackbar(
          'Test Failed ❌',
          'Audio not playing. Check Windows sound settings!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
      
      print('🧪 ========================================');
    } catch (e) {
      print('❌ Test audio error: $e');
      Get.snackbar(
        'Test Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    print('🔚 Disposing MediaSwitchController...');
    videoPlayer.dispose();
    audioPlayer.dispose();
    super.onClose();
  }
}
