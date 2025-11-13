import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeMediaController extends GetxController {
  final YoutubeExplode yt = YoutubeExplode();

  final RxList<Video> searchResults = <Video>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    yt.close();
    super.onClose();
  }

  Future<void> searchVideos(String query) async {
    try {
      isLoading.value = true;
      searchResults.clear();

      final results = await yt.search(query);
      searchResults.addAll(results);
    } catch (e) {
      print("Search error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getBestVideoUrl(String videoId) async {
    try {
      isLoading.value = true;
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final stream = manifest.muxed.withHighestBitrate();
      return stream.url.toString();
    } catch (e) {
      print("Video URL error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getBestAudioUrl(String videoId) async {
    try {
      isLoading.value = true;
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final stream = manifest.audioOnly.withHighestBitrate();
      return stream.url.toString();
    } catch (e) {
      print("Audio URL error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
