import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/product.dart';
import 'dependencies.dart';

class CartLine {
  CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  CartLine copyWith({Product? product, int? quantity}) => CartLine(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );

  double get lineTotal => product.price * quantity;
}

class CartState {
  const CartState({this.lines = const {}});

  final Map<int, CartLine> lines;

  double get subtotal =>
      lines.values.fold(0, (sum, line) => sum + line.lineTotal);

  double get tax => subtotal * 0.08; // 8% city tax assumption
  double get total => subtotal + tax;
  bool get isEmpty => lines.isEmpty;
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this.ref) : super(const CartState());

  final Ref ref;

  void add(Product product) {
    final existing = state.lines[product.id];
    final updated = {
      ...state.lines,
      product.id: existing == null
          ? CartLine(product: product, quantity: 1)
          : existing.copyWith(quantity: existing.quantity + 1),
    };
    state = CartState(lines: updated);
  }

  void removeOne(Product product) {
    final existing = state.lines[product.id];
    if (existing == null) return;

    if (existing.quantity <= 1) {
      final updated = {...state.lines}..remove(product.id);
      state = CartState(lines: updated);
    } else {
      final updated = {
        ...state.lines,
        product.id: existing.copyWith(quantity: existing.quantity - 1),
      };
      state = CartState(lines: updated);
    }
  }

  void clear() => state = const CartState();

  Future<Order> checkout({String paymentMethod = 'cash'}) async {
    if (state.isEmpty) {
      throw StateError('Cannot checkout an empty cart');
    }

    final repo = ref.read(posRepositoryProvider);
    final order = Order(
      subtotal: state.subtotal,
      tax: state.tax,
      total: state.total,
      paymentMethod: paymentMethod,
      status: 'paid',
      createdAt: DateTime.now(),
      items: state.lines.values
          .map(
            (line) => OrderItem(
              productId: line.product.id,
              name: line.product.name,
              quantity: line.quantity,
              price: line.product.price,
            ),
          )
          .toList(),
    );

    final saved = await repo.createOrder(order);
    clear();
    return saved;
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) => CartNotifier(ref));
