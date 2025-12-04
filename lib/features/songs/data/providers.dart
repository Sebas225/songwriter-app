import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import 'demo_data_seeder.dart';
import 'repositories/line_repository.dart';
import 'repositories/section_repository.dart';
import 'repositories/song_repository.dart';
import 'song_json_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final songDaoProvider = Provider<SongDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SongDao(db);
});

final sectionDaoProvider = Provider<SectionDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SectionDao(db);
});

final lineDaoProvider = Provider<LineDao>((ref) {
  final db = ref.watch(databaseProvider);
  return LineDao(db);
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  final dao = ref.watch(songDaoProvider);
  return SongRepository(dao);
});

final sectionRepositoryProvider = Provider<SectionRepository>((ref) {
  final dao = ref.watch(sectionDaoProvider);
  return SectionRepository(dao);
});

final lineRepositoryProvider = Provider<LineRepository>((ref) {
  final dao = ref.watch(lineDaoProvider);
  return LineRepository(dao);
});

final demoDataSeederProvider = Provider<DemoDataSeeder>((ref) {
  final songRepository = ref.watch(songRepositoryProvider);
  final sectionRepository = ref.watch(sectionRepositoryProvider);
  final lineRepository = ref.watch(lineRepositoryProvider);
  final uuid = ref.watch(uuidProvider);
  return DemoDataSeeder(
    songRepository,
    sectionRepository,
    lineRepository,
    uuid,
  );
});

final demoDataInitializerProvider = FutureProvider<void>((ref) {
  final seeder = ref.watch(demoDataSeederProvider);
  return seeder.seedIfEmpty();
});

final songJsonServiceProvider = Provider<SongJsonService>((ref) {
  final songRepository = ref.watch(songRepositoryProvider);
  final sectionRepository = ref.watch(sectionRepositoryProvider);
  final lineRepository = ref.watch(lineRepositoryProvider);
  final uuid = ref.watch(uuidProvider);
  return SongJsonService(
    songRepository,
    sectionRepository,
    lineRepository,
    uuid,
  );
});

final songsProvider = StreamProvider<List<Song>>((ref) {
  ref.watch(demoDataInitializerProvider);
  final repository = ref.watch(songRepositoryProvider);
  return repository.watchSongs();
});

final songProvider = StreamProvider.family<Song?, String>((ref, id) {
  ref.watch(demoDataInitializerProvider);
  final repository = ref.watch(songRepositoryProvider);
  return repository.watchSongById(id);
});

final sectionsForSongProvider =
    StreamProvider.family<List<Section>, String>((ref, songId) {
  ref.watch(demoDataInitializerProvider);
  final repository = ref.watch(sectionRepositoryProvider);
  return repository.watchSectionsForSong(songId);
});

final sectionProvider = StreamProvider.family<Section?, String>((ref, id) {
  ref.watch(demoDataInitializerProvider);
  final repository = ref.watch(sectionRepositoryProvider);
  return repository.watchSectionById(id);
});

final linesForSectionProvider =
    StreamProvider.family<List<Line>, String>((ref, sectionId) {
  ref.watch(demoDataInitializerProvider);
  final repository = ref.watch(lineRepositoryProvider);
  return repository.watchLinesForSection(sectionId);
});

