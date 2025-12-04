import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:songwriter/core/database/app_database.dart';
import 'package:songwriter/features/songs/data/repositories/line_repository.dart';
import 'package:songwriter/features/songs/data/repositories/section_repository.dart';
import 'package:songwriter/features/songs/data/repositories/song_repository.dart';
import 'package:songwriter/features/songs/data/song_json_service.dart';

void main() {
  late AppDatabase db;
  late SongRepository songRepository;
  late SectionRepository sectionRepository;
  late LineRepository lineRepository;
  late SongJsonService service;

  setUp(() {
    db = AppDatabase.inMemory();
    songRepository = SongRepository(SongDao(db));
    sectionRepository = SectionRepository(SectionDao(db));
    lineRepository = LineRepository(LineDao(db));
    service = SongJsonService(
      songRepository,
      sectionRepository,
      lineRepository,
      const Uuid(),
    );
  });

  tearDown(() => db.close());

  test('exportSongAsMap preserves sections and lines with chords', () async {
    final song = await songRepository.createSong(
      SongsCompanion.insert(
        id: 'song-1',
        title: 'Canción prueba',
        artist: const Value('Artista X'),
        originalKey: const Value('C'),
        tempoBpm: const Value(120),
      ),
    );

    final section = await sectionRepository.createSection(
      SectionsCompanion.insert(
        id: 'section-1',
        songId: song.id,
        name: 'Verso',
        order: 0,
      ),
    );

    await lineRepository.createLine(
      LinesCompanion.insert(
        id: 'line-1',
        sectionId: section.id,
        order: 0,
        rawText: '[C]Hola [G]mundo',
      ),
    );
    await lineRepository.createLine(
      LinesCompanion.insert(
        id: 'line-2',
        sectionId: section.id,
        order: 1,
        rawText: 'Otra [Am]línea con [F]acordes',
      ),
    );

    final map = await service.exportSongAsMap(song.id);

    expect(map['title'], 'Canción prueba');
    final sections = map['sections'] as List<dynamic>;
    expect(sections, hasLength(1));
    final lines = (sections.first as Map<String, dynamic>)['lines'] as List<dynamic>;
    expect(lines, hasLength(2));
    expect((lines.first as Map<String, dynamic>)['rawText'], '[C]Hola [G]mundo');
    expect((lines[1] as Map<String, dynamic>)['rawText'],
        'Otra [Am]línea con [F]acordes');
  });

  test('export and import keep chords, sections and lines intact', () async {
    final song = await songRepository.createSong(
      SongsCompanion.insert(
        id: 'song-2',
        title: 'Canción exportable',
        artist: const Value('Duo Y'),
        originalKey: const Value('G'),
        tempoBpm: const Value(90),
      ),
    );

    final intro = await sectionRepository.createSection(
      SectionsCompanion.insert(
        id: 'section-intro',
        songId: song.id,
        name: 'Intro',
        order: 0,
      ),
    );

    final chorus = await sectionRepository.createSection(
      SectionsCompanion.insert(
        id: 'section-chorus',
        songId: song.id,
        name: 'Coro',
        order: 1,
      ),
    );

    await lineRepository.createLine(
      LinesCompanion.insert(
        id: 'line-intro-1',
        sectionId: intro.id,
        order: 0,
        rawText: '[G]Se abre el [D]cielo',
      ),
    );
    await lineRepository.createLine(
      LinesCompanion.insert(
        id: 'line-chorus-1',
        sectionId: chorus.id,
        order: 0,
        rawText: '[Em]Ven y [C]canta',
      ),
    );

    final tempDir = await Directory.systemTemp.createTemp('songwriter_export_test');
    final file = await service.exportSongToFile(song.id, targetDirectory: tempDir);

    final importedSong = await service.importSongFromFile(file);

    final importedSections =
        await sectionRepository.getSectionsForSong(importedSong.id);
    expect(importedSections, hasLength(2));
    importedSections.sort((a, b) => a.order.compareTo(b.order));

    expect(importedSections.first.name, 'Intro');
    expect(importedSections.last.name, 'Coro');

    final introLines =
        await lineRepository.getLinesForSection(importedSections.first.id);
    final chorusLines =
        await lineRepository.getLinesForSection(importedSections.last.id);

    expect(introLines.single.rawText, '[G]Se abre el [D]cielo');
    expect(chorusLines.single.rawText, '[Em]Ven y [C]canta');
  });
}
