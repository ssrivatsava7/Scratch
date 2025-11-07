import 'package:media_kit/media_kit.dart';
import 'package:media_kit_libs_audio/media_kit_libs_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:get/get.dart';
import '../models/video_item.dart';
import '../services/storage_service.dart';
import 'history_controller.dart';



class AudioController extends GetxController {
  late final Player _player;
  final StorageService _storage = StorageService();
  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;
  RxString currentError = ''.obs;
  RxList<Video> searchResults = <Video>[].obs;
  Rx<VideoItem?> currentVideo = Rx<VideoItem?>(null);
  RxBool backgroundPlaybackEnabled = true.obs;

  @override
  void onInit() {
    _player = Player();
    _player.setVolume(100);
print("AudioController: Player initialized with volume 100%");
    _storage.init();
    _loadBackgroundPlaybackPreference();
    super.onInit();
  }

  Future<void> _loadBackgroundPlaybackPreference() async {
    // Load preference from storage if needed
    // For now, default to enabled
    backgroundPlaybackEnabled.value = true;
  }

  void toggleBackgroundPlayback() {
    backgroundPlaybackEnabled.value = !backgroundPlaybackEnabled.value;
    if (backgroundPlaybackEnabled.value && isPlaying.value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  void togglePlayback() {
    if (isPlaying.value) {
      _player.pause();
      if (backgroundPlaybackEnabled.value) {
        WakelockPlus.disable();
      }
    } else {
      _player.play();
      if (backgroundPlaybackEnabled.value) {
        WakelockPlus.enable();
      }
    }
    isPlaying.value = !isPlaying.value;
  }

  Future<void> loadAudio(String videoId, {String? title, String? author}) async {
    isLoading.value = true;
    currentError.value = '';
    YoutubeExplode? yt;

    try {
      // Check cache first
      final cachedData = await _storage.getCachedUrl(videoId);
      
      if (cachedData != null) {
        await _player.open(Media(cachedData['url']));
        _player.play();
        isPlaying.value = true;
        
        // Update current video and add to history
        if (title != null && author != null) {
          final videoItem = VideoItem(
            id: videoId,
            title: title,
            author: author,
          );
          currentVideo.value = videoItem;
          _addToHistory(videoItem);
        }
        
        isLoading.value = false;
        return;
      }

      yt = YoutubeExplode();

      var video = await yt.videos.get(videoId);
      if (video.duration == null || video.duration == Duration.zero) {
        throw Exception('Video not playable');
      }

      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      final audioUrl = audioStreamInfo.url.toString();
      
      // Cache the URL
      await _storage.cacheUrl(videoId, audioUrl, {});

      await _player.open(Media(audioUrl));
      _player.play();
      isPlaying.value = true;
      
      // Enable wakelock for background playback
      if (backgroundPlaybackEnabled.value) {
        WakelockPlus.enable();
      }
      
      // Create video item and add to history
      final videoItem = VideoItem(
        id: video.id.toString(),
        title: video.title,
        author: video.author,
        duration: video.duration,
      );
      currentVideo.value = videoItem;
      _addToHistory(videoItem);
      
    } catch (e) {
      print('Error: $e');
      currentError.value = 'Error: ${e.toString()}';
      isPlaying.value = false;
    } finally {
      isLoading.value = false;
      yt?.close();
    }
  }

  void _addToHistory(VideoItem video) {
    try {
      final historyController = Get.find<HistoryController>();
      historyController.addToHistory(video);
    } catch (e) {
      print('History controller not found: $e');
    }
  }

  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) return;

    YoutubeExplode? yt;
    try {
      currentError.value = '';
      yt = YoutubeExplode();

      var results = await yt.search.getVideos(query);
      var filtered = results
          .where((video) =>
              video.duration != null &&
              video.duration!.inMinutes < 60 &&
              video.duration!.inSeconds > 30 &&
              !video.title.toLowerCase().contains('live'))
          .take(15)
          .toList();

      searchResults.value = filtered;

      if (filtered.isEmpty) {
        currentError.value = "No playable results found.";
      }
    } catch (e) {
      currentError.value = "Search failed: ${e.toString()}";
      searchResults.clear();
    } finally {
      yt?.close();
    }
  }

  void stopPlayback() {
    _player.stop();
    isPlaying.value = false;
    if (backgroundPlaybackEnabled.value) {
      WakelockPlus.disable();
    }
  }

  void clearError() {
    currentError.value = '';
  }

  @override
  void onClose() {
    _player.dispose();
    WakelockPlus.disable();
    super.onClose();
  }
}

