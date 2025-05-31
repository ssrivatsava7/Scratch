import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../controllers/youtube_media_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
    required this.videoTitle,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final player = Player(
    configuration: const PlayerConfiguration(
      bufferSize: 1024 * 1024, // 1MB buffer for faster start
      title: 'Dopamine Video Player',
    ),
  );
  late final controller = VideoController(player);
  final ytController = Get.put(YouTubeMediaController());
  bool isInitialized = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final videoDetails = await ytController.getVideoDetails(widget.videoId);

        // Configure player for the specific stream
        await player.setPlaylistMode(PlaylistMode.single);
        await player.open(
          Media(
            videoDetails['url'],
            httpHeaders: {
              'Referer': 'https://www.youtube.com',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          ),
        );

        setState(() => isInitialized = true);
        break;
      } catch (e) {
        print('Attempt ${retryCount + 1} failed: $e');
        retryCount++;

        if (retryCount == maxRetries) {
          setState(() => errorMessage = e.toString());
          Get.snackbar(
            'Error',
            'Failed to load video after $maxRetries attempts',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoTitle),
        actions: [
          IconButton(
            icon: StreamBuilder(
              stream: player.stream.playing,
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                return Icon(playing ? Icons.pause : Icons.play_arrow);
              },
            ),
            onPressed: () => player.playOrPause(),
          ),
        ],
      ),
      body: Center(
        child: isInitialized
            ? Video(
                controller: controller,
                controls: AdaptiveVideoControls, // Native controls
              )
            : errorMessage != null
                ? Text('Error: $errorMessage')
                : CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
