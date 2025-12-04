import 'package:songwriter/core/database/app_database.dart';

class SongRepository {
  SongRepository(this._songDao);

  final SongDao _songDao;

  Future<Song> createSong(SongsCompanion entry) {
    return _songDao.createSong(entry);
  }

  Future<Song?> getSongById(String id) {
    return _songDao.findById(id);
  }

  Stream<List<Song>> watchSongs() {
    return _songDao.watchAll();
  }

  Stream<Song?> watchSongById(String id) {
    return _songDao.watchById(id);
  }

  Future<bool> updateSong(Song song) {
    return _songDao.updateSong(song);
  }

  Future<int> deleteSong(String id) {
    return _songDao.deleteSong(id);
  }
}
