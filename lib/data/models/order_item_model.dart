import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    super.id,
    required super.productId,
    required super.name,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromMap(Map<String, Object?> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap(int orderId) => {
        'id': id,
        'order_id': orderId,
        'product_id': productId,
        'name': name,
        'quantity': quantity,
        'price': price,
      };
}
