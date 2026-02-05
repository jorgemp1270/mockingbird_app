import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import '../models/song.dart';
import '../services/music_player_service.dart';
import '../services/cache_service.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:audiotags/audiotags.dart';

class PlayerState extends ChangeNotifier {
  final MusicPlayerService _playerService = MusicPlayerService();
  final CacheService _cacheService = CacheService();

  Song? _currentlyPlayingSong;
  Uint8List? _currentAlbumArt;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Song? get currentlyPlayingSong => _currentlyPlayingSong;
  Uint8List? get currentAlbumArt => _currentAlbumArt;
  MusicPlayerService get playerService => _playerService;
  CacheService get cacheService => _cacheService;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  PlayerState() {
    _setupPlayerListener();
    _setupPositionListener();
    _setupDurationListener();
  }

  void _setupPlayerListener() {
    _playerService.onPlayerStateChanged.listen((state) {
      // Clear currently playing when stopped or completed
      if (state == ap.PlayerState.stopped ||
          state == ap.PlayerState.completed) {
        _currentlyPlayingSong = null;
        _currentAlbumArt = null;
        _currentPosition = Duration.zero;
        _totalDuration = Duration.zero;
      }
      notifyListeners();
    });
  }

  void _setupPositionListener() {
    _playerService.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
  }

  void _setupDurationListener() {
    _playerService.onDurationChanged.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });
  }

  Future<void> playSong(Song song) async {
    try {
      final file = await _cacheService.getDownloadedSong(song.songId);
      if (file != null) {
        if (_playerService.isPlayingSong(song.songId)) {
          // Pause the currently playing song
          await _playerService.pause();
          // Keep the song info visible
          notifyListeners();
        } else if (_currentlyPlayingSong?.songId == song.songId) {
          // Resume the paused song
          await _playerService.resume();
          notifyListeners();
        } else {
          // Play a new song
          await _playerService.play(song.songId, file);
          _currentlyPlayingSong = song;
          await _loadAlbumArt(file);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadAlbumArt(File audioFile) async {
    try {
      final tag = await AudioTags.read(audioFile.path);
      if (tag?.pictures != null && tag!.pictures.isNotEmpty) {
        _currentAlbumArt = tag.pictures.first.bytes;
      } else {
        _currentAlbumArt = null;
      }
      notifyListeners();
    } catch (e) {
      _currentAlbumArt = null;
      notifyListeners();
    }
  }

  bool isPlayingSong(String songId) {
    return _playerService.isPlayingSong(songId);
  }

  Future<void> seekTo(Duration position) async {
    await _playerService.seek(position);
  }
}
