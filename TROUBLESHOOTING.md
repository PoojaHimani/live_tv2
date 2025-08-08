# Live TV App - Troubleshooting Guide

## 🎬 **Videos Not Playing Issues**

### **Common Causes & Solutions:**

### 1. **YouTube Player Issues**
- **Problem**: YouTube videos not loading or showing black screen
- **Solutions**:
  - Check internet connection
  - Restart the app (hot reload: `r` in terminal)
  - Try different YouTube URLs
  - Clear browser cache if running on web

### 2. **Missing Content in Movies/Kids Categories**
- **Problem**: No programs showing in MOVIES or KIDS sections
- **Solution**: Restart the app completely to reload sample data
  ```bash
  # Stop the app (Ctrl+C in terminal)
  # Then restart:
  flutter run
  ```

### 3. **Video Player Controls**
- **Note**: Video controls are intentionally minimal as per requirements
- **Available actions**:
  - Back button to return to TV guide
  - Fullscreen toggle (top right)
  - Videos auto-play when selected

### 4. **Web Platform Limitations**
- **Issue**: Some video features may not work properly on web
- **Solution**: Run on Android/iOS/Desktop for best experience
- **Web workarounds**:
  - Use Chrome or Edge browser
  - Enable autoplay in browser settings

## 📺 **Content Categories**

### **Available Content:**

#### **MOVIES Category:**
- HBO: Avengers Endgame, The Batman
- Netflix: Spider-Man No Way Home
- Disney+: Frozen 2, Moana

#### **KIDS Category:**
- Cartoon Network: Tom and Jerry
- Nickelodeon: SpongeBob SquarePants
- Disney Junior: Mickey Mouse Clubhouse

#### **SPORTS Category:**
- FOX Sports: Hockey games, Kings Live

#### **NEWS Category:**
- CBS: News programs, 60 Minutes
- CNBC: Deal or No Deal, Shark Tank

#### **RECENT Category:**
- TBS: Seinfeld, Big Bang Theory
- Food Network: Cooking shows

## 🔧 **Quick Fixes**

### **If Videos Don't Play:**
1. **Hot Reload**: Press `r` in the terminal where flutter run is active
2. **Full Restart**: Press `Ctrl+C` then `flutter run` again
3. **Check Console**: Look for error messages in the terminal
4. **Try Different Video**: Click on different programs to test

### **If No Content Shows:**
1. **Wait for Loading**: Sample data loads automatically on app start
2. **Check Categories**: Switch between different categories in left menu
3. **Restart App**: Full restart usually fixes loading issues

### **Platform-Specific Tips:**

#### **Windows Desktop:**
- Videos should play normally
- Use desktop version for best performance

#### **Web Browser:**
- May have YouTube embedding restrictions
- Some videos might not play due to CORS policies
- Try different browsers (Chrome, Edge, Firefox)

#### **Mobile (Android/iOS):**
- Best video playback experience
- All features should work properly

## 🐛 **Debug Mode**

### **Enable Debug Information:**
1. **Check Terminal Output**: Look for error messages
2. **Console Logs**: YouTube player logs when ready
3. **Error Messages**: App shows snackbar for invalid URLs

### **Common Error Messages:**
- "Invalid YouTube URL" - Check the video URL format
- "Error loading video" - Network or format issue
- "Video not available" - YouTube video might be restricted

## 🎯 **Test Videos**

### **Working YouTube URLs for Testing:**
- Avengers Trailer: `https://www.youtube.com/watch?v=TcMBFSGVi1c`
- Spider-Man Trailer: `https://www.youtube.com/watch?v=JfVOs4VSpmA`
- Frozen 2 Trailer: `https://www.youtube.com/watch?v=Zi4LMpSDccc`

### **To Add Custom Videos:**
1. Go to Settings (password: 1234)
2. Click Programs tab
3. Add Program with YouTube URL
4. Use calendar widget to set timing

## ⚡ **Performance Tips**

1. **Close Other Apps**: Free up system resources
2. **Good Internet**: Stable connection for YouTube videos
3. **Updated Flutter**: Ensure latest Flutter version
4. **Clean Build**: Run `flutter clean` then `flutter pub get` if issues persist

## 📞 **Still Having Issues?**

### **Steps to Report Problems:**
1. **Check Terminal Output**: Copy any error messages
2. **Note Platform**: Windows/Web/Android/iOS
3. **Describe Issue**: What exactly isn't working
4. **Test Steps**: What you tried before the issue occurred

### **Emergency Reset:**
If app is completely broken:
```bash
flutter clean
flutter pub get
flutter run
```

This will reset everything and reload fresh sample data. 