import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Thin service wrapper around [AppDatabase] providing common POS helpers.
class DbService {
  DbService(this._appDatabase);

  final AppDatabase _appDatabase;

  /// Exposes the underlying [Database] for advanced queries when needed.
  Future<Database> get database => _appDatabase.database;

  /// Returns the next invoice number as a formatted string and
  /// updates the counter in a single transaction.
  ///
  /// By default, invoice numbers are simple incremental integers
  /// starting from 1001 (configurable by seeding `invoice_counters`).
  Future<String> nextInvoiceNo() async {
    final db = await _appDatabase.database;
    return db.transaction((txn) async {
      final rows =
          await txn.query('invoice_counters', where: 'id = ?', whereArgs: [1]);
      int lastNumber;
      if (rows.isEmpty) {
        // Initialize if missing.
        lastNumber = 1000;
        await txn.insert('invoice_counters', {
          'id': 1,
          'last_number': lastNumber,
        });
      } else {
        lastNumber = rows.first['last_number'] as int;
      }

      final next = lastNumber + 1;
      await txn.update(
        'invoice_counters',
        {'last_number': next},
        where: 'id = ?',
        whereArgs: [1],
      );

      // Simple numeric invoice; can be changed to include prefixes/dates.
      return next.toString();
    });
  }
}

