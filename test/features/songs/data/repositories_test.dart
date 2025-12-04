import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songwriter/core/database/app_database.dart';
import 'package:songwriter/features/songs/data/repositories/line_repository.dart';
import 'package:songwriter/features/songs/data/repositories/section_repository.dart';
import 'package:songwriter/features/songs/data/repositories/song_repository.dart';

void main() {
  late AppDatabase db;
  late SongRepository songRepository;
  late SectionRepository sectionRepository;
  late LineRepository lineRepository;

  setUp(() {
    db = AppDatabase.inMemory();
    songRepository = SongRepository(db.songDao);
    sectionRepository = SectionRepository(db.sectionDao);
    lineRepository = LineRepository(db.lineDao);
  });

  tearDown(() async {
    await db.close();
  });

  test('creates and retrieves song with updates', () async {
    final created = await songRepository.createSong(
      SongsCompanion.insert(
        id: 'song-1',
        title: 'My Song',
        artist: const Value('Artist'),
        tempoBpm: const Value(120),
      ),
    );

    expect(created.title, 'My Song');

    final fetched = await songRepository.getSongById('song-1');
    expect(fetched?.artist, 'Artist');

    final updatedSong = created.copyWith(title: 'Updated Song');
    final updated = await songRepository.updateSong(updatedSong);
    expect(updated, isTrue);

    final result = await songRepository.getSongById('song-1');
    expect(result?.title, 'Updated Song');
  });

  test('streams songs, sections and lines reactively', () async {
    final songsStream = songRepository.watchSongs();
    final sectionsStream = sectionRepository.watchSectionsForSong('song-1');
    final linesStream = lineRepository.watchLinesForSection('section-1');

    final songsExpect = expectLater(
      songsStream,
      emitsInOrder([
        isEmpty,
        hasLength(1),
      ]),
    );

    final sectionsExpect = expectLater(
      sectionsStream,
      emitsInOrder([
        isEmpty,
        hasLength(1),
      ]),
    );

    final linesExpect = expectLater(
      linesStream,
      emitsInOrder([
        isEmpty,
        hasLength(1),
      ]),
    );

    await songRepository.createSong(
      SongsCompanion.insert(
        id: 'song-1',
        title: 'Stream Song',
      ),
    );

    await sectionRepository.createSection(
      SectionsCompanion.insert(
        id: 'section-1',
        songId: 'song-1',
        name: 'Verse',
        order: 0,
      ),
    );

    await lineRepository.createLine(
      LinesCompanion.insert(
        id: 'line-1',
        sectionId: 'section-1',
        order: 0,
        rawText: 'Hello [C]World',
      ),
    );

    await songsExpect;
    await sectionsExpect;
    await linesExpect;
  });

  test('cascades deletes from song to sections and lines', () async {
    await songRepository.createSong(
      SongsCompanion.insert(id: 'song-1', title: 'Cascade Song'),
    );

    await sectionRepository.createSection(
      SectionsCompanion.insert(
        id: 'section-1',
        songId: 'song-1',
        name: 'Chorus',
        order: 0,
      ),
    );

    await lineRepository.createLine(
      LinesCompanion.insert(
        id: 'line-1',
        sectionId: 'section-1',
        order: 0,
        rawText: 'Line content',
      ),
    );

    await songRepository.deleteSong('song-1');

    final section = await sectionRepository.getSectionById('section-1');
    final line = await lineRepository.getLineById('line-1');

    expect(section, isNull);
    expect(line, isNull);
  });
}
