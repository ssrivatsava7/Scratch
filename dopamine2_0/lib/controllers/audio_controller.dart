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

    YoutubeExplode? yt;

    try {
      print("Input YouTube Video ID: $videoId");

      // Create YoutubeExplode instance with custom HttpClient
      yt = YoutubeExplode();

      // Get video info with increased timeout
      Video? video;
      try {
        video = await yt.videos
            .get(videoId)
            .timeout(
              Duration(seconds: 20),
              onTimeout: () => throw Exception('Video fetch timeout'),
            );
      } catch (e) {
        throw Exception('Failed to fetch video info: ${e.toString()}');
      }

      if (video == null) {
        throw Exception('Video not found or unavailable');
      }

      print("Video fetched: ${video.title}");

      // Check if video is available and has duration
      if (video.duration == null || video.duration == Duration.zero) {
        throw Exception(
          "This video appears to be unavailable (live stream, private, or no audio)",
        );
      }

      // Try to get stream manifest with enhanced retry logic
      StreamManifest? streamInfo;
      int retryCount = 0;
      const maxRetries = 3;
      Exception? lastException;

      while (retryCount < maxRetries && streamInfo == null) {
        try {
          print(
            "Attempting to get stream manifest (attempt ${retryCount + 1})...",
          );

          // Add progressive delay between retries
          if (retryCount > 0) {
            await Future.delayed(Duration(seconds: 2 + retryCount));

            // Create fresh client for retry
            yt?.close();
            yt = YoutubeExplode();
          }

          // Try different approaches for getting manifest
          if (retryCount == 0) {
            // First attempt: normal approach
            streamInfo = await yt!.videos.streamsClient
                .getManifest(video!.id)
                .timeout(
                  Duration(minutes: 3),
                  onTimeout: () => throw Exception('Stream manifest timeout'),
                );
          } else {
            // Subsequent attempts: try with fresh video object
            var freshVideo = await yt!.videos.get(videoId);
            if (freshVideo != null) {
              video = freshVideo;
              streamInfo = await yt.videos.streamsClient
                  .getManifest(video.id)
                  .timeout(
                    Duration(minutes: 3),
                    onTimeout: () => throw Exception('Stream manifest timeout'),
                  );
            }
          }

          if (streamInfo != null) {
            print(
              "Stream manifest obtained successfully on attempt ${retryCount + 1}",
            );
            break;
          }
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          retryCount++;
          print("Attempt $retryCount failed: $e");

          // Handle specific error types
          if (e.toString().contains('FatalFailureException') ||
              e.toString().contains('signature decipherer')) {
            print("Signature deciphering failure detected");
            if (retryCount >= maxRetries) {
              throw Exception(
                "YouTube signature protection detected. This video cannot be played due to YouTube's anti-bot measures. Please try a different video.",
              );
            }
          } else if (e.toString().contains('403')) {
            if (retryCount >= maxRetries) {
              throw Exception(
                "Access denied. This video may be region-locked, age-restricted, or copyright protected.",
              );
            }
          } else if (e.toString().contains(
            'Null check operator used on a null value',
          )) {
            print("Null check error detected - video may be unavailable");
            if (retryCount >= maxRetries) {
              throw Exception(
                "Video data unavailable. This video may be private, deleted, or restricted.",
              );
            }
          }
        }
      }

      if (streamInfo == null) {
        throw lastException ??
            Exception(
              "Failed to get stream manifest after $maxRetries attempts",
            );
      }

      // Enhanced audio stream selection with null safety
      StreamInfo? audioStream;

      try {
        // First priority: Audio-only streams
        var audioOnlyStreams = streamInfo.audioOnly;
        if (audioOnlyStreams.isNotEmpty) {
          // Filter streams and sort by bitrate
          var validAudioStreams = audioOnlyStreams
              .where((stream) => stream.url != null && stream.bitrate != null)
              .toList();

          if (validAudioStreams.isNotEmpty) {
            validAudioStreams.sort(
              (a, b) =>
                  b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
            );
            audioStream = validAudioStreams.first;
            print(
              "Using audio-only stream with bitrate: ${audioStream.bitrate}",
            );
          }
        }

        // Second priority: Muxed streams with audio
        if (audioStream == null) {
          var muxedStreams = streamInfo.muxed
              .where((stream) => stream.url != null && stream.bitrate != null)
              .toList();

          if (muxedStreams.isNotEmpty) {
            muxedStreams.sort(
              (a, b) =>
                  b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
            );
            audioStream = muxedStreams.first;
            print("Using muxed stream with bitrate: ${audioStream.bitrate}");
          }
        }

        // Third priority: Any audio stream
        if (audioStream == null) {
          var allAudioStreams = streamInfo.audio
              .where((stream) => stream.url != null && stream.bitrate != null)
              .toList();

          if (allAudioStreams.isNotEmpty) {
            allAudioStreams.sort(
              (a, b) =>
                  b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
            );
            audioStream = allAudioStreams.first;
            print(
              "Using general audio stream with bitrate: ${audioStream.bitrate}",
            );
          }
        }

        if (audioStream == null) {
          throw Exception("No accessible audio streams found for this video");
        }

        // Validate stream URL
        if (audioStream.url.toString().isEmpty) {
          throw Exception("Invalid audio stream URL");
        }

        print("Selected audio stream:");
        print("- URL: ${audioStream.url}");
        print("- Bitrate: ${audioStream.bitrate}");
        // Note: audioCodec property may not be available in all stream types
      } catch (e) {
        throw Exception("Error selecting audio stream: ${e.toString()}");
      }

      // Stop current playback before loading new audio
      try {
        await _audioPlayer.stop();
      } catch (e) {
        print("Warning: Error stopping previous audio: $e");
      }

      // Load and play audio with enhanced error handling
      try {
        await _audioPlayer
            .setUrl(audioStream.url.toString(), preload: true)
            .timeout(
              Duration(seconds: 45),
              onTimeout: () => throw Exception(
                'Audio loading timeout - stream may be too slow',
              ),
            );

        // Start playing
        await _audioPlayer.play();
        isPlaying.value = true;

        print("Audio loaded and playing successfully");
      } catch (e) {
        throw Exception("Failed to load audio stream: ${e.toString()}");
      }
    } catch (e) {
      print("Error downloading or playing audio: $e");

      // Enhanced error categorization
      String errorMessage;
      if (e.toString().contains("FatalFailureException") ||
          e.toString().contains("signature decipherer")) {
        errorMessage =
            "⚠️ YouTube protection detected. This video cannot be played due to anti-bot measures. Try a different video.";
        print("Signature deciphering failure. Could not fetch audio.");
      } else if (e.toString().contains(
        "Null check operator used on a null value",
      )) {
        errorMessage =
            "❌ Video data unavailable. This video may be private, deleted, or restricted.";
      } else if (e.toString().contains("403")) {
        errorMessage =
            "🚫 Access denied. This video may be region-locked, age-restricted, or copyright protected.";
      } else if (e.toString().contains("timeout")) {
        errorMessage =
            "⏱️ Connection timeout. Please check your internet connection and try again.";
      } else if (e.toString().contains("No accessible audio stream")) {
        errorMessage = "🔇 No audio streams available for this video.";
      } else if (e.toString().contains("Video not found")) {
        errorMessage =
            "📹 Video not found. It may have been deleted or made private.";
      } else {
        errorMessage = "💥 Failed to load audio: ${e.toString()}";
      }

      currentError.value = errorMessage;
      isPlaying.value = false;
    } finally {
      isLoading.value = false;
      yt?.close(); // Safe null-aware close
    }
  }

  // Enhanced search with better filtering and error handling
  Future<void> searchVideos(String query) async {
    if (query.trim().isEmpty) return;

    YoutubeExplode? yt;

    try {
      currentError.value = '';
      yt = YoutubeExplode();

      var searchResults = await yt.search
          .getVideos(query)
          .timeout(
            Duration(minutes: 2),
            onTimeout: () => throw Exception('Search timeout'),
          );

      // Enhanced filtering with null safety
      var filteredVideos = searchResults
          .where((video) {
            try {
              // Null safety checks
              if (video.title == null ||
                  video.author == null ||
                  video.duration == null ||
                  video.id == null) {
                return false;
              }

              var title = video.title.toLowerCase();
              var author = video.author.toLowerCase();
              var duration = video.duration!;

              return duration.inMinutes < 60 && // Skip very long videos
                  duration.inSeconds > 30 && // Skip very short videos
                  !title.contains('live') &&
                  !title.contains('stream') &&
                  !title.contains('remix') && // Remixes often have restrictions
                  !author.contains('vevo') && // VEVO videos often restricted
                  !author.contains(
                    'records',
                  ) && // Record labels often restricted
                  !title.contains('official video') && // Often more restricted
                  !title.contains('music video'); // Often more restricted
            } catch (e) {
              print("Error filtering video: $e");
              return false;
            }
          })
          .take(15)
          .toList();

      this.searchResults.value = filteredVideos;
      print(
        "Search results: ${filteredVideos.length} videos found (filtered from ${searchResults.length}).",
      );

      if (filteredVideos.isEmpty && searchResults.isNotEmpty) {
        currentError.value =
            "Found videos but they may have playback restrictions. Try searching for different terms or artists.";
      } else if (filteredVideos.isEmpty) {
        currentError.value = "No videos found. Try a different search term.";
      }
    } catch (e) {
      print("Search error: $e");
      currentError.value = "Search failed: ${e.toString()}";
      searchResults.clear();
    } finally {
      yt?.close();
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
