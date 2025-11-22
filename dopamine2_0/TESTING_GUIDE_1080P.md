# Testing Guide: 1080p Video Playback

## How to Test the Fix

### 1. Start the App
The app should already be running on Windows. If not:
```bash
flutter run -d windows
```

### 2. Search for a Video
1. Go to the search screen
2. Search for a popular music video (e.g., "Official Music Video")
3. Select any video from the results

### 3. Test 1080p Playback

#### Step 1: Initial Audio Playback
- Video should start playing in audio-only mode
- Verify you can hear the audio

#### Step 2: Switch to Video Mode
- Click the video player icon/button to switch to video mode
- **Expected Result**: 
  - Video should appear and play
  - Audio should continue playing
  - Both should be synchronized

#### Step 3: Check Quality
- You should see the video playing
- Look for the quality badge (should show "FULL HD" for 1080p)
- Click the "High Quality" icon to open the quality selector

#### Step 4: Quality Selector
- The quality dialog should open
- Available qualities will be listed (2160p (4K), 1440p (2K), 1080p, 720p, etc.)
- Current quality should be highlighted (default: 1080p)
- Each quality has a colored badge:
  - 🔴 4K ULTRA HD (2160p)
  - 🟠 2K QHD (1440p)
  - 🔵 FULL HD (1080p)
  - 🟢 HD (720p)
  - 🟡 SD (480p)

#### Step 5: Change Quality
1. Select **720p** (standard quality):
   - Video should reload at 720p
   - Should use single-stream playback (video+audio together)
   - No audio sync issues

2. Switch back to **1080p**:
   - Video should reload at 1080p
   - Should use dual-stream synchronized playback
   - Audio should remain in sync

3. Try **1440p or 4K** if available:
   - Same synchronized playback behavior as 1080p
   - Higher resolution video

### 4. Test Playback Controls

While in 1080p video mode:
- ▶️ **Play/Pause**: Should pause/resume both video and audio
- ⏩ **Seek**: Dragging the progress bar should seek both players
- ⏪ **Skip Back 10s**: Should rewind both players
- ⏩ **Skip Forward 10s**: Should advance both players

### 5. Check Console Output

Watch the console for these log messages:

**When switching to 1080p video:**
```
🎬 Switching to video mode...
Current video quality: 1080p
Video URL: ...
Audio URL: ...
⏳ Loading video player at quality 1080p...
🎵 High-quality mode: Using video player for video + just_audio for audio
⏩ Seeking to Xs
▶️ Starting synchronized playback...
✅ Switched to synchronized high-quality video mode
📺 Video tracks: X
🎵 Audio tracks: X
```

**When switching to 720p:**
```
🎬 Changing video quality to: 720p
New video URL: ...
⏸️ Pausing current video...
⏳ Loading new quality stream...
📺 Standard quality mode: Using embedded audio
⏩ Seeking to position: Xs
▶️ Resuming playback...
✅ Quality changed to 720p successfully
```

### 6. Verify Audio-Video Sync

- Play for at least 30 seconds at 1080p
- Watch for any audio-video desynchronization
- If you notice drift, note the time when it occurs

### Expected Behavior Summary

| Quality | Stream Type | Audio Source | Video Source | Notes |
|---------|-------------|--------------|--------------|-------|
| 360p-720p | Muxed | Video Player | Video Player | Single stream, embedded audio |
| 1080p-4K | Separate | just_audio Player | MediaKit Player | Dual synchronized streams |

## Common Issues and Solutions

### Issue: No Audio in 1080p Mode
**Cause**: Audio player not initialized or URL not loaded
**Check**: Console logs for "🎵 High-quality mode" message
**Solution**: Verify `currentAudioUrl.value` is not empty

### Issue: Video and Audio Out of Sync
**Cause**: Players drifting apart over time
**Solution**: Pause and resume, or seek to resync
**Note**: Slight drift (<100ms) is normal for dual-player approach

### Issue: Video Freezes When Changing Quality
**Cause**: Network buffering or stream loading delay
**Solution**: Wait for loading spinner to complete

### Issue: Quality Selector Shows Wrong Current Quality
**Cause**: UI not updating with actual quality
**Solution**: Check `currentVideoQuality.value` in console logs

## Success Criteria

✅ Video plays with audio at 1080p
✅ Quality selector shows available qualities
✅ Quality changes work smoothly
✅ Play/Pause/Seek controls work in 1080p mode
✅ Audio and video stay synchronized (within 100ms)
✅ No crashes or errors during quality switching
✅ Console logs show correct playback mode

## Debugging Tips

1. **Check Stream URLs**: Look for logs showing the actual URLs being fetched
2. **Monitor Player States**: Watch for "Playing: true/false" logs
3. **Verify Quality Detection**: Check if quality height is calculated correctly
4. **Audio Player State**: Ensure audio player is in "ready" state before syncing

## Report Issues

If you encounter issues, please provide:
1. Video ID or search query used
2. Selected quality
3. Console logs (copy full output)
4. Description of the issue
5. Steps to reproduce
