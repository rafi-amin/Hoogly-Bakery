import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import 'order_item_model.dart';

class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.subtotal,
    required super.tax,
    required super.total,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    required List<OrderItem> super.items,
  });

  factory OrderModel.fromMap(
    Map<String, Object?> map,
    List<OrderItemModel> items,
  ) {
    return OrderModel(
      id: map['id'] as int?,
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'payment_method': paymentMethod,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}
