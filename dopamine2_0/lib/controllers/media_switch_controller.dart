import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:flutter/material.dart';
import '../services/youtube_service.dart';

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
  final currentVideoQuality = '720p'.obs; // Default to 720p (max for muxed streams)
  final availableQualities = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    print('🎮 Initializing MediaSwitchController...');
    
    // Initialize video player (Media Kit)
    videoPlayer = Player(
      configuration: const PlayerConfiguration(
        title: 'Dopamine Player',
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
        // Update playing state based on video player
        isPlaying.value = playing;
        if (playing) {
          print('▶️ Video playing');
        }
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
        error,
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
        // Only update playing state in audio-only mode
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
    
    // Listen for errors with better error handling
    // Note: just_audio_windows may emit threading warnings which are non-critical
    audioPlayer.playbackEventStream.listen(
      (event) {
        // Event stream for monitoring
        // Don't log every event to reduce noise
      },
      onError: (Object e, StackTrace st) {
        // Suppress non-critical threading warnings from just_audio_windows
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('operation aborted') || 
            errorStr.contains('platform thread') ||
            errorStr.contains('loading interrupted') ||
            errorStr.contains('channel sent a message')) {
          // These are known non-critical warnings from just_audio_windows
          // They don't affect playback and can be safely ignored
          return;
        }
        
        // Only log and show truly critical errors
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
      cancelOnError: false, // Continue listening even after errors
    );
  }

  Future<void> _configureWindowsAudioSession() async {
    try {
      print('🔊 Configuring Windows audio session...');
      
      // Set initial volume to maximum
      await audioPlayer.setVolume(1.0);
      
      // Skip pre-initialization as it causes threading issues
      // The audio player will initialize properly when actual media is loaded
      print('✅ Windows audio session configured');
      
    } catch (e) {
      print('⚠️ Audio session config error (non-critical): $e');
      // Don't propagate the error - this is non-critical
    }
  }

  /// Load media directly from ID (Instant Playback)
  Future<void> loadMediaFromId({
    required String videoId,
    required String title,
    required String thumbnail,
    required String author,
    bool isVideoMode = false,
  }) async {
    // 1. Update UI immediately
    currentTitle.value = title;
    currentThumbnail.value = thumbnail;
    currentArtist.value = author;
    isLoading.value = true;
    
    // Reset state
    isVideo.value = false;
    currentAudioUrl.value = '';
    currentVideoUrl.value = '';
    availableQualities.clear();
    
    // Stop previous playback
    await audioPlayer.stop();
    await videoPlayer.stop();
    
    try {
      // 2. Fetch streams in background
      print('🚀 Fetching streams for instant playback...');
      final streams = await YouTubeService.getStreamUrls(videoId);
      final qualities = await YouTubeService.getAvailableQualities(videoId);
      
      final audioUrl = streams['audioUrl'];
      final videoUrl = streams['videoUrl'];
      
      if (audioUrl == null) throw Exception("No audio stream found");
      
      // 3. Load the actual media
      // 3. Load the actual media
      await loadMedia(
        title: title,
        thumbnail: thumbnail,
        audio: audioUrl,
        video: videoUrl ?? audioUrl,
        artist: author,
        qualities: qualities,
        autoPlay: !isVideoMode,
        startInVideo: isVideoMode,
      );
      
      // switchToVideo is now handled inside loadMedia if startInVideo is true
      
    } catch (e) {
      print('❌ Error in instant load: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load media: $e');
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
    bool autoPlay = true,
    bool startInVideo = false,
  }) async {
    try {
      print('🎵 ========== LOADING MEDIA ==========');
      print('Title: $title');
      print('Artist: ${artist ?? "Unknown"}');
      print('Audio URL: ${audio.substring(0, 50)}...');
      print('Video URL: ${video.substring(0, 50)}...');
      print('Available Qualities: ${qualities ?? []}');
      print('Initial Quality: ${initialQuality ?? "auto"}');
      print('Start in Video: $startInVideo');
      
      // Update metadata
      currentTitle.value = title;
      currentThumbnail.value = thumbnail;
      currentArtist.value = artist ?? '';
      currentAudioUrl.value = audio;
      currentVideoUrl.value = video;
      availableQualities.value = qualities ?? ['720p', '480p', '360p', '240p'];
      
      // Set quality (use provided initialQuality or determine from available)
      if (initialQuality != null && initialQuality.isNotEmpty) {
        currentVideoQuality.value = initialQuality;
      } else if (qualities != null && qualities.isNotEmpty) {
        // Default to 720p if available, otherwise use highest available
        if (qualities.any((q) => q.contains('720'))) {
          currentVideoQuality.value = qualities.firstWhere((q) => q.contains('720'));
        } else {
          currentVideoQuality.value = qualities.first;
        }
      }
      
      print('🎬 Set video quality to: ${currentVideoQuality.value}');

      // Stop any existing playback first
      try {
        await audioPlayer.stop();
      } catch (e) {
        print('⚠️ Error stopping audio: $e');
      }
      await videoPlayer.stop();
      
      // If starting in video mode, skip audio loading entirely
      if (startInVideo) {
        print('🎬 Starting directly in video mode...');
        isVideo.value = true;
        await switchToVideo(force: true);
        return;
      }
      
      isVideo.value = false; // Start with audio mode
      isLoading.value = true;

      // Load audio using just_audio (better Windows support)
      print('⏳ Loading audio stream...');
      await audioPlayer.setVolume(1.0);
      
      final audioDuration = await audioPlayer.setUrl(audio);
      print('✅ Audio loaded! Duration: ${audioDuration?.inSeconds ?? 0}s');
      
      // Start playback only if autoPlay is true
      if (autoPlay) {
        print('▶️ Starting playback...');
        await audioPlayer.play();
      } else {
        print('⏸️ Auto-play disabled (waiting for video switch or user action)');
      }
      
      // Verify playback started
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

  /// Switch to video mode with muxed stream (reliable playback)
  Future<void> switchToVideo({String? quality, bool force = false}) async {
    if (currentVideoUrl.value.isEmpty) {
      Get.snackbar('Error', 'No video URL available',
        snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Prevent re-entry if already loading
    if (isLoading.value && !force) {
      print('⚠️ Already loading/switching, ignoring request');
      return;
    }
    
    try {
      print('🎬 Switching to video mode...');
      print('Current video quality: ${currentVideoQuality.value}');
      print('Video URL: ${currentVideoUrl.value.substring(0, 100)}...');
      
      // Save current position BEFORE changing mode
      final currentPos = position.value;
      
      // Stop audio player completely to avoid interference
      print('⏸️ Stopping audio player...');
      try {
        await audioPlayer.stop();
      } catch (e) {
        print('⚠️ Error stopping audio: $e');
      }
      
      // Set video mode
      isVideo.value = true;
      isLoading.value = true;
      
      print('⏳ Loading video player at quality ${currentVideoQuality.value}...');
      
      // WORKAROUND: Using muxed streams only (max 720p) for reliable playback
      // Muxed streams contain both audio and video in a single stream
      print('📺 Using muxed stream (video+audio together) for reliable playback');
      print('🎯 Target quality: ${currentVideoQuality.value}');
      
      // Stop any existing video playback
      await videoPlayer.stop();
      
      // Load muxed stream
      print('📹 Opening muxed stream...');
      await videoPlayer.open(Media(currentVideoUrl.value), play: false);
      
      // Wait for video to be ready (safer than fixed delay)
      // Check if width/height are available, if not wait a bit
      int retries = 0;
      while ((videoPlayer.state.width == null || videoPlayer.state.width == 0) && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
      print('📺 Video loaded - Width: ${videoPlayer.state.width}, Height: ${videoPlayer.state.height}');
      
      // Seek to saved position
      if (currentPos.inSeconds > 0) {
        print('⏩ Seeking to ${currentPos.inSeconds}s');
        await videoPlayer.seek(currentPos);
      }
      
      // Wait for seek to complete
      // await Future.delayed(const Duration(milliseconds: 200));
      
      // Start video playback
      print('▶️ Starting video playback...');
      await videoPlayer.play();
        
        print('✅ Switched to video mode with embedded audio');
        print('✅ Actual video resolution: ${videoPlayer.state.width}x${videoPlayer.state.height}');
      
      isLoading.value = false;
      
      print('📺 Video tracks: ${videoPlayer.state.tracks.video.length}');
      print('🎵 Audio tracks: ${videoPlayer.state.tracks.audio.length}');
    } catch (e, stackTrace) {
      print('❌ Error switching to video: $e');
      print('Stack trace: $stackTrace');
      isLoading.value = false;
      isVideo.value = false; // Revert to audio mode on error
      
      // Try to resume audio playback on error
      try {
        if (audioPlayer.processingState != ja.ProcessingState.ready) {
          await audioPlayer.setUrl(currentAudioUrl.value);
        }
        await audioPlayer.play();
      } catch (audioError) {
        print('⚠️ Could not resume audio: $audioError');
      }
      
      Get.snackbar('Error', 'Failed to switch to video: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
    }
  }

  /// Switch to audio mode
  Future<void> switchToAudio({bool force = false}) async {
    if (currentAudioUrl.value.isEmpty) {
      Get.snackbar('Error', 'No audio URL available',
        snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Prevent re-entry if already loading
    if (isLoading.value && !force) {
      print('⚠️ Already loading/switching, ignoring request');
      return;
    }
    
    try {
      print('🎵 Switching to audio mode...');
      isVideo.value = false;
      
      // Save current position
      final currentPos = position.value;
      
      // Stop video player completely to release resources
      try {
        await videoPlayer.stop();
      } catch (e) {
        print('⚠️ Error stopping video: $e');
      }
      
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

  /// Change video quality with proper error handling (muxed streams)
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
        
        print('⏳ Loading new quality stream (muxed)...');
        await videoPlayer.open(Media(newVideoUrl), play: false);
        
        // Wait for video to be ready
        int retries = 0;
        while ((videoPlayer.state.width == null || videoPlayer.state.width == 0) && retries < 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          retries++;
        }
        
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

  // Playback controls (simplified for muxed streams)
  Future<void> play() async {
    try {
      if (isVideo.value) {
        // In video mode - play video (contains audio in muxed stream)
        print('▶️ Playing video');
        await videoPlayer.play();
      } else {
        // Audio-only mode
        print('▶️ Playing audio');
        await audioPlayer.play();
      }
    } catch (e) {
      print('❌ Play error: $e');
    }
  }
  
  Future<void> pause() async {
    try {
      if (isVideo.value) {
        // In video mode - pause video
        print('⏸️ Pausing video');
        await videoPlayer.pause();
      } else {
        // Audio-only mode
        print('⏸️ Pausing audio');
        await audioPlayer.pause();
      }
    } catch (e) {
      print('❌ Pause error: $e');
    }
  }
  
  Future<void> seek(Duration position) async {
    try {
      if (isVideo.value) {
        // In video mode - seek video
        print('⏩ Seeking video to ${position.inSeconds}s');
        await videoPlayer.seek(position);
      } else {
        // Audio-only mode
        print('⏩ Seeking audio to ${position.inSeconds}s');
        await audioPlayer.seek(position);
      }
    } catch (e) {
      print('❌ Seek error: $e');
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
