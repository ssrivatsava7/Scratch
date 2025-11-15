import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeService {
  static final yt = YoutubeExplode();

  static Future<(String audioUrl, String videoUrl)> extractStreams(
      String videoIdOrUrl) async {
    final video = await yt.videos.get(videoIdOrUrl);

    final manifest = await yt.videos.streamsClient.getManifest(video.id);

    final audioStream = manifest.audioOnly.withHighestBitrate();
    final videoStream = manifest.muxed.withHighestBitrate();

    return (audioStream.url.toString(), videoStream.url.toString());
  }
}
