import '../../core/database/app_database.dart';
import '../models/category_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class LocalPosDataSource {
  LocalPosDataSource(this._db);

  final AppDatabase _db;

  Future<List<CategoryModel>> getCategories() async {
    final database = await _db.database;
    final results = await database.query('categories', orderBy: 'name ASC');
    return results.map(CategoryModel.fromMap).toList();
  }

  Future<List<ProductModel>> getProducts({int? categoryId}) async {
    final database = await _db.database;
    final results = await database.query(
      'products',
      where: categoryId != null ? 'category_id = ? AND is_available = 1' : 'is_available = 1',
      whereArgs: categoryId != null ? [categoryId] : null,
      orderBy: 'name ASC',
    );
    return results.map(ProductModel.fromMap).toList();
  }

  Future<OrderModel> insertOrder(OrderModel order) async {
    final database = await _db.database;
    return database.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap());
      final itemModels = order.items
          .map(
            (item) => OrderItemModel(
              id: item.id,
              productId: item.productId,
              name: item.name,
              quantity: item.quantity,
              price: item.price,
            ),
          )
          .toList();

      for (final item in itemModels) {
        await txn.insert('order_items', item.toMap(orderId));
      }

      return OrderModel(
        id: orderId,
        subtotal: order.subtotal,
        tax: order.tax,
        total: order.total,
        paymentMethod: order.paymentMethod,
        status: order.status,
        createdAt: order.createdAt,
        items: itemModels,
      );
    });
  }

  Future<List<OrderModel>> getRecentOrders({int limit = 50}) async {
    final database = await _db.database;
    final orders = await database.query(
      'orders',
      orderBy: 'id DESC',
      limit: limit,
    );

    final result = <OrderModel>[];
    for (final order in orders) {
      final items = await database.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [order['id']],
      );
      final itemModels = items.map(OrderItemModel.fromMap).toList();
      result.add(OrderModel.fromMap(order, itemModels));
    }
    return result;
  }
}
