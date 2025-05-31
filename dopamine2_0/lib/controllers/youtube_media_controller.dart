import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeMediaController extends GetxController {
  YoutubeExplode? _yt;
  
  YoutubeExplode get yt {
    _yt?.close();
    _yt = YoutubeExplode();
    return _yt!;
  }

  @override
  void onClose() {
    _yt?.close();
    super.onClose();
  }

  Future<List<Video>> searchVideos(String query) async {
    var searchResults = await yt.search.getVideos(query);
    return searchResults.take(20).toList();
  }

  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    int retryCount = 0;
    const maxRetries = 3;
    dynamic lastError;

    while (retryCount < maxRetries) {
      try {
        // Create new instance for each attempt
        final yt = YoutubeExplode();
        
        // Try to get video info first
        final video = await yt.videos.get(videoId);
        
        // Get all available streams
        final manifest = await yt.videos.streamsClient.getManifest(videoId);
        
        // First try: Get all MP4 streams
        var allStreams = [
          ...manifest.muxed,
          ...manifest.videoOnly,
        ].where((s) => 
          s.container.name == 'mp4' && 
          s.size.totalBytes < 150000000 // 150MB max
        ).toList();

        // Sort by quality and bitrate
        allStreams.sort((a, b) {
          if (a is MuxedStreamInfo && b is MuxedStreamInfo) {
            return b.videoQuality.index.compareTo(a.videoQuality.index);
          }
          return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
        });

        // Try different stream qualities if available
        var selectedStream = allStreams.firstWhere(
          (s) => s is MuxedStreamInfo && s.videoQuality.index <= 720,
          orElse: () => allStreams.first,
        );

        print('Selected stream info:');
        print('- Type: ${selectedStream.runtimeType}');
        print('- Container: ${selectedStream.container.name}');
        print('- Size: ${selectedStream.size.totalMegaBytes.toStringAsFixed(2)}MB');
        print('- Bitrate: ${selectedStream.bitrate.kiloBitsPerSecond}kbps');

        return {
          'url': selectedStream.url.toString(),
          'title': video.title,
          'author': video.author,
          'duration': video.duration,
          'bitrate': selectedStream.bitrate.bitsPerSecond,
          'headers': {
            'Referer': 'https://www.youtube.com',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36',
            'Range': 'bytes=0-',
          },
        };
      } catch (e) {
        lastError = e;
        retryCount++;
        
        print('Attempt $retryCount failed: $e');
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(seconds: 1 * retryCount));
          continue;
        }
        
        if (e.toString().contains('403')) {
          throw Exception('This video requires age verification. Try a different video.');
        }
        throw Exception('Failed to get video after $maxRetries attempts: ${e.toString()}');
      }
    }
    
    throw lastError ?? Exception('Unknown error occurred');
  }
}
