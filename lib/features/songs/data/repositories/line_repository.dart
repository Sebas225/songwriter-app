import 'package:songwriter/core/database/app_database.dart';

class LineRepository {
  LineRepository(this._lineDao);

  final LineDao _lineDao;

  Future<Line> createLine(LinesCompanion entry) {
    return _lineDao.createLine(entry);
  }

  Future<Line?> getLineById(String id) {
    return _lineDao.findById(id);
  }

  Stream<List<Line>> watchLinesForSection(String sectionId) {
    return _lineDao.watchForSection(sectionId);
  }

  Future<List<Line>> getLinesForSection(String sectionId) {
    return _lineDao.getForSection(sectionId);
  }

  Stream<Line?> watchLineById(String id) {
    return _lineDao.watchById(id);
  }

  Future<bool> updateLine(Line line) {
    return _lineDao.updateLine(line);
  }

  Future<int> deleteLine(String id) {
    return _lineDao.deleteLine(id);
  }
}
