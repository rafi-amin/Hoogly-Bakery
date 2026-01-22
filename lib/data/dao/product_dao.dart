import '../../core/database/app_database.dart';
import '../models/product_model.dart';

class ProductDao {
  ProductDao(this._db);

  final AppDatabase _db;

  Future<int> insert(ProductModel product) async {
    final db = await _db.database;
    return db.insert('products', product.toMap());
  }

  Future<ProductModel?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ProductModel.fromMap(rows.first);
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final db = await _db.database;
    final rows = await db.query(
      'products',
      where: 'category_id = ? AND is_active = 1',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _db.database;
    final rows = await db.query(
      'products',
      where: 'is_active = 1 AND name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<List<ProductModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<int> update(ProductModel product) async {
    final db = await _db.database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}

