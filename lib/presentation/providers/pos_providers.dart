import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import 'dependencies.dart';

final selectedCategoryIdProvider = StateProvider<int?>((ref) => null);

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final repo = ref.read(posRepositoryProvider);
  return repo.getCategories();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(posRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);
  return repo.getProducts(categoryId: categoryId);
});

final recentOrdersProvider = FutureProvider<List<Order>>((ref) {
  final repo = ref.read(posRepositoryProvider);
  return repo.recentOrders(limit: 20);
});
