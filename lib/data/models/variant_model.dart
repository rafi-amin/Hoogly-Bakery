/// Model mapped to the `product_variants` table.
class VariantModel {
  const VariantModel({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    this.sku,
    required this.isActive,
  });

  final int? id;
  final int productId;
  final String name;
  final double price;
  final String? sku;
  final bool isActive;

  factory VariantModel.fromMap(Map<String, Object?> map) {
    final productId = map['product_id'];
    final name = map['name'];
    final price = map['price'];
    final isActive = map['is_active'];

    if (productId == null ||
        name == null ||
        price == null ||
        isActive == null) {
      throw ArgumentError('Missing required variant fields in map: $map');
    }

    return VariantModel(
      id: map['id'] as int?,
      productId: productId as int,
      name: name as String,
      price: (price as num).toDouble(),
      sku: map['sku'] as String?,
      isActive: (isActive as int) == 1,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'product_id': productId,
        'name': name,
        'price': price,
        'sku': sku,
        'is_active': isActive ? 1 : 0,
      };

  VariantModel copyWith({
    int? id,
    int? productId,
    String? name,
    double? price,
    String? sku,
    bool? isActive,
  }) {
    return VariantModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      isActive: isActive ?? this.isActive,
    );
  }
}

