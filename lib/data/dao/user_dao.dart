import '../../core/database/app_database.dart';
import '../models/user_model.dart';

class UserDao {
  UserDao(this._db);

  final AppDatabase _db;

  Future<UserModel?> login(String pin) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'pin = ? AND is_active = 1',
      whereArgs: [pin],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }
}

