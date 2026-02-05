# Mockingbird App

A Flutter music library management app that allows users to upload, download, and play music files from cloud storage, with an AI assistant powered by Gemini.

## Features

### Library Page
- **Directory Structure**: Navigate through your music organized in folders
- **File Management**:
  - Upload music files (.mp3, .m4a, .flac) to any directory
  - Download songs to local cache for offline playback
  - Delete songs from cloud storage
- **Music Player**: Play downloaded songs directly in the app
- **Visual Indicators**:
  - Folders shown with folder icon
  - Downloaded songs show play button
  - Not downloaded songs show download button
  - All songs have a delete button

### AI Chat Page
- Chat interface to ask questions about your music library
- Powered by Gemini AI
- Examples:
  - "What songs do I have?"
  - "List all my rock songs"
  - "What are my top 5 artists?"
  - "Show me songs from the 1980s"

## Setup

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- An Android/iOS device or emulator
- Running Mockingbird API server

### Installation

1. **Clone the repository** (if applicable)
   ```bash
   cd mockingbird_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**

   Edit `lib/config/app_config.dart` and replace the API base URL with your EC2 instance IP:
   ```dart
   static const String apiBaseUrl = 'http://YOUR-EC2-IP:8000';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # App configuration (API URL)
├── models/
│   └── song.dart                # Data models (Song, LibraryItem, ChatMessage)
├── pages/
│   ├── library_page.dart        # Library/music management page
│   └── ai_chat_page.dart        # AI chat interface
├── services/
│   ├── api_service.dart         # API client for Mockingbird backend
│   ├── cache_service.dart       # Local cache management
│   └── music_player_service.dart # Audio playback service
└── main.dart                    # App entry point
```

## Usage

### Uploading Music
1. Navigate to the desired directory (or stay in root)
2. Tap the floating upload button (⬆)
3. Select a music file (.mp3, .m4a, or .flac)
4. The file will be uploaded to the current directory

### Playing Music
1. Download a song by tapping the download icon
2. Once downloaded, tap the play button to listen
3. Tap again to pause

### Navigating Directories
- Tap on any folder to enter it
- Use the back button to go up one level
- The app bar shows the current directory name

### Using AI Assistant
1. Switch to the "AI Chat" tab
2. Type your question about your music library
3. The AI will analyze your library and respond

### Deleting Songs
1. Tap the "X" button next to any song
2. Confirm the deletion
3. The song will be removed from cloud storage and local cache

## Dependencies

- `http`: HTTP client for API calls
- `path_provider`: Access to device directories
- `file_picker`: File selection for uploads
- `audioplayers`: Audio playback
- `shared_preferences`: Local storage for cache management
- `path`: Path manipulation utilities

## API Integration

The app consumes the Mockingbird API with the following endpoints:

- `GET /library` - Get all songs in library
- `GET /library/{song_id}` - Get specific song metadata
- `POST /upload` - Upload a music file
- `DELETE /library/{song_id}` - Delete a song
- `GET /download/{song_id}` - Download a song file
- `POST /prompt` - Ask Gemini AI about your library

See `API_DOCUMENTATION.md` for full API details.

## Troubleshooting

### "Failed to load library" error
- Check that your API server is running
- Verify the API URL in `app_config.dart` is correct
- Ensure your device can reach the server (same network or proper firewall rules)

### Upload fails
- Verify file format is .mp3, .m4a, or .flac
- Check API server logs for errors
- Ensure S3 bucket permissions are correct

### Audio won't play
- Make sure the song is downloaded first (download icon should become play icon)
- Check device audio settings and volume
- Verify the downloaded file isn't corrupted

## Notes

- Downloaded songs are stored in the app's cache directory
- Cache persists between app sessions
- Deleting a song removes it from both cloud and local cache
- The app requires network connectivity for uploads, downloads, and AI chat

## Future Enhancements

Potential features for future versions:
- Playlist management
- Search functionality
- Sorting options (by artist, date, etc.)
- Background playback
- Queue management
- Batch upload/download
- Offline mode with sync

## License

[Your License Here]
