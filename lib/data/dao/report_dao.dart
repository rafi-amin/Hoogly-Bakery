import '../../core/database/app_database.dart';

class ReportDao {
  ReportDao(this._db);

  final AppDatabase _db;

  Future<double> todaySalesTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final db = await _db.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(total) as total_sum
      FROM sales
      WHERE created_at >= ? AND created_at < ?
      ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final value = result.first['total_sum'] as num?;
    return value?.toDouble() ?? 0.0;
  }

  /// Returns a map of payment_method -> total amount for today.
  Future<Map<String, double>> paymentBreakdownByMethod() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT payment_method, SUM(total) as total_sum
      FROM sales
      WHERE created_at >= ? AND created_at < ?
      GROUP BY payment_method
      ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final map = <String, double>{};
    for (final row in rows) {
      final method = row['payment_method'] as String?;
      final sum = row['total_sum'] as num?;
      if (method != null && sum != null) {
        map[method] = sum.toDouble();
      }
    }
    return map;
  }

  Future<int> totalOrdersToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final db = await _db.database;
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) as cnt
      FROM sales
      WHERE created_at >= ? AND created_at < ?
      ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final count = rows.first['cnt'] as int?;
    return count ?? 0;
  }
}

