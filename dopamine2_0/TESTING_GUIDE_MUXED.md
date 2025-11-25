# Quick Testing Guide - Muxed Stream Workaround

## ✅ Implementation Complete

The app now uses muxed streams (max 720p) for reliable YouTube playback.

## How to Test

### 1. Start the App
```cmd
flutter run -d windows
```

### 2. Search and Play a Video

1. Search for any song (e.g., "Bohemian Rhapsody")
2. Click on a search result to play

### 3. Verify Console Output

You should see these messages indicating the workaround is working:

```
⚠️  WORKAROUND ACTIVE: Using muxed streams only (max 720p) for reliable playback
📊 Available muxed streams (reliable):
   - 720p @ 2500 kbps
   - 480p @ 1500 kbps
   - 360p @ 1000 kbps
✅ Selected muxed stream: 720p @ 2500 kbps
   Container: mp4
   ✅ Reliable playback expected (muxed stream with audio+video)
```

### 4. Test Quality Selection

1. Open quality selector (if available in UI)
2. Verify it shows only: 720p, 480p, 360p, 240p (NO 1080p, 1440p, or 4K)
3. Switch between qualities
4. Verify smooth transitions without errors

### 5. Test Video Mode

1. Click video mode toggle/button
2. Console should show:
   ```
   📺 Using muxed stream (video+audio together) for reliable playback
   🎯 Target quality: 720p
   📹 Opening muxed stream...
   📺 Video loaded - Width: 1280, Height: 720
   ▶️ Starting video playback...
   ✅ Switched to video mode with embedded audio
   ```
3. Video should play **WITHOUT** these errors:
   - ❌ "Failed to open https://..."
   - ❌ "Video player error"
   - ❌ MediaKit errors

### 6. Test Playback Controls

- ▶️ Play/Pause: Should work smoothly
- ⏩ Seek: Should seek correctly without stuttering
- 🔄 Switch to audio mode: Should maintain position
- 🔄 Switch back to video: Should resume from same position

### 7. Test Mode Switching

1. Start playing in audio mode
2. Switch to video mode (console: `🎬 Switching to video mode...`)
3. Video should load and play from same position
4. Switch back to audio mode
5. Audio should resume from same position

## ✅ Success Criteria

- ✅ Videos play reliably without errors
- ✅ No "Failed to open" or MediaKit errors
- ✅ Quality selector shows max 720p
- ✅ Smooth quality switching
- ✅ Playback controls work correctly
- ✅ Mode switching maintains playback position
- ✅ No audio/video sync issues
- ✅ Console shows workaround indicators

## ❌ What Should NOT Happen

- ❌ No MediaKit "Failed to open" errors
- ❌ No 1080p, 1440p, or 4K options in quality selector
- ❌ No audio/video sync drift warnings
- ❌ No dual-player synchronization messages
- ❌ No playback failures or crashes

## 🐛 If You See Errors

### "Failed to open https://..." Error
- This should NOT happen anymore
- If it does, check if video-only streams are being selected
- Verify YouTubeService is using muxed streams

### Quality Selector Shows 1080p+
- Check `getAvailableQualities()` in YouTubeService
- Should only return muxed stream qualities

### Audio/Video Out of Sync
- This should NOT happen with muxed streams
- Muxed streams have audio+video together
- No synchronization needed

## 📊 Expected Performance

- **Load Time**: 1-2 seconds
- **Buffering**: Minimal (muxed streams are efficient)
- **Quality**: Up to 720p (clear and smooth)
- **Reliability**: High (should "just work")

## 🔄 Next Steps After Testing

If testing is successful:
1. ✅ Mark as working
2. ✅ Document in release notes
3. ✅ Consider UI message about max 720p quality

If you want 1080p+ support in the future:
- Consider integrating `youtube_player_flutter` package
- See `MUXED_STREAM_WORKAROUND.md` for implementation options

---

**Testing Date**: November 22, 2025
**Expected Result**: ✅ Reliable playback up to 720p
**Known Limitation**: Max quality is 720p (trade-off for reliability)
