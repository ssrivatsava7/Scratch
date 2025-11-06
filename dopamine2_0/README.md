# Dopamine 2.0 - YouTube Audio & Video Player

A Flutter application for streaming YouTube audio and video content with an intuitive user interface.

## Features

### 🎵 Audio Player
- **Search YouTube**: Find any song or audio content
- **High-Quality Audio**: Streams best available audio quality
- **Smart Filtering**: Automatically filters for playable content (30s-60min)
- **Playback Controls**: Play, pause, and stop controls
- **Error Handling**: Clear error messages for restricted content

### 🎥 Video Player
- **Full Video Playback**: Stream YouTube videos with audio
- **Quality Selection**: Automatically selects optimal quality (up to 720p)
- **Size Management**: Limits to 150MB for efficient streaming
- **Retry Logic**: Handles network issues with automatic retries

### 🔍 Search & Browse
- Real-time search with instant results
- Video metadata display (title, author, duration)
- Easy navigation between audio and video modes
- Up to 15 relevant results per search

## Technical Stack

- **Flutter/Dart**: Cross-platform mobile framework
- **GetX**: State management and navigation
- **Media Kit**: Audio and video playback engine
- **YouTube Explode Dart**: YouTube data extraction without API
- **HTTP**: Network requests

## Dependencies

Key packages used:
- `get: ^4.6.6` - State management
- `media_kit: ^1.1.7` - Media playback
- `media_kit_video: ^1.2.4` - Video rendering
- `youtube_explode_dart: ^2.4.2` - YouTube integration
- `just_audio: ^0.9.35` - Alternative audio backend
- `http: ^1.1.0` - HTTP client

## Project Structure

```
lib/
├── controllers/
│   ├── audio_controller.dart          # Audio playback logic
│   └── youtube_media_controller.dart  # Video stream handling
├── screens/
│   ├── audio_player_screen.dart       # Main audio UI
│   └── video_player_screen.dart       # Video player UI
└── main.dart                          # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/ssrivatsava7/Scratch.git
cd Scratch/dopamine2_0
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. **Search for Content**:
   - Enter a song name or video title in the search bar
   - Press Enter or click the search icon

2. **Play Audio**:
   - Tap any result to play audio only
   - Use play/pause/stop controls

3. **Watch Video**:
   - Tap the video icon on any result
   - Video player opens in a new screen

## Known Limitations

- Age-restricted videos cannot be played
- Live streams are not supported
- Maximum video quality: 720p
- Maximum file size: 150MB
- Video duration: 30 seconds to 60 minutes

## Platform Support

- ✅ Windows (fully supported with native libraries)
- ⚠️ macOS (requires testing)
- ⚠️ Linux (requires testing)
- ⚠️ Android (requires platform-specific configuration)
- ⚠️ iOS (requires platform-specific configuration)

## Troubleshooting

### Common Issues

**"Video requires age verification"**
- This is a YouTube restriction and cannot be bypassed
- Try a different video

**"No playable stream found"**
- Video may be region-locked or restricted
- Check your internet connection

**"Search failed"**
- Verify internet connectivity
- YouTube servers may be temporarily unavailable

## Development

### Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Windows
flutter build windows
```

## Contributing

This is a personal project under development. If you find issues or have suggestions, please create an issue in the repository.

## License

This project is part of the Scratch repository. Please refer to the main repository for licensing information.

## Resources

For Flutter development resources:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [GetX Documentation](https://pub.dev/packages/get)
- [Media Kit Documentation](https://pub.dev/packages/media_kit)

## Disclaimer

This application streams content from YouTube. Please ensure you comply with YouTube's Terms of Service when using this application. This tool is for personal use only.

