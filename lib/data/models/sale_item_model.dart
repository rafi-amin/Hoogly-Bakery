/// Model mapped to the `sale_items` table.
class SaleItemModel {
  const SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    this.variantId,
    required this.nameSnapshot,
    this.variantSnapshot,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
  });

  final int? id;
  final int saleId;
  final int productId;
  final int? variantId;
  final String nameSnapshot;
  final String? variantSnapshot;
  final int qty;
  final double unitPrice;
  final double totalPrice;

  factory SaleItemModel.fromMap(Map<String, Object?> map) {
    final saleId = map['sale_id'];
    final productId = map['product_id'];
    final nameSnapshot = map['name_snapshot'];
    final qty = map['qty'];
    final unitPrice = map['unit_price'];
    final totalPrice = map['total_price'];

    if (saleId == null ||
        productId == null ||
        nameSnapshot == null ||
        qty == null ||
        unitPrice == null ||
        totalPrice == null) {
      throw ArgumentError('Missing required sale_item fields in map: $map');
    }

    return SaleItemModel(
      id: map['id'] as int?,
      saleId: saleId as int,
      productId: productId as int,
      variantId: map['variant_id'] as int?,
      nameSnapshot: nameSnapshot as String,
      variantSnapshot: map['variant_snapshot'] as String?,
      qty: qty as int,
      unitPrice: (unitPrice as num).toDouble(),
      totalPrice: (totalPrice as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'sale_id': saleId,
        'product_id': productId,
        'variant_id': variantId,
        'name_snapshot': nameSnapshot,
        'variant_snapshot': variantSnapshot,
        'qty': qty,
        'unit_price': unitPrice,
        'total_price': totalPrice,
      };

  SaleItemModel copyWith({
    int? id,
    int? saleId,
    int? productId,
    int? variantId,
    String? nameSnapshot,
    String? variantSnapshot,
    int? qty,
    double? unitPrice,
    double? totalPrice,
  }) {
    return SaleItemModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      variantSnapshot: variantSnapshot ?? this.variantSnapshot,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

