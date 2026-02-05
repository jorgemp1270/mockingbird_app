class Song {
  final String songId;
  final String bucket;
  final String title;
  final String artist;
  final String genre;
  final String album;
  final String year;
  final String uploadDate;
  final String fileName;

  Song({
    required this.songId,
    required this.bucket,
    required this.title,
    required this.artist,
    required this.genre,
    required this.album,
    required this.year,
    required this.uploadDate,
    required this.fileName,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['songId'] ?? '',
      bucket: json['bucket'] ?? '',
      title: json['title'] ?? 'Unknown',
      artist: json['artist'] ?? 'Unknown',
      genre: json['genre'] ?? 'Unknown',
      album: json['album'] ?? 'Unknown',
      year: json['year'] ?? 'Unknown',
      uploadDate: json['upload_date'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'bucket': bucket,
      'title': title,
      'artist': artist,
      'genre': genre,
      'album': album,
      'year': year,
      'upload_date': uploadDate,
      'file_name': fileName,
    };
  }

  // Get directory path from songId
  String get directoryPath {
    final parts = songId.split('/');
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join('/');
    }
    return '';
  }

  // Check if song is in root directory
  bool get isInRoot {
    return !songId.contains('/');
  }
}

class LibraryItem {
  final String name;
  final bool isDirectory;
  final Song? song;
  final String path;

  LibraryItem({
    required this.name,
    required this.isDirectory,
    this.song,
    required this.path,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
