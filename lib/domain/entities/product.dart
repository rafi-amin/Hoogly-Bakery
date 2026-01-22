class Product {
  final int id;
  final int? categoryId;
  final String name;
  final double price;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.isAvailable,
  });
}
