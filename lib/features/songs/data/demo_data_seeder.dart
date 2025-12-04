import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import 'repositories/line_repository.dart';
import 'repositories/section_repository.dart';
import 'repositories/song_repository.dart';

class DemoDataSeeder {
  DemoDataSeeder(
    this._songRepository,
    this._sectionRepository,
    this._lineRepository,
    this._uuid,
  );

  final SongRepository _songRepository;
  final SectionRepository _sectionRepository;
  final LineRepository _lineRepository;
  final Uuid _uuid;

  Future<void>? _pending;

  Future<void> seedIfEmpty() {
    return _pending ??= _seedInternal();
  }

  Future<void> _seedInternal() async {
    final existing = await _songRepository.watchSongs().first;
    if (existing.isNotEmpty) return;

    final content = await rootBundle.loadString('demo/sample_songs.json');
    final data = jsonDecode(content) as List<dynamic>;

    for (final entry in data) {
      final songData = entry as Map<String, dynamic>;
      final songId = _uuid.v4();

      final song = await _songRepository.createSong(
        SongsCompanion(
          id: Value(songId),
          title: Value(songData['title'] as String),
          artist: Value(songData['artist'] as String?),
          originalKey: Value(songData['originalKey'] as String?),
          currentKey: Value(songData['currentKey'] as String?),
          tempoBpm: Value(songData['tempoBpm'] as int?),
        ),
      );

      final sections = songData['sections'] as List<dynamic>? ?? [];
      for (var i = 0; i < sections.length; i++) {
        final sectionData = sections[i] as Map<String, dynamic>;
        final sectionId = _uuid.v4();

        await _sectionRepository.createSection(
          SectionsCompanion(
            id: Value(sectionId),
            songId: Value(song.id),
            name: Value(sectionData['name'] as String),
            order: Value(i),
          ),
        );

        final lines = sectionData['lines'] as List<dynamic>? ?? [];
        for (var j = 0; j < lines.length; j++) {
          await _lineRepository.createLine(
            LinesCompanion(
              id: Value(_uuid.v4()),
              sectionId: Value(sectionId),
              order: Value(j),
              rawText: Value(lines[j] as String),
            ),
          );
        }
      }
    }
  }
}
