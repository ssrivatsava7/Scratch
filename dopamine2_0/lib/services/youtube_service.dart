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

  // Get video stream URLs with quality selection (supports up to 4K)
  static Future<Map<String, String?>> getStreamUrls(String videoId, {String videoQuality = '720p'}) async {
    try {
      print('🎬 Fetching streams for $videoId at quality: $videoQuality');
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Debug: Print all available streams
      print('📊 Available video-only streams:');
      for (final stream in manifest.videoOnly) {
        print('   - ${stream.videoResolution.height}p @ ${stream.bitrate.kiloBitsPerSecond} kbps (${stream.videoCodec})');
      }
      print('📊 Available muxed streams:');
      for (final stream in manifest.muxed) {
        print('   - ${stream.videoResolution.height}p @ ${stream.bitrate.kiloBitsPerSecond} kbps');
      }

      // Get best audio stream
      String? audioUrl;
      if (manifest.audioOnly.isNotEmpty) {
        final bestAudio = manifest.audioOnly.withHighestBitrate();
        audioUrl = bestAudio.url.toString();
        print('🎵 Audio: ${bestAudio.bitrate.kiloBitsPerSecond} kbps, codec: ${bestAudio.audioCodec}');
      }

      // Get video stream based on requested quality
      String? videoUrl;
      final requestedHeight = int.tryParse(videoQuality.replaceAll('p', '')) ?? 720;
      
      print('🎯 Requested quality height: ${requestedHeight}p');
      
      // For high quality (1080p and above), prefer video-only streams as they have better quality
      if (requestedHeight >= 1080 && manifest.videoOnly.isNotEmpty) {
        VideoOnlyStreamInfo? selectedStream;
        int closestDiff = 999999;
        int highestBitrate = 0;
        
        // First, find streams that match or are close to requested height
        for (final stream in manifest.videoOnly) {
          final height = stream.videoResolution.height;
          final diff = (height - requestedHeight).abs();
          final bitrate = stream.bitrate.kiloBitsPerSecond.toInt();
          
          // Prefer exact match with highest bitrate, or closest match with highest bitrate
          if (diff < closestDiff || (diff == closestDiff && bitrate > highestBitrate)) {
            closestDiff = diff;
            highestBitrate = bitrate;
            selectedStream = stream;
          }
        }
        
        if (selectedStream != null) {
          videoUrl = selectedStream.url.toString();
          print('✅ Selected high-quality video-only: ${selectedStream.videoResolution.height}p @ ${selectedStream.bitrate.kiloBitsPerSecond} kbps');
          print('   Codec: ${selectedStream.videoCodec}');
          print('   Size: ${selectedStream.size.totalMegaBytes.toStringAsFixed(2)} MB');
          print('   Container: ${selectedStream.container}');
        }
      }
      
      // Try muxed streams for lower qualities (better for playback, has audio+video)
      if (videoUrl == null && manifest.muxed.isNotEmpty) {
        MuxedStreamInfo? selectedStream;
        int closestDiff = 999999;
        
        for (final stream in manifest.muxed) {
          final height = stream.videoResolution.height;
          final diff = (height - requestedHeight).abs();
          if (diff < closestDiff) {
            closestDiff = diff;
            selectedStream = stream;
          }
        }
        
        if (selectedStream != null) {
          videoUrl = selectedStream.url.toString();
          print('📹 Muxed video: ${selectedStream.videoResolution.height}p, ${selectedStream.bitrate.kiloBitsPerSecond} kbps');
        }
      }
      
      // Fallback to video-only streams if no muxed available
      if (videoUrl == null && manifest.videoOnly.isNotEmpty) {
        VideoOnlyStreamInfo? selectedStream;
        int closestDiff = 999999;
        
        for (final stream in manifest.videoOnly) {
          final height = stream.videoResolution.height;
          final diff = (height - requestedHeight).abs();
          if (diff < closestDiff) {
            closestDiff = diff;
            selectedStream = stream;
          }
        }
        
        if (selectedStream != null) {
          videoUrl = selectedStream.url.toString();
          print('📹 Video-only: ${selectedStream.videoResolution.height}p, ${selectedStream.bitrate.kiloBitsPerSecond} kbps');
        }
      }

      // Final fallback
      if (audioUrl == null && manifest.muxed.isNotEmpty) {
        audioUrl = manifest.muxed.withHighestBitrate().url.toString();
      }
      if (videoUrl == null && manifest.muxed.isNotEmpty) {
        videoUrl = manifest.muxed.withHighestBitrate().url.toString();
      }

      print('✅ Stream URLs obtained - Audio: ${audioUrl != null}, Video: ${videoUrl != null}');
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

  // Get available video qualities (supports up to 4K)
  static Future<List<String>> getAvailableQualities(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final qualities = <String>{};
      
      // Get qualities from muxed streams (usually up to 720p)
      for (final stream in manifest.muxed) {
        qualities.add('${stream.videoResolution.height}p');
      }
      
      // Get qualities from video-only streams (includes 1080p, 1440p, 2160p/4K, etc.)
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
      return sortedQualities;
    } catch (e) {
      print('❌ Error getting qualities: $e');
      return ['1080p', '720p', '480p', '360p']; // Updated default fallback
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
