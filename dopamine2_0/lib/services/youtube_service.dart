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

  // Get video stream URL
  static Future<Map<String, String?>> getStreamUrls(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      final audioUrl = manifest.audioOnly.withHighestBitrate().url.toString();
      final videoUrl = manifest.muxed.withHighestBitrate().url.toString();

      return {
        'audioUrl': audioUrl,
        'videoUrl': videoUrl,
      };
    } catch (e) {
      print('Stream URL error: $e');
      return {
        'audioUrl': null,
        'videoUrl': null,
      };
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
