# Files to Delete - Cleanup Guide

These are **duplicate/outdated** screen files that should be deleted. You're using the newer versions in `lib/screens/` folders.

## Delete these files from lib/ root folder:

1. `lib/favorites_screen.dart` - Duplicate, use `lib/screens/favorites/favorites_screen.dart` instead
2. `lib/player_screen.dart` - Duplicate, use `lib/screens/audio/audio_player_screen.dart` and `lib/screens/video/video_player_screen.dart` instead
3. `lib/playlist_detail_screen.dart` - Duplicate, use `lib/screens/playlists/playlist_detail_screen.dart` instead
4. `lib/playlists_screen.dart` - Duplicate, use `lib/screens/playlists/playlists_screen.dart` instead
5. `lib/search_screen.dart` - Duplicate, use `lib/screens/search/search_screen.dart` instead

## Additional File to Delete

## Delete this controller file:

`c:\Users\snigd\Downloads\Scratch-main\Scratch-main\dopamine2_0\lib\controllers\app_controller.dart`

## Why?

This file is part of an **old architecture pattern** that wraps all controllers. Your current project uses a **direct controller pattern** which is simpler and cleaner.

### Old Pattern (AppController - NOT USED):
```dart
// ❌ Old way - wrapped in AppController
final appController = Get.find<AppController>();
final favorites = appController.favoritesController;
```

### New Pattern (Direct - CURRENT):
```dart
// ✅ New way - direct access via helper
final favorites = Controllers.favorites;
```

## Your Current Architecture:

**main.dart** initializes controllers directly:
```dart
Get.put(FavoritesController(), permanent: true);
Get.put(PlaylistController(), permanent: true);
// etc...
```

**Screens** access controllers via helper:
```dart
import '../../utils/controller_helper.dart';

final favorites = Controllers.favorites;
final playlist = Controllers.playlist;
```

## How to delete:

**Option 1: Delete via VS Code**
- Right-click each file in the file explorer
- Select "Delete"
- Confirm deletion

**Option 2: Delete via Command Line**
```bash
cd c:\Users\snigd\Downloads\Scratch-main\Scratch-main\dopamine2_0
del lib\favorites_screen.dart
del lib\player_screen.dart
del lib\playlist_detail_screen.dart
del lib\playlists_screen.dart
del lib\search_screen.dart
del lib\controllers\app_controller.dart
```

Or in PowerShell:
```powershell
cd c:\Users\snigd\Downloads\Scratch-main\Scratch-main\dopamine2_0
Remove-Item lib\favorites_screen.dart
Remove-Item lib\player_screen.dart
Remove-Item lib\playlist_detail_screen.dart
Remove-Item lib\playlists_screen.dart
Remove-Item lib\search_screen.dart
Remove-Item lib\controllers\app_controller.dart
```

## Current Project Structure (KEEP THESE):

```
lib/
├── main.dart ✅
├── controllers/ ✅
│   ├── favorites_controller.dart
│   ├── playlist_controller.dart
│   ├── download_controller.dart
│   ├── mini_player_controller.dart
│   ├── media_switch_controller.dart
│   ├── history_controller.dart
│   ├── search_controller.dart
│   └── nav_controller.dart
├── screens/ ✅
│   ├── home/
│   │   └── home_screen.dart (✅ Updated with home button)
│   ├── search/
│   │   ├── search_screen.dart (✅ Updated with home button)
│   │   └── search_results_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart (✅ Updated with home button)
│   ├── playlists/
│   │   ├── playlists_screen.dart (✅ Updated with home button)
│   │   └── playlist_detail_screen.dart (✅ Updated with home button)
│   ├── downloads/
│   │   └── downloads_screen.dart (✅ Updated with home button)
│   ├── history/
│   │   └── history_screen.dart (✅ Updated with home button)
│   ├── audio/
│   │   └── audio_player_screen.dart (✅ Updated with home button)
│   └── video/
│       └── video_player_screen.dart (✅ Updated with home button)
├── widgets/ ✅
│   ├── dopamine_app_bar.dart (✅ NEW - Home button widget)
│   ├── aurora_mini_player.dart
│   └── aurora_navbar.dart
├── utils/ ✅
│   └── controller_helper.dart (✅ NEW - Easy controller access)
├── routes/ ✅
│   ├── app_pages.dart
│   └── app_routes.dart
├── theme/ ✅
│   └── midnight_aurora_theme.dart
└── models/ ✅
    └── media_item.dart
```

## After Deletion:

Run these commands to verify everything works:
```bash
flutter clean
flutter pub get
flutter run -d windows
```

All screens now have:
- ✅ Home button (via DopamineAppBar)
- ✅ Global controller access (via Controllers helper)
- ✅ Consistent navigation
- ✅ Clean architecture
