import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/song.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/player_state.dart';

class LibraryPage extends StatefulWidget {
  final MockingbirdService apiService;
  final String currentPath;
  final String displayName;

  const LibraryPage({
    super.key,
    required this.apiService,
    this.currentPath = '',
    this.displayName = 'Biblioteca',
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final CacheService _cacheService = CacheService();

  List<LibraryItem> _items = [];
  bool _isLoading = true;
  String? _error;
  bool _isUploading = false;

  // Track download progress for each song
  final Map<String, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final songs = await widget.apiService.getLibrary();
      final items = await _organizeLibrary(songs);

      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<LibraryItem>> _organizeLibrary(List<Song> allSongs) async {
    final items = <LibraryItem>[];
    final directories = <String>{};
    final songsInCurrentDir = <Song>[];

    for (var song in allSongs) {
      final songPath = song.songId;

      // Check if song is in current directory or subdirectory
      if (widget.currentPath.isEmpty) {
        // Root directory
        if (song.isInRoot) {
          songsInCurrentDir.add(song);
        } else {
          // Extract first directory
          final firstDir = songPath.split('/')[0];
          directories.add(firstDir);
        }
      } else {
        // Inside a directory
        if (songPath.startsWith('${widget.currentPath}/')) {
          final relativePath = songPath.substring(
            widget.currentPath.length + 1,
          );
          if (!relativePath.contains('/')) {
            // Song is directly in this directory
            songsInCurrentDir.add(song);
          } else {
            // Song is in a subdirectory
            final subDir = relativePath.split('/')[0];
            directories.add(subDir);
          }
        }
      }
    }

    // Add directories first
    for (var dir in directories.toList()..sort()) {
      final dirPath =
          widget.currentPath.isEmpty ? dir : '${widget.currentPath}/$dir';
      items.add(LibraryItem(name: dir, isDirectory: true, path: dirPath));
    }

    // Add songs
    songsInCurrentDir.sort((a, b) => a.fileName.compareTo(b.fileName));
    for (var song in songsInCurrentDir) {
      items.add(
        LibraryItem(
          name: song.fileName,
          isDirectory: false,
          song: song,
          path: song.songId,
        ),
      );
    }

    return items;
  }

  Future<void> _uploadFile() async {
    try {
      // Ask user for directory path
      final directoryController = TextEditingController(
        text: widget.currentPath,
      );
      final confirmedPath = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder:
            (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Subir Archivo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Ruta del directorio (opcional):'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: directoryController,
                          decoration: const InputDecoration(
                            hintText: 'ej: rock/2024',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Deja vacío para subir a la raíz',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed:
                                  () => Navigator.pop(
                                    context,
                                    directoryController.text.trim(),
                                  ),
                              child: const Text('Continuar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      );

      if (confirmedPath == null) return;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'flac'],
      );

      if (result != null) {
        setState(() {
          _isUploading = true;
        });

        File file = File(result.files.single.path!);

        await widget.apiService.uploadSong(
          file,
          filePath: confirmedPath.isEmpty ? null : confirmedPath,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Archivo subido exitosamente')),
          );
          _loadLibrary();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _downloadSong(Song song) async {
    try {
      // Initialize progress to 0
      setState(() {
        _downloadProgress[song.songId] = 0.0;
      });

      final filePath = await _cacheService.getSongFilePath(song.songId);
      await widget.apiService.downloadSong(
        song.songId,
        filePath,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress[song.songId] = received / total;
            });
          }
        },
      );
      await _cacheService.markAsDownloaded(song.songId);

      if (mounted) {
        // Remove progress indicator
        setState(() {
          _downloadProgress.remove(song.songId);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${song.fileName} descargado')));
      }
    } catch (e) {
      if (mounted) {
        // Remove progress indicator on error
        setState(() {
          _downloadProgress.remove(song.songId);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al descargar: $e')));
      }
    }
  }

  Future<void> _playSong(Song song) async {
    try {
      final playerState = Provider.of<PlayerState>(context, listen: false);
      await playerState.playSong(song);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de reproducción: $e')));
      }
    }
  }

  Future<void> _deleteSong(Song song) async {
    // Check if song is downloaded
    final isDownloaded = await _cacheService.isSongDownloaded(song.songId);

    final deleteOption = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Eliminar Canción',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¿Cómo quieres eliminar "${song.fileName}"?',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (isDownloaded) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () => Navigator.pop(context, 'local'),
                          child: const Text('Solo del almacenamiento interno'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, 'cloud'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          isDownloaded
                              ? 'Del almacenamiento interno y la nube'
                              : 'De la nube',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
    );

    if (deleteOption == 'local') {
      // Delete only from local storage
      try {
        await _cacheService.removeDownloadedSong(song.songId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${song.fileName} eliminado del almacenamiento interno',
              ),
            ),
          );
          _loadLibrary();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar del almacenamiento interno: $e'),
            ),
          );
        }
      }
    } else if (deleteOption == 'cloud') {
      // Delete from cloud (and local if downloaded)
      try {
        await widget.apiService.deleteSong(song.songId);
        await _cacheService.removeDownloadedSong(song.songId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${song.fileName} eliminado de la nube')),
          );
          _loadLibrary();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName, style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadFile,
        child:
            _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLibrary,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay archivos de música', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Presiona el botón de subir para agregar música'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLibrary,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return item.isDirectory
              ? _buildDirectoryItem(item)
              : _buildSongItem(item);
        },
      ),
    );
  }

  Widget _buildDirectoryItem(LibraryItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.6),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          Icons.folder,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => LibraryPage(
                    apiService: widget.apiService,
                    currentPath: item.path,
                    displayName: item.name,
                  ),
            ),
          ).then((_) => _loadLibrary());
        },
      ),
    );
  }

  Widget _buildSongItem(LibraryItem item) {
    final song = item.song!;

    return Consumer<PlayerState>(
      builder: (context, playerState, child) {
        return FutureBuilder<bool>(
          future: _cacheService.isSongDownloaded(song.songId),
          builder: (context, snapshot) {
            final isDownloaded = snapshot.data ?? false;
            final isPlaying = playerState.isPlayingSong(song.songId);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
              elevation: 1,
              child: ListTile(
                leading: Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 28,
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                subtitle: Text(
                  '${song.artist} • ${song.album}',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delete button (moved first)
                    InkWell(
                      onTap: () => _deleteSong(song),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Download or Play button
                    if (!isDownloaded &&
                        !_downloadProgress.containsKey(song.songId))
                      InkWell(
                        onTap: () => _downloadSong(song),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.download,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    // Download progress indicator
                    if (_downloadProgress.containsKey(song.songId))
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: _downloadProgress[song.songId],
                          strokeWidth: 3,
                          color: Colors.blue,
                          backgroundColor: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                    if (isDownloaded)
                      InkWell(
                        onTap: () => _playSong(song),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
