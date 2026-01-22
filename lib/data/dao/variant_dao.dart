import '../../core/database/app_database.dart';
import '../models/variant_model.dart';

class VariantDao {
  VariantDao(this._db);

  final AppDatabase _db;

  Future<int> insert(VariantModel variant) async {
    final db = await _db.database;
    return db.insert('product_variants', variant.toMap());
  }

  Future<VariantModel?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'product_variants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return VariantModel.fromMap(rows.first);
  }

  Future<List<VariantModel>> getVariantsForProduct(int productId) async {
    final db = await _db.database;
    final rows = await db.query(
      'product_variants',
      where: 'product_id = ? AND is_active = 1',
      whereArgs: [productId],
      orderBy: 'name ASC',
    );
    return rows.map(VariantModel.fromMap).toList();
  }

  Future<List<VariantModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('product_variants', orderBy: 'name ASC');
    return rows.map(VariantModel.fromMap).toList();
  }

  Future<int> update(VariantModel variant) async {
    final db = await _db.database;
    return db.update(
      'product_variants',
      variant.toMap(),
      where: 'id = ?',
      whereArgs: [variant.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('product_variants', where: 'id = ?', whereArgs: [id]);
  }
}

