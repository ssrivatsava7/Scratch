import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioController extends GetxController {
  late final Player _player;
  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;
  RxString currentError = ''.obs;
  RxList<Video> searchResults = <Video>[].obs;

  @override
  void onInit() {
    _player = Player();
    super.onInit();
  }

  void togglePlayback() {
    if (isPlaying.value) {
      _player.pause();
    } else {
      _player.play();
    }
    isPlaying.value = !isPlaying.value;
  }

  Future<void> loadAudio(String videoId) async {
    isLoading.value = true;
    currentError.value = '';
    YoutubeExplode? yt;

    try {
      yt = YoutubeExplode();

      var video = await yt.videos.get(videoId);
      if (video == null || video.duration == null || video.duration == Duration.zero) {
        throw Exception('Video not playable');
      }

      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      if (audioStreamInfo == null) {
        throw Exception('No audio stream found. Video might be age-restricted or unavailable.');
      }

      await _player.open(Media(audioStreamInfo.url.toString()));
      _player.play();
      isPlaying.value = true;
    } catch (e) {
      print('Error: $e');
      currentError.value = 'Error: ${e.toString()}';
      isPlaying.value = false;
    } finally {
      isLoading.value = false;
      yt?.close();
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
  }

  void clearError() {
    currentError.value = '';
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
