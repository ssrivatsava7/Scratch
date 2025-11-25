# Video Quality API Reference

## Quick Reference for Developers

### Key Methods

#### YouTubeService (`lib/services/youtube_service.dart`)

```dart
// Get stream URLs with specific quality
static Future<Map<String, String?>> getStreamUrls(
  String videoId, 
  {String videoQuality = '720p'}
)

// Returns: {'audioUrl': String?, 'videoUrl': String?}
// Quality format: '2160p (4K)', '1440p (2K)', '1080p', '720p', '480p', '360p'

// Get all available qualities for a video
static Future<List<String>> getAvailableQualities(String videoId)

// Returns: ['2160p (4K)', '1440p (2K)', '1080p', '720p', '480p', '360p']
// Sorted in descending order (highest first)
```

#### SearchController (`lib/controllers/search_controller.dart`)

```dart
// Get stream URLs (with quality normalization)
Future<Map<String, String?>> getStreamUrls(
  String videoId, 
  {String videoQuality = '720p'}
)

// Get available qualities
Future<List<String>> getAvailableQualities(String videoId)
```

#### MediaSwitchController (`lib/controllers/media_switch_controller_new.dart`)

```dart
// Observables
final currentVideoQuality = '1080p'.obs;  // Current quality
final availableQualities = <String>[].obs; // Available qualities

// Change quality on the fly
Future<void> changeVideoQuality(String quality, String newVideoUrl)
```

### Quality Constants

```dart
// Quality Resolution Map
final qualityMap = {
  '2160p (4K)': 2160,  // 4K Ultra HD
  '1440p (2K)': 1440,  // 2K QHD
  '1080p': 1080,       // Full HD
  '720p': 720,         // HD
  '480p': 480,         // SD
  '360p': 360,         // Low
  '240p': 240,         // Minimum
};

// Quality Badge Colors
final qualityColors = {
  '2160p (4K)': Colors.red,         // 4K
  '1440p (2K)': Colors.deepOrange,  // 2K
  '1080p': Colors.blue,              // Full HD
  '720p': Colors.green,              // HD
  '480p': Colors.orange,             // SD
};
```

### Usage Examples

#### Example 1: Get and Play Video with Specific Quality

```dart
// Get video ID
final videoId = 'dQw4w9WgXcQ';

// Fetch available qualities
final qualities = await Controllers.search.getAvailableQualities(videoId);
print('Available: $qualities'); // ['2160p (4K)', '1080p', '720p', ...]

// Get stream URLs for 1080p
final streams = await Controllers.search.getStreamUrls(
  videoId, 
  videoQuality: '1080p'
);

// Load media
await Controllers.mediaSwitch.loadMedia(
  title: 'Video Title',
  thumbnail: 'https://...',
  audio: streams['audioUrl']!,
  video: streams['videoUrl']!,
  qualities: qualities,
  artist: 'Channel Name',
);
```

#### Example 2: Switch Quality During Playback

```dart
// User selects new quality
final newQuality = '2160p (4K)';

// Fetch new stream URL
final streams = await Controllers.search.getStreamUrls(
  videoId,
  videoQuality: newQuality,
);

// Change quality
await Controllers.mediaSwitch.changeVideoQuality(
  newQuality,
  streams['videoUrl']!,
);
```

#### Example 3: Show Quality Selector

```dart
// In your widget
void showQualityDialog(String videoId) {
  Get.dialog(
    VideoQualitySelector(
      videoId: videoId,
      onQualitySelected: (quality) {
        print('Selected: $quality');
        // Handle quality change
      },
    ),
  );
}
```

### Quality String Normalization

When passing quality strings to `getStreamUrls()`:

```dart
// Input (from UI)          →  Normalized (for API)
'2160p (4K)'               →  '2160p'
'1440p (2K)'               →  '1440p'
'1080p'                    →  '1080p'

// Normalization in SearchController:
final normalizedQuality = videoQuality
    .replaceAll(' (4K)', '')
    .replaceAll(' (2K)', '');
```

### Stream Selection Algorithm

```dart
// High quality (1080p+): Prefer video-only streams
if (requestedHeight >= 1080 && manifest.videoOnly.isNotEmpty) {
  // Use video-only stream for better bitrate
  // Requires separate audio stream
}

// Medium quality (720p and below): Use muxed streams
else if (manifest.muxed.isNotEmpty) {
  // Use muxed stream (audio + video combined)
  // Better for compatibility
}

// Fallback: Use video-only if muxed unavailable
```

### Error Handling

```dart
try {
  final streams = await getStreamUrls(videoId, videoQuality: '1080p');
  
  if (streams['videoUrl'] == null) {
    // Quality not available, try fallback
    final fallbackStreams = await getStreamUrls(videoId, videoQuality: '720p');
  }
} catch (e) {
  // Handle network or parsing errors
  print('Error: $e');
  // Use default qualities: ['1080p', '720p', '480p', '360p']
}
```

### UI Integration

#### Settings Button with Quality Badge

```dart
IconButton(
  icon: Stack(
    alignment: Alignment.center,
    children: [
      Icon(Icons.settings, color: Colors.white),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.purpleAccent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Obx(() => Text(
            media.currentVideoQuality.value
                .replaceAll('p', '')
                .replaceAll(' (4K)', '')
                .replaceAll(' (2K)', ''),
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    ],
  ),
  onPressed: () => showQualitySelector(),
)
```

### Testing Checklist

- [ ] Test with 4K videos (YouTube Premium required for some)
- [ ] Test with videos that don't support all qualities
- [ ] Verify quality switching preserves position
- [ ] Test on slow network (buffering behavior)
- [ ] Verify quality labels are correct
- [ ] Test fallback when quality unavailable
- [ ] Check default quality (should be 1080p)
- [ ] Verify UI updates after quality change

### Performance Tips

1. **Cache Qualities**: Store `availableQualities` to avoid repeated API calls
2. **Preload Streams**: Fetch next quality in background for instant switching
3. **Quality Limits**: Consider limiting max quality based on screen resolution
4. **Network Check**: Suggest quality based on connection speed
5. **User Preference**: Remember user's preferred quality in settings

### Known Limitations

- Some videos may not have all qualities available
- 4K streams require more bandwidth (~25 Mbps)
- YouTube may rate-limit quality fetching for rapid switches
- DRM-protected content may have limited quality options

### Future Enhancements

```dart
// Possible additions:
- Auto-quality based on network speed
- Quality preference persistence
- Bitrate display for each quality
- Custom quality selection (not just presets)
- Adaptive streaming (HLS/DASH)
```

---

**Last Updated**: November 21, 2025  
**Version**: 1.0.0  
**Maintainer**: Dopamine Development Team
