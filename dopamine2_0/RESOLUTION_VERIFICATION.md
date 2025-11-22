# Resolution Verification Guide

## How to Verify 1080p is Actually Playing

### Step 1: Check Console Logs
When you play a video and switch to video mode, look for these specific log messages:

#### Expected Log Sequence:
```
🎬 Fetching streams for [videoId] at quality: 1080p
📊 Available video-only streams:
   - 2160p @ XXXX kbps (vp9)
   - 1440p @ XXXX kbps (vp9)
   - 1080p @ XXXX kbps (vp9)   <-- Look for this
   - 720p @ XXXX kbps (avc1)
   - ...
✅ Selected high-quality video-only: 1080p @ XXXX kbps
   Codec: vp9 (or avc1)
   Size: XX.XX MB
   Container: ...
```

#### When Switching to Video:
```
🎬 Switching to video mode...
Current video quality: 1080p
🎵 High-quality mode: Using video player for video + just_audio for audio
🎯 Target quality: 1080p (1080p)
📺 Video loaded - Width: 1920, Height: 1080   <-- VERIFY THIS!
✅ Actual video resolution: 1920x1080         <-- CONFIRM HERE!
```

### Step 2: What to Look For

#### ✅ Good Signs (1080p is working):
- Width: **1920**, Height: **1080**
- Bitrate: **3000-5000+ kbps** (for 1080p)
- Codec: **vp9** or **avc1**
- Log says: "Selected high-quality video-only: **1080p**"

#### ❌ Bad Signs (Not actually 1080p):
- Width: **1280**, Height: **720** (this is 720p!)
- Width: **854**, Height: **480** (this is 480p!)
- Bitrate: **<2000 kbps** (too low for 1080p)
- Log says: "Selected... **720p**" or lower

### Step 3: Common Issues

#### Issue 1: Video Doesn't Have 1080p
**Symptom**: Logs show available streams max out at 720p
**Solution**: Try a different video (older/low-quality videos may not have 1080p)

#### Issue 2: Wrong Stream Selected
**Symptom**: Logs show 1080p available but 720p selected
**Solution**: Check the selection logic in YouTubeService

#### Issue 3: Player Downscaling
**Symptom**: Logs show 1920x1080 loaded but looks pixelated
**Possible causes**:
- Window size is too small (making 1080p look compressed)
- Display scaling issues
- GPU driver problems
- Codec decoding issues

### Step 4: Test with Known 1080p Video

Try these videos that definitely have 1080p:
1. Search: "Official Music Video 1080p"
2. Search: "4K Nature Video" (should have multiple high qualities)
3. Any recent popular music video

### Step 5: Compare Qualities

Do a side-by-side comparison:

1. **Play at 720p**:
   - Note the clarity
   - Check console: Should show 1280x720

2. **Switch to 1080p**:
   - Should look noticeably sharper
   - Check console: Should show 1920x1080
   - Bitrate should be higher

### Step 6: Window Size Check

Make sure your player window is large enough:
- **Minimum for 1080p**: 1920x1080 pixels
- **If window is smaller**: You won't see the full benefit
- **Solution**: Maximize the window or go fullscreen

### Step 7: Visual Quality Indicators

#### What 1080p Should Look Like:
- ✅ Text in video is sharp and readable
- ✅ Fine details are clear (hair, textures, etc.)
- ✅ No obvious pixelation or blocking
- ✅ Smooth gradients without banding

#### What 720p or Lower Looks Like:
- ❌ Text appears slightly blurry
- ❌ Some details are lost
- ❌ Visible compression artifacts
- ❌ Pixelation on fast motion

## Debugging Commands

### 1. Check Current Resolution During Playback
Look for this in console:
```
✅ Actual video resolution: 1920x1080
```

### 2. Verify Stream Selection
Look for this when loading:
```
✅ Selected high-quality video-only: 1080p @ [bitrate] kbps
```

### 3. Check Available Streams
Look for this list:
```
📊 Available video-only streams:
   - 2160p @ ...
   - 1440p @ ...
   - 1080p @ ...  <-- Must be present
```

## Quick Test Script

1. Start app
2. Search: "Official Music Video"
3. Select any video
4. Wait for audio to start
5. Click video mode button
6. **IMMEDIATELY CHECK CONSOLE** for:
   - "📺 Video loaded - Width: ???, Height: ???"
7. Copy those numbers here:
   - Width: _______
   - Height: _______

**If Width = 1920 and Height = 1080**: ✅ It's working!
**If not**: Share the console output for diagnosis

## Performance Check

### Expected Performance at 1080p:
- **CPU Usage**: 15-30% (depending on codec)
- **Memory**: 200-500 MB
- **GPU Usage**: 20-40%
- **Buffering**: Initial buffer, then smooth
- **Frame Rate**: 30 or 60 fps

### Warning Signs:
- ⚠️ Constant buffering (network issue)
- ⚠️ Stuttering playback (CPU/GPU overload)
- ⚠️ Very high CPU (>60%) (codec issue)

## Next Steps

1. **Run the app**
2. **Play a video**
3. **Switch to video mode**
4. **Copy the entire console output**
5. **Look for the resolution lines**
6. **Report back with**:
   - Actual resolution shown in logs
   - Available streams list
   - Whether video looks clear or pixelated
   - Screenshot if possible

## Expected Console Output (Success Case)

```
🎬 Fetching streams for dQw4w9WgXcQ at quality: 1080p
📊 Available video-only streams:
   - 1080p @ 4500 kbps (vp9)
   - 720p @ 2500 kbps (avc1)
   - 480p @ 1500 kbps (avc1)
📊 Available muxed streams:
   - 720p @ 2000 kbps
   - 480p @ 1200 kbps
🎵 Audio: 128 kbps, codec: opus
🎯 Requested quality height: 1080p
✅ Selected high-quality video-only: 1080p @ 4500 kbps
   Codec: vp9
   Size: 45.50 MB
   Container: webm
✅ Stream URLs obtained - Audio: true, Video: true

🎬 Switching to video mode...
Current video quality: 1080p
Video URL: https://...
Audio URL: https://...
⏳ Loading video player at quality 1080p...
🎵 High-quality mode: Using video player for video + just_audio for audio
🎯 Target quality: 1080p (1080p)
📺 Video loaded - Width: 1920, Height: 1080
⏩ Seeking to 0s
▶️ Starting synchronized playback...
✅ Switched to synchronized high-quality video mode
✅ Actual video resolution: 1920x1080
📺 Video tracks: 1
🎵 Audio tracks: 0
```

Look for **"Width: 1920, Height: 1080"** - that's the proof!
