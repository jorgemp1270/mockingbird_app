# 🎵 Mockingbird App - Setup Checklist

## ✅ Pre-Launch Checklist

### 1. API Configuration
- [ ] Open `lib/config/app_config.dart`
- [ ] Replace `'http://your-ec2-ip:8000'` with your actual EC2 IP address
  - Example: `'http://54.123.45.67:8000'`
- [ ] Save the file

### 2. Verify API Server
- [ ] Ensure your Mockingbird API server is running
- [ ] Test the health endpoint:
  ```bash
  curl http://YOUR-EC2-IP:8000/health
  ```
- [ ] Expected response: `{"status":"healthy"}`

### 3. Network Setup
- [ ] If testing on Android emulator with local server:
  - [ ] Use `http://10.0.2.2:8000` instead of localhost
- [ ] If testing on physical device:
  - [ ] Ensure device is on same network as API server
  - [ ] Check firewall allows port 8000
- [ ] For iOS simulator with local server:
  - [ ] Use `http://localhost:8000`

### 4. Dependencies (Already Done ✓)
- [x] Dependencies installed via `flutter pub get`
- [x] Android permissions configured
- [x] Cleartext traffic enabled

### 5. First Run
- [ ] Run `flutter run` or use your IDE's run button
- [ ] App should launch without errors
- [ ] You should see the Library page (empty initially)

## 🎯 Testing Checklist

### Library Features
- [ ] **Upload Test**
  - [ ] Tap the upload button (floating action button)
  - [ ] Select a .mp3, .m4a, or .flac file
  - [ ] File appears in library after upload

- [ ] **Download Test**
  - [ ] Tap download icon next to a song
  - [ ] Wait for download to complete
  - [ ] Icon changes to play button

- [ ] **Playback Test**
  - [ ] Tap play button on downloaded song
  - [ ] Music should start playing
  - [ ] Tap again to pause

- [ ] **Delete Test**
  - [ ] Tap X button next to a song
  - [ ] Confirm deletion in dialog
  - [ ] Song disappears from library

- [ ] **Directory Navigation**
  - [ ] Upload files with paths (or create via API)
  - [ ] Tap folder to enter
  - [ ] App bar shows folder name
  - [ ] Use back button to return

### AI Chat Features
- [ ] **Switch to AI Tab**
  - [ ] Tap "AI Chat" in bottom navigation
  - [ ] See welcome message

- [ ] **Ask Questions**
  - [ ] Type: "What songs do I have?"
  - [ ] AI responds with library info
  - [ ] Try: "List all my rock songs"
  - [ ] Try: "What are my top artists?"

## 🐛 Troubleshooting

### Connection Errors
If you see "Failed to load library":
- [ ] Verify API URL in `app_config.dart` is correct
- [ ] Check API server is running
- [ ] Test API from browser: `http://YOUR-EC2-IP:8000/health`
- [ ] Ensure device can reach server (same network)

### Upload Fails
If uploads don't work:
- [ ] Check file format (.mp3, .m4a, .flac only)
- [ ] Verify API server logs for errors
- [ ] Ensure S3 bucket permissions are correct
- [ ] Check network connectivity

### Can't Play Music
If playback doesn't work:
- [ ] Ensure song is downloaded first
- [ ] Check device volume
- [ ] Try a different audio file
- [ ] Check app has storage permissions

### Android HTTP Issues
If Android can't connect:
- [ ] Verify `android:usesCleartextTraffic="true"` in AndroidManifest.xml
- [ ] Check internet permission is added

### iOS HTTP Issues
If iOS can't connect:
- [ ] May need to add App Transport Security exception
- [ ] See SETUP.md for Info.plist configuration

## 📱 Platform-Specific Notes

### Android
- ✅ Cleartext traffic enabled
- ✅ Internet permission added
- ✅ Storage permissions added

### iOS (if deploying)
- ⚠️ May need App Transport Security configuration for HTTP
- ⚠️ Check Info.plist for required permissions

## 🎉 Success Indicators

You'll know everything is working when:
- ✅ App launches without crashes
- ✅ Library page loads (even if empty)
- ✅ Can upload a music file
- ✅ Can download and play uploaded files
- ✅ AI chat responds to questions
- ✅ Can navigate folders
- ✅ Can delete files

## 📚 Documentation Reference

- **SETUP.md** - Detailed setup instructions
- **APP_README.md** - Full app documentation
- **IMPLEMENTATION_SUMMARY.md** - Technical overview
- **API_DOCUMENTATION.md** - API reference

## 🚀 Ready to Launch!

Once all items are checked:
1. Your API server is configured and running
2. Your app is connected to the API
3. You can upload, download, and play music
4. The AI assistant is working

Enjoy your Mockingbird music library! 🎵
