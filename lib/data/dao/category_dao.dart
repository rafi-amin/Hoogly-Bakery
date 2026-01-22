import '../../core/database/app_database.dart';
import '../models/category_model.dart';

class CategoryDao {
  CategoryDao(this._db);

  final AppDatabase _db;

  Future<int> insert(CategoryModel category) async {
    final db = await _db.database;
    return db.insert('categories', category.toMap());
  }

  Future<CategoryModel?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CategoryModel.fromMap(rows.first);
  }

  Future<List<CategoryModel>> getActiveCategories() async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: 'is_active = 1',
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<int> update(CategoryModel category) async {
    final db = await _db.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}

