import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Songs extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get artist => text().nullable();

  TextColumn get originalKey => text().nullable();

  TextColumn get currentKey => text().nullable();

  IntColumn get tempoBpm => integer().nullable();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Sections extends Table {
  TextColumn get id => text()();

  TextColumn get songId =>
      text().references(Songs, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  IntColumn get order => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Lines extends Table {
  TextColumn get id => text()();

  TextColumn get sectionId =>
      text().references(Sections, #id, onDelete: KeyAction.cascade)();

  IntColumn get order => integer()();

  TextColumn get rawText => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/songwriter.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [Songs, Sections, Lines], daos: [SongDao, SectionDao, LineDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  factory AppDatabase.inMemory() => AppDatabase(executor: NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

@DriftAccessor(tables: [Songs])
class SongDao extends DatabaseAccessor<AppDatabase> with _$SongDaoMixin {
  SongDao(AppDatabase db) : super(db);

  Future<Song> createSong(SongsCompanion entry) {
    return into(songs).insertReturning(entry);
  }

  Future<Song?> findById(String id) {
    return (select(songs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Song>> watchAll() {
    return select(songs).watch();
  }

  Stream<Song?> watchById(String id) {
    return (select(songs)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<bool> updateSong(Song song) {
    return update(songs).replace(song);
  }

  Future<int> deleteSong(String id) {
    return (delete(songs)..where((tbl) => tbl.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [Sections])
class SectionDao extends DatabaseAccessor<AppDatabase> with _$SectionDaoMixin {
  SectionDao(AppDatabase db) : super(db);

  Future<Section> createSection(SectionsCompanion entry) {
    return into(sections).insertReturning(entry);
  }

  Future<Section?> findById(String id) {
    return (select(sections)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Section>> watchForSong(String songId) {
    return (select(sections)..where((tbl) => tbl.songId.equals(songId))).watch();
  }

  Stream<Section?> watchById(String id) {
    return (select(sections)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<bool> updateSection(Section section) {
    return update(sections).replace(section);
  }

  Future<int> deleteSection(String id) {
    return (delete(sections)..where((tbl) => tbl.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [Lines])
class LineDao extends DatabaseAccessor<AppDatabase> with _$LineDaoMixin {
  LineDao(AppDatabase db) : super(db);

  Future<Line> createLine(LinesCompanion entry) {
    return into(lines).insertReturning(entry);
  }

  Future<Line?> findById(String id) {
    return (select(lines)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Line>> watchForSection(String sectionId) {
    return (select(lines)..where((tbl) => tbl.sectionId.equals(sectionId))).watch();
  }

  Stream<Line?> watchById(String id) {
    return (select(lines)..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<bool> updateLine(Line line) {
    return update(lines).replace(line);
  }

  Future<int> deleteLine(String id) {
    return (delete(lines)..where((tbl) => tbl.id.equals(id))).go();
  }
}
