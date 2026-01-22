class OrderItem {
  final int? id;
  final int productId;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;
}
