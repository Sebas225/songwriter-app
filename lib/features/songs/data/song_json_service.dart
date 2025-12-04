import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import 'repositories/line_repository.dart';
import 'repositories/section_repository.dart';
import 'repositories/song_repository.dart';

class SongJsonService {
  SongJsonService(
    this._songRepository,
    this._sectionRepository,
    this._lineRepository,
    this._uuid,
  );

  final SongRepository _songRepository;
  final SectionRepository _sectionRepository;
  final LineRepository _lineRepository;
  final Uuid _uuid;

  Future<Map<String, dynamic>> exportSongAsMap(String songId) async {
    final song = await _songRepository.getSongById(songId);
    if (song == null) {
      throw ArgumentError('Canción no encontrada');
    }

    final sections = await _sectionRepository.getSectionsForSong(songId);
    final linesBySection = <String, List<Line>>{};
    for (final section in sections) {
      linesBySection[section.id] =
          await _lineRepository.getLinesForSection(section.id);
    }

    return {
      'id': song.id,
      'title': song.title,
      'artist': song.artist,
      'originalKey': song.originalKey,
      'currentKey': song.currentKey,
      'tempoBpm': song.tempoBpm,
      'createdAt': song.createdAt.toIso8601String(),
      'updatedAt': song.updatedAt.toIso8601String(),
      'sections': sections
          .map(
            (section) => {
              'id': section.id,
              'name': section.name,
              'order': section.order,
              'lines': (linesBySection[section.id] ?? [])
                  .map(
                    (line) => {
                      'id': line.id,
                      'order': line.order,
                      'rawText': line.rawText,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }

  Future<File> exportSongToFile(
    String songId, {
    Directory? targetDirectory,
  }) async {
    final map = await exportSongAsMap(songId);
    final directory =
        targetDirectory ?? await getApplicationDocumentsDirectory();
    final sanitizedTitle = map['title']
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp('_+'), '_')
        .trim();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = sanitizedTitle.isEmpty
        ? 'song_$timestamp.json'
        : '${sanitizedTitle}_$timestamp.json';
    final file = File('${directory.path}/$filename');

    final encoder = const JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(map));
    return file;
  }

  Future<Song> importSongFromFile(File file) async {
    final content = await file.readAsString();
    return importSongFromJson(content);
  }

  Future<Song> importSongFromJson(String jsonContent) async {
    final decoded = jsonDecode(jsonContent);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Formato de canción inválido');
    }

    final now = DateTime.now();
    final songId = _uuid.v4();
    final sections = decoded['sections'] as List<dynamic>? ?? [];

    final song = await _songRepository.createSong(
      SongsCompanion(
        id: Value(songId),
        title: Value(_readString(decoded, 'title') ?? 'Canción importada'),
        artist: Value(_readString(decoded, 'artist')),
        originalKey: Value(_readString(decoded, 'originalKey')),
        currentKey: Value(_readString(decoded, 'currentKey')),
        tempoBpm: Value(_readInt(decoded, 'tempoBpm')),
        createdAt: Value(_readDate(decoded, 'createdAt') ?? now),
        updatedAt: Value(_readDate(decoded, 'updatedAt') ?? now),
      ),
    );

    for (var i = 0; i < sections.length; i++) {
      final rawSection = sections[i];
      if (rawSection is! Map<String, dynamic>) continue;

      final sectionId = _uuid.v4();
      final lines = rawSection['lines'] as List<dynamic>? ?? [];

      await _sectionRepository.createSection(
        SectionsCompanion(
          id: Value(sectionId),
          songId: Value(song.id),
          name: Value(_readString(rawSection, 'name') ?? 'Sección ${i + 1}'),
          order: Value(_readInt(rawSection, 'order') ?? i),
        ),
      );

      for (var j = 0; j < lines.length; j++) {
        final rawLine = lines[j];
        if (rawLine is! Map<String, dynamic>) continue;

        await _lineRepository.createLine(
          LinesCompanion(
            id: Value(_uuid.v4()),
            sectionId: Value(sectionId),
            order: Value(_readInt(rawLine, 'order') ?? j),
            rawText: Value(_readString(rawLine, 'rawText') ?? ''),
          ),
        );
      }
    }

    return song;
  }

  String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is String ? value : null;
  }

  int? _readInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  DateTime? _readDate(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
