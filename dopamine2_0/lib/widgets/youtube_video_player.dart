import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt;

/// YouTube Video Player Widget using youtube_player_iframe
/// Supports up to 4K quality with reliable playback
class YouTubeVideoPlayer extends StatefulWidget {
  final String videoId;
  final VoidCallback? onReady;
  final Function(Duration position)? onPositionChanged;
  final VoidCallback? onEnded;

  const YouTubeVideoPlayer({
    Key? key,
    required this.videoId,
    this.onReady,
    this.onPositionChanged,
    this.onEnded,
  }) : super(key: key);

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late yt.YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    print('🎬 Initializing YouTube player for video: ${widget.videoId}');
    
    _controller = yt.YoutubePlayerController(
      params: const yt.YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
        enableCaption: false,
        strictRelatedVideos: true,
      ),
    );

    // Load the video
    _controller.loadVideoById(videoId: widget.videoId);

    // Listen to player state changes
    _controller.listen((event) {
      if (event.playerState == yt.PlayerState.playing && !_isPlayerReady) {
        _isPlayerReady = true;
        widget.onReady?.call();
        print('✅ YouTube player ready and playing');
      }

      if (event.playerState == yt.PlayerState.ended) {
        widget.onEnded?.call();
        print('⏹️ YouTube video ended');
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return yt.YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }

  // Expose controller methods
  yt.YoutubePlayerController get controller => _controller;
}

/// YouTube Video Player Controller Extension
/// Provides easy access to player controls
extension YouTubePlayerControllerExt on yt.YoutubePlayerController {
  /// Play the video
  Future<void> playYouTubeVideo() async {
    await playVideo();
    print('▶️ YouTube player: Play');
  }

  /// Pause the video
  Future<void> pauseYouTubeVideo() async {
    await pauseVideo();
    print('⏸️ YouTube player: Pause');
  }

  /// Seek to a specific position
  Future<void> seekToYouTubePosition(Duration position) async {
    await seekTo(seconds: position.inSeconds.toDouble());
    print('⏩ YouTube player: Seek to ${position.inSeconds}s');
  }

  /// Stop the video
  Future<void> stopYouTubeVideo() async {
    await stopVideo();
    print('⏹️ YouTube player: Stop');
  }

  /// Get current position
  Future<Duration> getCurrentYouTubePosition() async {
    final seconds = await currentTime;
    return Duration(seconds: seconds.toInt());
  }

  /// Get duration
  Future<Duration> getYouTubeVideoDuration() async {
    final seconds = await duration;
    return Duration(seconds: seconds.toInt());
  }

  /// Check if playing
  Future<bool> isYouTubePlaying() async {
    final state = await playerState;
    return state == yt.PlayerState.playing;
  }
}
