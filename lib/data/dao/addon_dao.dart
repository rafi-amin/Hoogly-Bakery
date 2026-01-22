import '../../core/database/app_database.dart';
import '../models/addon_model.dart';

class AddonDao {
  AddonDao(this._db);

  final AppDatabase _db;

  Future<int> insert(AddonModel addon) async {
    final db = await _db.database;
    return db.insert('addons', addon.toMap());
  }

  Future<AddonModel?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'addons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AddonModel.fromMap(rows.first);
  }

  Future<List<AddonModel>> getActiveAddons() async {
    final db = await _db.database;
    final rows = await db.query(
      'addons',
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );
    return rows.map(AddonModel.fromMap).toList();
  }

  Future<List<AddonModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('addons', orderBy: 'name ASC');
    return rows.map(AddonModel.fromMap).toList();
  }

  Future<int> update(AddonModel addon) async {
    final db = await _db.database;
    return db.update(
      'addons',
      addon.toMap(),
      where: 'id = ?',
      whereArgs: [addon.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('addons', where: 'id = ?', whereArgs: [id]);
  }
}

