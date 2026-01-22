import 'order_item.dart';

class Order {
  final int? id;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    this.id,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.items,
  });
}
