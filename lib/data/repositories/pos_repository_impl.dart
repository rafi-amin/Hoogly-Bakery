import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/local_pos_datasource.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class PosRepositoryImpl implements PosRepository {
  PosRepositoryImpl(this._local);

  final LocalPosDataSource _local;

  @override
  Future<List<CategoryModel>> getCategories() => _local.getCategories();

  @override
  Future<List<ProductModel>> getProducts({int? categoryId}) =>
      _local.getProducts(categoryId: categoryId);

  @override
  Future<OrderModel> createOrder(Order order) async {
    final orderModel = OrderModel(
      id: order.id,
      subtotal: order.subtotal,
      tax: order.tax,
      total: order.total,
      paymentMethod: order.paymentMethod,
      status: order.status,
      createdAt: order.createdAt,
      items: order.items,
    );
    return _local.insertOrder(orderModel);
  }

  @override
  Future<List<OrderModel>> recentOrders({int limit = 50}) =>
      _local.getRecentOrders(limit: limit);

  @override
  Future<String> exportOrdersCsv() async {
    final orders = await recentOrders(limit: 200);
    final rows = <List<dynamic>>[
      ['ID', 'Created At', 'Subtotal', 'Tax', 'Total', 'Payment', 'Status'],
    ];

    for (final order in orders.reversed) {
      rows.add([
        order.id ?? '-',
        order.createdAt.toIso8601String(),
        order.subtotal,
        order.tax,
        order.total,
        order.paymentMethod,
        order.status,
      ]);

      for (final item in order.items) {
        rows.add(['', '   ${item.name}', '', item.quantity, item.price, '', '']);
      }
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/hoogli_orders.csv');
    await file.writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)], text: 'Hoogli Bakery Orders');
    return file.path;
  }
}
