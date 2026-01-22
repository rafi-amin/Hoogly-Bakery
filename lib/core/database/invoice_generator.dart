import 'package:sqflite/sqflite.dart';

/// Generates the next invoice number using the `invoice_counters` table.
///
/// - Format: `HB-000001`
/// - Uses a SQLite transaction to update the counter atomically, so it is
///   safe to use offline and under concurrent access on the same device.
///
/// This function does not create the `invoice_counters` table; the schema
/// must already exist (see `AppDatabase`).
Future<String> generateInvoiceNo(Database db) async {
  return db.transaction((txn) async {
    // Ensure there is always a single counter row with id = 1.
    final rows =
        await txn.query('invoice_counters', where: 'id = ?', whereArgs: [1]);

    int lastNumber;
    if (rows.isEmpty) {
      // Initialize at 0 so the first generated invoice becomes HB-000001.
      lastNumber = 0;
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

    final padded = next.toString().padLeft(6, '0');
    return 'HB-$padded';
  });
}

