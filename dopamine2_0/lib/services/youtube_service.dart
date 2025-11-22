import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeService {
  static final _yt = YoutubeExplode();

  // Search for videos
  static Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final searchList = await _yt.search.search(query);

      return searchList.take(20).map((video) {
        return {
          'id': video.id.value,
          'title': video.title,
          'thumbnail': video.thumbnails.highResUrl,
          'author': video.author,
          'duration': video.duration?.inSeconds ?? 0,
          'videoUrl': 'https://youtube.com/watch?v=${video.id.value}',
        };
      }).toList();
    } catch (e) {
      print('YouTube search error: $e');
      return [];
    }
  }

  // Get video stream URLs with quality selection (WORKAROUND: Muxed streams only for reliability)
  // Note: This is a temporary workaround for MediaKit playback issues with YouTube URLs.
  // Muxed streams (max 720p) work reliably, while video-only streams (1080p+) fail.
  // TODO: Integrate a dedicated YouTube player (flutter_inappwebview, youtube_player_flutter, etc.) for 1080p+ support.
  static Future<Map<String, String?>> getStreamUrls(String videoId, {String videoQuality = '720p'}) async {
    try {
      print('🎬 Fetching streams for $videoId at quality: $videoQuality');
      print('⚠️  WORKAROUND ACTIVE: Using muxed streams only (max 720p) for reliable playback');
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Debug: Print all available streams
      print('📊 Available muxed streams (reliable):');
      for (final stream in manifest.muxed) {
        print('   - ${stream.videoResolution.height}p @ ${stream.bitrate.kiloBitsPerSecond} kbps');
      }
      print('📊 Available video-only streams (unreliable with MediaKit):');
      for (final stream in manifest.videoOnly) {
        print('   - ${stream.videoResolution.height}p @ ${stream.bitrate.kiloBitsPerSecond} kbps (${stream.videoCodec})');
      }

      // WORKAROUND: Always use muxed streams for reliable playback
      // Muxed streams contain both audio and video, max 720p, and work reliably with MediaKit
      String? videoUrl;
      String? audioUrl;
      
      final requestedHeight = int.tryParse(videoQuality.replaceAll('p', '').replaceAll(' (4K)', '').replaceAll(' (2K)', '')) ?? 720;
      
      // Cap requested quality at 720p (max available in muxed streams)
      final cappedHeight = requestedHeight > 720 ? 720 : requestedHeight;
      if (requestedHeight > 720) {
        print('⚠️  Quality capped at 720p (requested: ${requestedHeight}p) - muxed streams only');
      }
      
      print('🎯 Target quality: ${cappedHeight}p');
      
      // Select best muxed stream for requested quality
      if (manifest.muxed.isNotEmpty) {
        MuxedStreamInfo? selectedStream;
        int closestDiff = 999999;
        int highestBitrate = 0;
        
        for (final stream in manifest.muxed) {
          final height = stream.videoResolution.height;
          final diff = (height - cappedHeight).abs();
          final bitrate = stream.bitrate.kiloBitsPerSecond.toInt();
          
          // Prefer closest match with highest bitrate
          if (diff < closestDiff || (diff == closestDiff && bitrate > highestBitrate)) {
            closestDiff = diff;
            highestBitrate = bitrate;
            selectedStream = stream;
          }
        }
        
        if (selectedStream != null) {
          videoUrl = selectedStream.url.toString();
          audioUrl = videoUrl; // Muxed streams contain both audio and video
          print('✅ Selected muxed stream: ${selectedStream.videoResolution.height}p @ ${selectedStream.bitrate.kiloBitsPerSecond} kbps');
          print('   Container: ${selectedStream.container}');
          print('   Size: ${selectedStream.size.totalMegaBytes.toStringAsFixed(2)} MB');
          print('   ✅ Reliable playback expected (muxed stream with audio+video)');
        }
      }

      // Final fallback: get highest quality muxed stream
      if (videoUrl == null && manifest.muxed.isNotEmpty) {
        final bestMuxed = manifest.muxed.withHighestBitrate();
        videoUrl = bestMuxed.url.toString();
        audioUrl = videoUrl;
        print('⚠️  Fallback: Using highest quality muxed stream (${bestMuxed.videoResolution.height}p)');
      }

      print('✅ Stream URLs obtained - Audio: ${audioUrl != null}, Video: ${videoUrl != null}');
      if (videoUrl != null) {
        print('ℹ️  Using muxed stream (audio+video combined) for reliable playback');
      }
      
      return {
        'audioUrl': audioUrl,
        'videoUrl': videoUrl,
      };
    } catch (e) {
      print('❌ Stream URL error: $e');
      return {
        'audioUrl': null,
        'videoUrl': null,
      };
    }
  }

  // Get available video qualities (supports up to 4K with YouTube player)
  // Note: Muxed streams max out at 720p, but video-only streams go up to 4K
  // The app will automatically use YouTube iframe player for 1080p+ and MediaKit for 720p and below
  static Future<List<String>> getAvailableQualities(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final qualities = <String>{};
      
      // Get qualities from muxed streams (up to 720p)
      for (final stream in manifest.muxed) {
        qualities.add('${stream.videoResolution.height}p');
      }
      
      // Get qualities from video-only streams (includes 1080p, 1440p, 2160p/4K, etc.)
      // These will use YouTube iframe player for reliable playback
      for (final stream in manifest.videoOnly) {
        final height = stream.videoResolution.height;
        // Add quality label with special naming for 4K
        if (height >= 2160) {
          qualities.add('2160p (4K)');
        } else if (height >= 1440) {
          qualities.add('1440p (2K)');
        } else {
          qualities.add('${height}p');
        }
      }
      
      // Sort by height (descending order - highest quality first)
      final sortedQualities = qualities.toList();
      sortedQualities.sort((a, b) {
        final aHeight = int.tryParse(a.replaceAll('p', '').replaceAll(' (4K)', '').replaceAll(' (2K)', '')) ?? 0;
        final bHeight = int.tryParse(b.replaceAll('p', '').replaceAll(' (4K)', '').replaceAll(' (2K)', '')) ?? 0;
        return bHeight.compareTo(aHeight); // Descending order
      });
      
      print('📊 Available qualities: $sortedQualities');
      print('ℹ️  1080p+ will use YouTube iframe player, 720p and below will use muxed streams');
      
      return sortedQualities;
    } catch (e) {
      print('❌ Error getting qualities: $e');
      return ['1080p', '720p', '480p', '360p']; // Default fallback with 1080p
    }
  }

  // Get video details
  static Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);

      return {
        'id': video.id.value,
        'title': video.title,
        'thumbnail': video.thumbnails.highResUrl,
        'author': video.author,
        'duration': video.duration?.inSeconds ?? 0,
        'description': video.description,
        'videoUrl': 'https://youtube.com/watch?v=${video.id.value}',
      };
    } catch (e) {
      print('Video details error: $e');
      return null;
    }
  }

  // Get related videos
  static Future<List<Map<String, dynamic>>> getRelated(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final related = await _yt.videos.getRelatedVideos(video);

      if (related == null) return [];

      return related.take(10).map((video) {
        return {
          'id': video.id.value,
          'title': video.title,
          'thumbnail': video.thumbnails.highResUrl,
          'author': video.author,
          'duration': video.duration?.inSeconds ?? 0,
          'videoUrl': 'https://youtube.com/watch?v=${video.id.value}',
        };
      }).toList();
    } catch (e) {
      print('Related videos error: $e');
      return [];
    }
  }

  // Get audio stream URL for downloading
  static  Future<String?> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      
      // Get the best audio-only stream
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isEmpty) {
        return null;
      }
      
      // Sort by bitrate and get the best one
      audioStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      final bestAudio = audioStreams.first;
      
      return bestAudio.url.toString();
    } catch (e) {
      print('Error getting audio stream URL: $e');
      return null;
    }
  }

  // Close the client
  static void close() {
    _yt.close();
  }
}
