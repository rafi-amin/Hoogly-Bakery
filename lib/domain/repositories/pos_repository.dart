import '../entities/category.dart';
import '../entities/order.dart';
import '../entities/product.dart';

abstract class PosRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts({int? categoryId});
  Future<Order> createOrder(Order order);
  Future<List<Order>> recentOrders({int limit});
  Future<String> exportOrdersCsv();
}
