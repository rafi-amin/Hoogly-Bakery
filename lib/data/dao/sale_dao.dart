import '../../core/database/app_database.dart';
import '../models/sale_item_addon_model.dart';
import '../models/sale_item_model.dart';
import '../models/sale_model.dart';

class SaleDao {
  SaleDao(this._db);

  final AppDatabase _db;

  /// Creates a sale with its items and addons in a single transaction.
  ///
  /// [addonsByItemIndex] maps the index of the item in [items] to its addons.
  Future<SaleModel> createSaleWithItemsAndAddons({
    required SaleModel sale,
    required List<SaleItemModel> items,
    required Map<int, List<SaleItemAddonModel>> addonsByItemIndex,
  }) async {
    final db = await _db.database;
    return db.transaction((txn) async {
      final saleId = await txn.insert('sales', sale.toMap());

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final itemId = await txn.insert(
          'sale_items',
          item.copyWith(saleId: saleId, id: null).toMap(),
        );

        final addons = addonsByItemIndex[i] ?? const [];
        for (final addon in addons) {
          await txn.insert(
            'sale_item_addons',
            addon.copyWith(saleItemId: itemId, id: null).toMap(),
          );
        }
      }

      return sale.copyWith(id: saleId);
    });
  }

  Future<List<SaleModel>> getTodaySales() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getSalesByDateRange(start, end);
  }

  Future<List<SaleModel>> getSalesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db.database;
    final rows = await db.query(
      'sales',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'created_at DESC',
    );
    return rows.map(SaleModel.fromMap).toList();
  }
}

