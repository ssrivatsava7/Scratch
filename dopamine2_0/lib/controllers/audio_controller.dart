import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;
  RxString currentError = ''.obs;
  RxList<Video> searchResults = <Video>[].obs;

  // Play or pause the audio
  void togglePlayback() {
    if (isPlaying.value) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    isPlaying.value = !isPlaying.value;
  }

  // Load YouTube audio URL with improved error handling and fallback strategies
  Future<void> loadAudio(String videoId) async {
    isLoading.value = true;
    currentError.value = '';

    var yt = YoutubeExplode();

    try {
      print("Input YouTube Video ID: $videoId");

      // Get video info with increased timeout
      var video = await yt.videos
          .get(videoId)
          .timeout(
            Duration(seconds: 20),
            onTimeout: () => throw Exception('Video fetch timeout'),
          );

      print("Video fetched: ${video.title}");

      // Check if video is available
      if (video.duration == null) {
        throw Exception(
          "This video appears to be unavailable (live stream or private)",
        );
      }

      // Try to get stream manifest with retry logic and different approaches
      StreamManifest? streamInfo;
      int retryCount = 0;
      const maxRetries = 2; // Reduced retries to avoid rate limiting

      while (retryCount < maxRetries && streamInfo == null) {
        try {
          print(
            "Attempting to get stream manifest (attempt ${retryCount + 1})...",
          );

          // Add a small delay between retries to avoid rate limiting
          if (retryCount > 0) {
            await Future.delayed(Duration(seconds: 3));
          }

          streamInfo = await yt.videos.streamsClient
              .getManifest(video.id)
              .timeout(
                Duration(seconds: 25),
                onTimeout: () => throw Exception('Stream manifest timeout'),
              );
        } catch (e) {
          retryCount++;
          print("Attempt $retryCount failed: $e");

          // If we get a 403, try with a fresh YoutubeExplode instance
          if (e.toString().contains('403') && retryCount < maxRetries) {
            print("Got 403 error, trying with fresh client...");
            yt.close();
            yt = YoutubeExplode();
          }

          if (retryCount >= maxRetries) {
            // Check if it's a 403 error and provide specific guidance
            if (e.toString().contains('403')) {
              throw Exception(
                "Access denied to this video. This may be due to regional restrictions, age restrictions, or copyright protection. Please try a different video.",
              );
            }
            throw e;
          }
        }
      }

      print("Stream manifest obtained successfully");

      if (streamInfo == null) {
        throw Exception("Failed to get stream manifest after retries");
      }

      // Try different audio stream options
      StreamInfo? audioStream;

      // First, try to get the highest bitrate audio-only stream
      if (streamInfo.audioOnly.isNotEmpty) {
        audioStream = streamInfo.audioOnly.withHighestBitrate();
        print("Using audio-only stream");
      }

      // If no audio-only stream, try muxed streams
      if (audioStream == null && streamInfo.muxed.isNotEmpty) {
        // Get muxed stream with highest bitrate
        var muxedStreams = streamInfo.muxed
            .where((stream) => stream.audioCodec.isNotEmpty)
            .toList();
        if (muxedStreams.isNotEmpty) {
          audioStream = muxedStreams.reduce(
            (a, b) => a.bitrate.bitsPerSecond > b.bitrate.bitsPerSecond ? a : b,
          );
          print("Using muxed stream");
        }
      }

      // If still no stream, try any available audio stream
      if (audioStream == null && streamInfo.audio.isNotEmpty) {
        audioStream = streamInfo.audio.withHighestBitrate();
        print("Using general audio stream");
      }

      if (audioStream == null) {
        throw Exception("No accessible audio stream found for this video");
      }

      print("Audio stream URL: ${audioStream.url}");
      print("Audio stream bitrate: ${audioStream.bitrate}");

      // Stop current playback before loading new audio
      await _audioPlayer.stop();

      // Use Just Audio to stream audio with error handling
      await _audioPlayer
          .setUrl(
            audioStream.url.toString(),
            preload: true, // Changed to true for better reliability
          )
          .timeout(
            Duration(seconds: 30), // Increased timeout
            onTimeout: () => throw Exception('Audio loading timeout'),
          );

      // Start playing
      await _audioPlayer.play();
      isPlaying.value = true;

      print("Audio loaded and playing successfully");
    } catch (e) {
      print("Error downloading or playing audio: $e");
      currentError.value = e.toString();

      if (e.toString().contains("FatalFailureException") ||
          e.toString().contains("signature decipherer")) {
        currentError.value =
            "YouTube signature error. Please try a different video.";
        print("Signature deciphering failure. Could not fetch audio.");
      } else if (e.toString().contains("403")) {
        currentError.value =
            "Access denied to this video. Try a different song - this one may be region-locked or protected.";
      } else if (e.toString().contains("timeout")) {
        currentError.value =
            "Connection timeout. Please check your internet connection.";
      } else if (e.toString().contains("No accessible audio stream")) {
        currentError.value =
            "This video doesn't have accessible audio streams.";
      } else {
        currentError.value = "Failed to load audio. Please try again.";
      }

      // Reset playing state
      isPlaying.value = false;
    } finally {
      isLoading.value = false;
      yt.close(); // Always close the YoutubeExplode instance
    }
  }

  // Search for a video by song name with better filtering
  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) return;

    var yt = YoutubeExplode();

    try {
      currentError.value = '';

      var videos = await yt.search
          .getVideos(query)
          .timeout(
            Duration(minutes: 3),
            onTimeout: () => throw Exception('Search timeout'),
          );

      // Filter out videos that are likely to have issues
      var filteredVideos = videos
          .where((video) {
            var title = video.title.toLowerCase();
            var author = video.author.toLowerCase();

            return video.duration != null &&
                video.duration!.inMinutes < 60 && // Skip very long videos
                video.duration!.inSeconds > 30 && // Skip very short videos
                !title.contains('live') &&
                !title.contains('stream') &&
                !title.contains('remix') && // Remixes often have restrictions
                !title.contains('cover') && // Covers sometimes have issues
                !author.contains('vevo') && // VEVO videos often restricted
                !author.contains('records'); // Record labels often restricted
          })
          .take(12)
          .toList(); // Reduced to 12 results

      searchResults.value = filteredVideos;
      print(
        "Search results: ${filteredVideos.length} videos found (filtered from ${videos.length}).",
      );

      if (filteredVideos.isEmpty && videos.isNotEmpty) {
        currentError.value =
            "Found videos but they may have playback restrictions. Try a different search term.";
      }
    } catch (e) {
      print("Search error: $e");
      currentError.value = "Search failed. Please try again.";
      searchResults.clear();
    } finally {
      yt.close();
    }
  }

  // Stop playback
  void stopPlayback() {
    _audioPlayer.stop();
    isPlaying.value = false;
  }

  // Clear current error
  void clearError() {
    currentError.value = '';
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
