# Quick Setup Guide

## Before Running the App

### 1. Configure API Endpoint

Open `lib/config/app_config.dart` and update the API base URL:

```dart
static const String apiBaseUrl = 'http://YOUR-EC2-IP:8000';
```

Replace `YOUR-EC2-IP` with your actual EC2 instance public IP address.

**Example:**
```dart
static const String apiBaseUrl = 'http://54.123.45.67:8000';
```

### 2. Ensure API Server is Running

Make sure your Mockingbird API server is running and accessible:

```bash
# Test from your development machine
curl http://YOUR-EC2-IP:8000/health

# Expected response:
# {"status":"healthy"}
```

### 3. Network Configuration

#### For Android Emulator:
- If API server is on localhost, use: `http://10.0.2.2:8000`
- If API server is on same network, use actual IP address

#### For Physical Device:
- Ensure device is on same network as API server
- Use the actual IP address of the server
- Check firewall allows port 8000

#### For iOS Simulator:
- If API server is on localhost, use: `http://localhost:8000`
- If API server is on same network, use actual IP address

### 4. Run the App

```bash
flutter run
```

## Testing the App

### Test Library Functionality:
1. Open the app
2. Tap the upload button (floating action button)
3. Select a music file (.mp3, .m4a, or .flac)
4. Wait for upload to complete
5. Tap download icon to download the song
6. Tap play icon to play the song

### Test AI Chat:
1. Switch to "AI Chat" tab
2. Ask: "What songs do I have?"
3. The AI should respond with your library contents

## Troubleshooting

### Connection Issues:
```bash
# Check API is reachable from your device
# Use your device's browser to visit:
http://YOUR-EC2-IP:8000/health
```

### Android Network Security:
If using HTTP (not HTTPS), you may need to allow cleartext traffic.
Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS App Transport Security:
For HTTP connections, add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Features Overview

### Library Page
- 📁 Browse directories
- ⬆️ Upload music files
- ⬇️ Download songs to cache
- ▶️ Play downloaded songs
- ❌ Delete songs

### AI Chat Page
- 💬 Chat with AI about your music
- 📊 Ask for statistics
- 🔍 Query your collection
- 🎵 Get recommendations

## Next Steps

After successful setup:
1. Upload some music files
2. Organize them in directories
3. Try the AI assistant
4. Enjoy your cloud music library!
