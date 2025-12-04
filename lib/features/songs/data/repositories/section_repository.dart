import 'package:songwriter/core/database/app_database.dart';

class SectionRepository {
  SectionRepository(this._sectionDao);

  final SectionDao _sectionDao;

  Future<Section> createSection(SectionsCompanion entry) {
    return _sectionDao.createSection(entry);
  }

  Future<Section?> getSectionById(String id) {
    return _sectionDao.findById(id);
  }

  Stream<List<Section>> watchSectionsForSong(String songId) {
    return _sectionDao.watchForSong(songId);
  }

  Future<List<Section>> getSectionsForSong(String songId) {
    return _sectionDao.getForSong(songId);
  }

  Stream<Section?> watchSectionById(String id) {
    return _sectionDao.watchById(id);
  }

  Future<bool> updateSection(Section section) {
    return _sectionDao.updateSection(section);
  }

  Future<int> deleteSection(String id) {
    return _sectionDao.deleteSection(id);
  }
}
