import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/song.dart';

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
    File file, {
    String? filePath,
    String? bucketName,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    if (filePath != null && filePath.isNotEmpty) {
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
  Future<List<Song>> getLibrary({
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
      List<dynamic> items = data['items'];
      return items.map((item) => Song.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load library');
    }
  }

  // Get specific song
  Future<Song> getSong(String songId) async {
    var encodedSongId = Uri.encodeComponent(songId);
    var response = await http.get(Uri.parse('$baseUrl/library/$encodedSongId'));

    if (response.statusCode == 200) {
      return Song.fromJson(json.decode(response.body));
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
  Future<File> downloadSong(
    String songId,
    String savePath, {
    String? bucketName,
    Function(int received, int total)? onProgress,
  }) async {
    var uri = Uri.parse('$baseUrl/download/${Uri.encodeComponent(songId)}');

    if (bucketName != null) {
      uri = uri.replace(queryParameters: {'bucket_name': bucketName});
    }

    if (onProgress != null) {
      // Download with progress tracking
      var request = http.Request('GET', uri);
      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        final file = File(savePath);
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
        throw Exception('Download failed');
      }
    } else {
      // Simple download
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else if (response.statusCode == 404) {
        throw Exception('Song not found');
      } else {
        throw Exception('Download failed');
      }
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
