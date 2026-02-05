import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class MusicPlayerService {
  static final MusicPlayerService _instance = MusicPlayerService._internal();
  factory MusicPlayerService() => _instance;
  MusicPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSongId;
  bool _isPlaying = false;

  String? get currentSongId => _currentSongId;
  bool get isPlaying => _isPlaying;

  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration?> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<PlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  Future<void> play(String songId, File audioFile) async {
    try {
      if (_currentSongId == songId && _isPlaying) {
        return;
      }

      if (_currentSongId != songId) {
        await _audioPlayer.stop();
        _currentSongId = songId;
      }

      await _audioPlayer.play(DeviceFileSource(audioFile.path));
      _isPlaying = true;
    } catch (e) {
      // Error playing audio - rethrow as exception for caller to handle
      throw Exception('Failed to play audio: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentSongId = null;
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  bool isPlayingSong(String songId) {
    return _currentSongId == songId && _isPlaying;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
