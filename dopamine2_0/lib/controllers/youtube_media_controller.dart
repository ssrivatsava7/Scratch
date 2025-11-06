import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../services/storage_service.dart';

class YouTubeMediaController extends GetxController {
  YoutubeExplode? _yt;
  final StorageService _storage = StorageService();
  final RxString selectedQuality = '720p'.obs;
  
  YoutubeExplode get yt {
    _yt?.close();
    _yt = YoutubeExplode();
    return _yt!;
  }

  @override
  void onInit() {
    super.onInit();
    _storage.init().then((_) {
      _loadQualityPreference();
    });
  }

  Future<void> _loadQualityPreference() async {
    selectedQuality.value = await _storage.getQualityPreference();
  }

  Future<void> setQualityPreference(String quality) async {
    selectedQuality.value = quality;
    await _storage.setQualityPreference(quality);
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

  int _getMaxQualityHeight(String quality) {
    switch (quality) {
      case '360p':
        return 360;
      case '480p':
        return 480;
      case '720p':
        return 720;
      case '1080p':
        return 1080;
      default:
        return 720;
    }
  }

  Future<Map<String, dynamic>> getVideoDetails(String videoId, {String? preferredQuality}) async {
    int retryCount = 0;
    const maxRetries = 3;
    dynamic lastError;
    
    final quality = preferredQuality ?? selectedQuality.value;
    final maxHeight = _getMaxQualityHeight(quality);

    // Check cache first
    final cachedData = await _storage.getCachedUrl(videoId);
    if (cachedData != null) {
      return {
        'url': cachedData['url'],
        'title': 'Cached Video',
        'author': '',
        'duration': Duration.zero,
        'bitrate': 0,
        'headers': cachedData['headers'] ?? {},
        'fromCache': true,
      };
    }

    while (retryCount < maxRetries) {
      try {
        // Create new instance for each attempt
        final yt = YoutubeExplode();
        
        // Try to get video info first
        final video = await yt.videos.get(videoId);
        
        // Get all available streams
        final manifest = await yt.videos.streamsClient.getManifest(videoId);
        
        // Get streams matching quality preference
        var allStreams = [
          ...manifest.muxed,
          ...manifest.videoOnly,
        ].where((s) => 
          s.container.name == 'mp4' && 
          s.size.totalBytes < 150000000 // 150MB max
        ).toList();

        // Filter by quality preference
        allStreams = allStreams.where((s) {
          if (s is VideoStreamInfo) {
            return s.videoResolution.height <= maxHeight;
          }
          return true;
        }).toList();

        // Sort by quality and bitrate
        allStreams.sort((a, b) {
          if (a is MuxedStreamInfo && b is MuxedStreamInfo) {
            return b.videoQuality.index.compareTo(a.videoQuality.index);
          }
          return b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond);
        });

        if (allStreams.isEmpty) {
          throw Exception('No streams available for selected quality');
        }

        // Try different stream qualities if available
        var selectedStream = allStreams.firstWhere(
          (s) => s is MuxedStreamInfo,
          orElse: () => allStreams.first,
        );

        print('Selected stream info:');
        print('- Type: ${selectedStream.runtimeType}');
        print('- Container: ${selectedStream.container.name}');
        print('- Size: ${selectedStream.size.totalMegaBytes.toStringAsFixed(2)}MB');
        print('- Bitrate: ${selectedStream.bitrate.kiloBitsPerSecond}kbps');

        final headers = {
          'Referer': 'https://www.youtube.com',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36',
          'Range': 'bytes=0-',
        };

        final result = {
          'url': selectedStream.url.toString(),
          'title': video.title,
          'author': video.author,
          'duration': video.duration,
          'bitrate': selectedStream.bitrate.bitsPerSecond,
          'headers': headers,
          'fromCache': false,
        };

        // Cache the URL
        await _storage.cacheUrl(videoId, result['url'] as String, headers);

        return result;
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

  Future<List<String>> getAvailableQualities(String videoId) async {
    try {
      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      
      final qualities = <String>{};
      
      for (var stream in manifest.muxed) {
        if (stream is MuxedStreamInfo) {
          final height = stream.videoResolution.height;
          if (height <= 360) qualities.add('360p');
          else if (height <= 480) qualities.add('480p');
          else if (height <= 720) qualities.add('720p');
          else if (height <= 1080) qualities.add('1080p');
        }
      }
      
      yt.close();
      
      final sortedQualities = qualities.toList()
        ..sort((a, b) => _getMaxQualityHeight(a).compareTo(_getMaxQualityHeight(b)));
      
      return sortedQualities;
    } catch (e) {
      print('Error getting available qualities: $e');
      return ['360p', '480p', '720p'];
    }
  }
}

