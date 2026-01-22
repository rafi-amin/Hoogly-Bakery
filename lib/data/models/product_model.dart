import '../../domain/entities/product.dart';

/// Product model aligned with the `products` table schema.
///
/// It extends the domain [Product] entity and adds POS-specific
/// fields such as `basePrice`, `hasVariants`, `isActive`, and `imagePath`.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.price,
    required super.isAvailable,
    required this.basePrice,
    required this.hasVariants,
    required this.isActive,
    this.imagePath,
  });

  final double basePrice;
  final bool hasVariants;
  final bool isActive;
  final String? imagePath;

  factory ProductModel.fromMap(Map<String, Object?> map) {
    final id = map['id'];
    final categoryId = map['category_id'];
    final name = map['name'];
    final basePrice = map['base_price'];
    final hasVariants = map['has_variants'];
    final isActive = map['is_active'];
    final isAvailable = map['is_available'];

    if (id == null ||
        categoryId == null ||
        name == null ||
        basePrice == null ||
        hasVariants == null ||
        isActive == null ||
        isAvailable == null) {
      throw ArgumentError('Missing required product fields in map: $map');
    }

    final base = (basePrice as num).toDouble();
    final rawPrice = map['price'];
    final effectivePrice =
        rawPrice == null ? base : (rawPrice as num).toDouble();

    return ProductModel(
      id: id as int,
      categoryId: categoryId as int,
      name: name as String,
      basePrice: base,
      price: effectivePrice,
      hasVariants: (hasVariants as int) == 1,
      isActive: (isActive as int) == 1,
      isAvailable: (isAvailable as int) == 1,
      imagePath: map['image_path'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category_id': categoryId,
        'base_price': basePrice,
        'has_variants': hasVariants ? 1 : 0,
        'is_active': isActive ? 1 : 0,
        'image_path': imagePath,
        // keep price / is_available in sync with domain view
        'price': price,
        'is_available': isAvailable ? 1 : 0,
      };

  ProductModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? basePrice,
    double? price,
    bool? hasVariants,
    bool? isActive,
    bool? isAvailable,
    String? imagePath,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      price: price ?? this.price,
      hasVariants: hasVariants ?? this.hasVariants,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
