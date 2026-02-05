# Mockingbird API Documentation

**Base URL:** `http://your-ec2-ip:8000`
**Version:** 1.0.0

## Overview

Mockingbird is a music library backup and management API that allows users to upload music files to AWS S3, extract metadata, store it in DynamoDB, and query their library using Gemini AI.

---

## Table of Contents

1. [Authentication](#authentication)
2. [Endpoints](#endpoints)
   - [Health Check](#health-check)
   - [Upload Music File](#upload-music-file)
   - [Get Music Library](#get-music-library)
   - [Get Specific Song](#get-specific-song)
   - [Delete Song](#delete-song)
   - [Download Song](#download-song)
   - [AI Assistant (Gemini)](#ai-assistant-gemini)
3. [Data Models](#data-models)
4. [Error Handling](#error-handling)
5. [Examples](#examples)

---

## Authentication

Currently, the API does not require authentication. All endpoints are publicly accessible.

> **Note for Production:** Implement API key authentication or OAuth before deploying to production.

---

## Endpoints

### Health Check

#### Get Service Status
```
GET /
```

**Description:** Returns basic service information and status.

**Response:**
```json
{
  "service": "Mockingbird API",
  "status": "running",
  "version": "1.0.0"
}
```

**Status Codes:**
- `200 OK` - Service is running

---

#### Health Check
```
GET /health
```

**Description:** Simple health check endpoint.

**Response:**
```json
{
  "status": "healthy"
}
```

**Status Codes:**
- `200 OK` - Service is healthy

---

### Upload Music File

```
POST /upload
```

**Description:** Upload a music file to S3 and extract metadata to DynamoDB.

**Content-Type:** `multipart/form-data`

**Form Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `file` | File | Yes | - | Music file (.mp3, .flac, or .m4a) |
| `bucket_name` | String | No | `mockingbird-storage-kris` | S3 bucket name |
| `file_path` | String | No | `""` (root) | Directory path in S3 bucket |

**Supported File Formats:**
- `.mp3` - MP3 audio files
- `.flac` - FLAC audio files
- `.m4a` - M4A audio files

**Success Response (200 OK):**
```json
{
  "message": "File uploaded successfully",
  "bucket": "mockingbird-storage-kris",
  "key": "rock/2024/song.mp3",
  "metadata": {
    "title": "Song Title",
    "artist": "Artist Name",
    "genre": "Rock",
    "album": "Album Name",
    "year": "2024"
  }
}
```

**Error Responses:**

- `400 Bad Request` - Invalid file format
```json
{
  "detail": "Invalid file format. Only .mp3, .flac, and .m4a are supported."
}
```

- `500 Internal Server Error` - AWS error or processing error
```json
{
  "detail": "AWS error: [error message]"
}
```

**Example (Flutter/Dart):**
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> uploadSong(File file, String filePath) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://your-ec2-ip:8000/upload'),
  );

  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  request.fields['file_path'] = filePath;

  var response = await request.send();
  var responseData = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    print('Upload successful: $responseData');
  } else {
    print('Upload failed: $responseData');
  }
}
```

---

### Get Music Library

```
GET /library
```

**Description:** Retrieve all songs in the library with optional filtering.

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `artist` | String | No | Filter by artist name (case-insensitive) |
| `genre` | String | No | Filter by genre (case-insensitive) |
| `album` | String | No | Filter by album name (case-insensitive) |

**Success Response (200 OK):**
```json
{
  "total": 2,
  "items": [
    {
      "songId": "rock/2024/song1.mp3",
      "bucket": "mockingbird-storage-kris",
      "title": "Song Title 1",
      "artist": "Artist Name",
      "genre": "Rock",
      "album": "Album Name",
      "year": "2024",
      "upload_date": "2025-11-01T12:00:00.000000",
      "file_name": "song1.mp3"
    },
    {
      "songId": "pop/2023/song2.mp3",
      "bucket": "mockingbird-storage-kris",
      "title": "Song Title 2",
      "artist": "Another Artist",
      "genre": "Pop",
      "album": "Another Album",
      "year": "2023",
      "upload_date": "2025-11-01T13:00:00.000000",
      "file_name": "song2.mp3"
    }
  ]
}
```

**Error Response (500 Internal Server Error):**
```json
{
  "detail": "Database error: [error message]"
}
```

**Example (Flutter/Dart):**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getLibrary({String? artist, String? genre, String? album}) async {
  var uri = Uri.parse('http://your-ec2-ip:8000/library');

  Map<String, String> queryParams = {};
  if (artist != null) queryParams['artist'] = artist;
  if (genre != null) queryParams['genre'] = genre;
  if (album != null) queryParams['album'] = album;

  if (queryParams.isNotEmpty) {
    uri = uri.replace(queryParameters: queryParams);
  }

  var response = await http.get(uri);

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['items'];
  } else {
    throw Exception('Failed to load library');
  }
}
```

---

### Get Specific Song

```
GET /library/{song_id}
```

**Description:** Retrieve metadata for a specific song by its ID (S3 key).

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `song_id` | String | Yes | Song ID (S3 object key) - can include slashes for nested paths |

**Success Response (200 OK):**
```json
{
  "songId": "rock/2024/song.mp3",
  "bucket": "mockingbird-storage-kris",
  "title": "Song Title",
  "artist": "Artist Name",
  "genre": "Rock",
  "album": "Album Name",
  "year": "2024",
  "upload_date": "2025-11-01T12:00:00.000000",
  "file_name": "song.mp3"
}
```

**Error Responses:**

- `404 Not Found` - Song not found
```json
{
  "detail": "File not found"
}
```

- `500 Internal Server Error` - Database error
```json
{
  "detail": "Database error: [error message]"
}
```

**Example (Flutter/Dart):**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getSong(String songId) async {
  // URL encode the song ID to handle slashes
  var encodedSongId = Uri.encodeComponent(songId);
  var response = await http.get(
    Uri.parse('http://your-ec2-ip:8000/library/$encodedSongId'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 404) {
    throw Exception('Song not found');
  } else {
    throw Exception('Failed to load song');
  }
}
```

---

### Delete Song

```
DELETE /library/{song_id}
```

**Description:** Delete a song from both S3 and DynamoDB.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `song_id` | String | Yes | Song ID (S3 object key) |

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `bucket_name` | String | No | `mockingbird-storage-kris` | S3 bucket name |

**Success Response (200 OK):**
```json
{
  "message": "File deleted successfully",
  "songId": "rock/2024/song.mp3"
}
```

**Error Response (500 Internal Server Error):**
```json
{
  "detail": "AWS error: [error message]"
}
```

**Example (Flutter/Dart):**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> deleteSong(String songId, {String? bucketName}) async {
  var uri = Uri.parse('http://your-ec2-ip:8000/library/${Uri.encodeComponent(songId)}');

  if (bucketName != null) {
    uri = uri.replace(queryParameters: {'bucket_name': bucketName});
  }

  var response = await http.delete(uri);

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to delete song');
  }
}
```

---

### Download Song

```
GET /download/{song_id}
```

**Description:** Download a music file from S3. Returns the file as a streaming response with proper audio content type.

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `song_id` | String | Yes | Song ID (S3 object key) - can include slashes for nested paths |

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `bucket_name` | String | No | `mockingbird-storage-kris` | S3 bucket name |

**Success Response (200 OK):**

Returns the audio file as a binary stream with appropriate headers:

**Response Headers:**
```
Content-Type: audio/mpeg (or audio/flac, audio/mp4)
Content-Disposition: attachment; filename="song.mp3"
```

**Error Responses:**

- `404 Not Found` - Song not found in library
```json
{
  "detail": "File not found in library"
}
```

- `404 Not Found` - File not found in S3
```json
{
  "detail": "File not found in S3"
}
```

- `500 Internal Server Error` - AWS error
```json
{
  "detail": "AWS error: [error message]"
}
```

**Example (cURL):**
```bash
# Download to current directory
curl -O "http://your-ec2-ip:8000/download/rock%2F2024%2Fsong.mp3"

# Download with custom filename
curl "http://your-ec2-ip:8000/download/rock%2F2024%2Fsong.mp3" -o my_song.mp3

# Download from specific bucket
curl "http://your-ec2-ip:8000/download/song.mp3?bucket_name=my-bucket" -o song.mp3
```

**Example (PowerShell):**
```powershell
# Download a file
Invoke-WebRequest -Uri "http://your-ec2-ip:8000/download/rock%2F2024%2Fsong.mp3" -OutFile "song.mp3"

# Download from specific bucket
Invoke-WebRequest -Uri "http://your-ec2-ip:8000/download/song.mp3?bucket_name=my-bucket" -OutFile "song.mp3"
```

**Example (Flutter/Dart):**
```dart
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> downloadSong(String songId, {String? bucketName}) async {
  var uri = Uri.parse('http://your-ec2-ip:8000/download/${Uri.encodeComponent(songId)}');

  if (bucketName != null) {
    uri = uri.replace(queryParameters: {'bucket_name': bucketName});
  }

  var response = await http.get(uri);

  if (response.statusCode == 200) {
    // Get local directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = songId.split('/').last;
    final file = File('${directory.path}/$fileName');

    // Write bytes to file
    await file.writeAsBytes(response.bodyBytes);
    return file;
  } else if (response.statusCode == 404) {
    throw Exception('Song not found');
  } else {
    throw Exception('Failed to download song');
  }
}

// Example: Download and save with progress tracking
Future<File> downloadSongWithProgress(
  String songId,
  Function(int received, int total) onProgress,
) async {
  var uri = Uri.parse('http://your-ec2-ip:8000/download/${Uri.encodeComponent(songId)}');

  var request = http.Request('GET', uri);
  var streamedResponse = await request.send();

  if (streamedResponse.statusCode == 200) {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = songId.split('/').last;
    final file = File('${directory.path}/$fileName');

    var bytes = <int>[];
    var received = 0;
    var total = streamedResponse.contentLength ?? 0;

    await for (var chunk in streamedResponse.stream) {
      bytes.addAll(chunk);
      received += chunk.length;
      onProgress(received, total);
    }

    await file.writeAsBytes(bytes);
    return file;
  } else {
    throw Exception('Failed to download song');
  }
}
```

**Notes:**
- The endpoint streams the file directly from S3, making it efficient for large files
- Content type is automatically detected based on file extension (.mp3, .flac, .m4a)
- The `Content-Disposition` header includes the original filename
- URL encode the `song_id` if it contains special characters or slashes

---

### AI Assistant (Gemini)

```
POST /prompt
```

**Description:** Query your music library using Gemini AI. The AI has access to all your library data and can answer questions about your music collection.

**Content-Type:** `application/json`

**Request Body:**
```json
{
  "prompt": "What songs do I have from the 1980s?"
}
```

**Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt` | String | Yes | Natural language question about your music library |

**Success Response (200 OK):**
```json
{
  "response": "Based on your music library, you have the following songs from the 1980s:\n\n1. 'Take On Me' by A-ha (1985)\n2. 'Sweet Child O' Mine' by Guns N' Roses (1987)\n\nThese are both classic hits from that era!"
}
```

**Error Responses:**

- `500 Internal Server Error` - Database or AI processing error
```json
{
  "detail": "Error processing Gemini prompt: [error message]"
}
```

**Example Prompts:**
- "What songs do I have in my library?"
- "List all my rock songs"
- "What are my top 5 artists?"
- "Show me songs from the 1980s"
- "What albums do I have by [artist name]?"
- "Recommend a song for a relaxing evening"
- "¿Qué canciones tengo en mi biblioteca?" (Works in multiple languages!)

**Example (Flutter/Dart):**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> askGemini(String prompt) async {
  var response = await http.post(
    Uri.parse('http://your-ec2-ip:8000/prompt'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'prompt': prompt}),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['response'];
  } else {
    throw Exception('Failed to get AI response');
  }
}
```

---

## Data Models

### Song Metadata

```json
{
  "songId": "string",           // S3 object key (primary key)
  "bucket": "string",           // S3 bucket name
  "title": "string",            // Song title (from file metadata or "Unknown")
  "artist": "string",           // Artist name (from file metadata or "Unknown")
  "genre": "string",            // Music genre (from file metadata or "Unknown")
  "album": "string",            // Album name (from file metadata or "Unknown")
  "year": "string",             // Release year (from file metadata or "Unknown")
  "upload_date": "string",      // ISO 8601 timestamp of upload
  "file_name": "string"         // Original filename
}
```

### Upload Request (Form Data)

| Field | Type | Required |
|-------|------|----------|
| file | File | Yes |
| bucket_name | String | No |
| file_path | String | No |

### Prompt Request

```json
{
  "prompt": "string"  // Required: Natural language question
}
```

### Prompt Response

```json
{
  "response": "string"  // AI-generated response
}
```

---

## Error Handling

### Standard Error Response Format

```json
{
  "detail": "Error message description"
}
```

### Common HTTP Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid request parameters or file format |
| 404 | Not Found | Resource not found |
| 500 | Internal Server Error | Server-side error (AWS, Database, or AI processing) |

### Error Types

1. **File Format Error (400)**
   - Occurs when uploading unsupported file types
   - Only .mp3, .flac, and .m4a are supported

2. **AWS Errors (500)**
   - S3 upload/download failures
   - DynamoDB read/write failures
   - Secrets Manager access failures

3. **Not Found (404)**
   - Song with specified ID doesn't exist in database

4. **AI Processing Errors (500)**
   - Gemini API failures
   - Invalid API key
   - Rate limiting

---

## Examples

### Complete Flutter Service Class

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class MockingbirdService {
  final String baseUrl;

  MockingbirdService({required this.baseUrl});

  // Health check
  Future<bool> isHealthy() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Upload song
  Future<Map<String, dynamic>> uploadSong(
    File file,
    {String? filePath, String? bucketName}
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    if (filePath != null) {
      request.fields['file_path'] = filePath;
    }

    if (bucketName != null) {
      request.fields['bucket_name'] = bucketName;
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Upload failed: $responseData');
    }
  }

  // Get all songs
  Future<List<dynamic>> getLibrary({
    String? artist,
    String? genre,
    String? album,
  }) async {
    var uri = Uri.parse('$baseUrl/library');

    Map<String, String> queryParams = {};
    if (artist != null) queryParams['artist'] = artist;
    if (genre != null) queryParams['genre'] = genre;
    if (album != null) queryParams['album'] = album;

    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    var response = await http.get(uri);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to load library');
    }
  }

  // Get specific song
  Future<Map<String, dynamic>> getSong(String songId) async {
    var encodedSongId = Uri.encodeComponent(songId);
    var response = await http.get(
      Uri.parse('$baseUrl/library/$encodedSongId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Song not found');
    } else {
      throw Exception('Failed to load song');
    }
  }

  // Delete song
  Future<bool> deleteSong(String songId, {String? bucketName}) async {
    var uri = Uri.parse('$baseUrl/library/${Uri.encodeComponent(songId)}');

    if (bucketName != null) {
      uri = uri.replace(queryParameters: {'bucket_name': bucketName});
    }

    var response = await http.delete(uri);
    return response.statusCode == 200;
  }

  // Download song
  Future<File> downloadSong(String songId, String savePath, {String? bucketName}) async {
    var uri = Uri.parse('$baseUrl/download/${Uri.encodeComponent(songId)}');

    if (bucketName != null) {
      uri = uri.replace(queryParameters: {'bucket_name': bucketName});
    }

    var response = await http.get(uri);

    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else if (response.statusCode == 404) {
      throw Exception('Song not found');
    } else {
      throw Exception('Failed to download song');
    }
  }

  // Download song with progress tracking
  Future<File> downloadSongWithProgress(
    String songId,
    String savePath,
    Function(int received, int total) onProgress,
    {String? bucketName}
  ) async {
    var uri = Uri.parse('$baseUrl/download/${Uri.encodeComponent(songId)}');

    if (bucketName != null) {
      uri = uri.replace(queryParameters: {'bucket_name': bucketName});
    }

    var request = http.Request('GET', uri);
    var streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      var bytes = <int>[];
      var received = 0;
      var total = streamedResponse.contentLength ?? 0;

      await for (var chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        onProgress(received, total);
      }

      final file = File(savePath);
      await file.writeAsBytes(bytes);
      return file;
    } else if (streamedResponse.statusCode == 404) {
      throw Exception('Song not found');
    } else {
      throw Exception('Failed to download song');
    }
  }

  // Ask Gemini AI
  Future<String> askGemini(String prompt) async {
    var response = await http.post(
      Uri.parse('$baseUrl/prompt'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to get AI response');
    }
  }
}

// Usage example
void main() async {
  var service = MockingbirdService(baseUrl: 'http://your-ec2-ip:8000');

  // Check health
  bool healthy = await service.isHealthy();
  print('Service healthy: $healthy');

  // Upload a song
  var file = File('/path/to/song.mp3');
  var result = await service.uploadSong(file, filePath: 'rock/2024');
  print('Uploaded: ${result['metadata']['title']}');

  // Get all songs
  var songs = await service.getLibrary();
  print('Total songs: ${songs.length}');

  // Filter by genre
  var rockSongs = await service.getLibrary(genre: 'Rock');
  print('Rock songs: ${rockSongs.length}');

  // Download a song
  var downloadedFile = await service.downloadSong(
    'rock/2024/song.mp3',
    '/path/to/save/song.mp3'
  );
  print('Downloaded to: ${downloadedFile.path}');

  // Download with progress tracking
  await service.downloadSongWithProgress(
    'rock/2024/song.mp3',
    '/path/to/save/song.mp3',
    (received, total) {
      var progress = (received / total * 100).toStringAsFixed(1);
      print('Download progress: $progress%');
    }
  );

  // Ask Gemini
  var aiResponse = await service.askGemini('What are my top artists?');
  print('AI says: $aiResponse');

  // Delete a song
  await service.deleteSong('rock/2024/song.mp3');
  print('Song deleted');
}
```

---

## Rate Limits

Currently, there are no rate limits implemented. However, be mindful of:
- **Gemini API limits**: Subject to Google's API quotas
- **S3 operations**: AWS S3 request limits
- **DynamoDB operations**: AWS DynamoDB capacity

---

## Notes for Flutter Development

1. **Add HTTP package to pubspec.yaml:**
```yaml
dependencies:
  http: ^1.1.0
```

2. **Handle network permissions:**
   - **Android:** Add to `AndroidManifest.xml`
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

   - **iOS:** Enable App Transport Security in `Info.plist` (if using HTTP)

3. **Error handling:** Wrap all API calls in try-catch blocks

4. **Loading states:** Show loading indicators during API calls

5. **File picking:** Use `file_picker` package for selecting music files

6. **URL encoding:** Always encode song IDs when they contain special characters or slashes

---

## Support

For issues or questions, please refer to the main README.md or contact the development team.

**API Version:** 1.0.0
**Last Updated:** November 1, 2025
