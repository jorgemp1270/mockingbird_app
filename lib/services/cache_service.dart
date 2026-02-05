import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _downloadedSongsKey = 'downloaded_songs';

  // Get cache directory
  Future<Directory> getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'music_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  // Get file path for a song
  Future<String> getSongFilePath(String songId) async {
    final cacheDir = await getCacheDirectory();
    final fileName = songId.replaceAll('/', '_');
    return path.join(cacheDir.path, fileName);
  }

  // Check if song is downloaded
  Future<bool> isSongDownloaded(String songId) async {
    final filePath = await getSongFilePath(songId);
    final file = File(filePath);
    return await file.exists();
  }

  // Get downloaded song file
  Future<File?> getDownloadedSong(String songId) async {
    final filePath = await getSongFilePath(songId);
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  // Mark song as downloaded
  Future<void> markAsDownloaded(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> downloadedSongs =
        prefs.getStringList(_downloadedSongsKey) ?? [];
    if (!downloadedSongs.contains(songId)) {
      downloadedSongs.add(songId);
      await prefs.setStringList(_downloadedSongsKey, downloadedSongs);
    }
  }

  // Remove downloaded song
  Future<void> removeDownloadedSong(String songId) async {
    final filePath = await getSongFilePath(songId);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    List<String> downloadedSongs =
        prefs.getStringList(_downloadedSongsKey) ?? [];
    downloadedSongs.remove(songId);
    await prefs.setStringList(_downloadedSongsKey, downloadedSongs);
  }

  // Get all downloaded song IDs
  Future<List<String>> getDownloadedSongIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_downloadedSongsKey) ?? [];
  }

  // Clear all cache
  Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      await cacheDir.create();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_downloadedSongsKey);
  }
}
