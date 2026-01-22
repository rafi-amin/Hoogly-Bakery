/// Model mapped to the `sale_item_addons` table.
class SaleItemAddonModel {
  const SaleItemAddonModel({
    this.id,
    required this.saleItemId,
    required this.addonId,
    required this.addonNameSnapshot,
    required this.qty,
    required this.addonPrice,
    required this.totalPrice,
  });

  final int? id;
  final int saleItemId;
  final int addonId;
  final String addonNameSnapshot;
  final int qty;
  final double addonPrice;
  final double totalPrice;

  factory SaleItemAddonModel.fromMap(Map<String, Object?> map) {
    final saleItemId = map['sale_item_id'];
    final addonId = map['addon_id'];
    final addonNameSnapshot = map['addon_name_snapshot'];
    final qty = map['qty'];
    final addonPrice = map['addon_price'];
    final totalPrice = map['total_price'];

    if (saleItemId == null ||
        addonId == null ||
        addonNameSnapshot == null ||
        qty == null ||
        addonPrice == null ||
        totalPrice == null) {
      throw ArgumentError(
        'Missing required sale_item_addons fields in map: $map',
      );
    }

    return SaleItemAddonModel(
      id: map['id'] as int?,
      saleItemId: saleItemId as int,
      addonId: addonId as int,
      addonNameSnapshot: addonNameSnapshot as String,
      qty: qty as int,
      addonPrice: (addonPrice as num).toDouble(),
      totalPrice: (totalPrice as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'sale_item_id': saleItemId,
        'addon_id': addonId,
        'addon_name_snapshot': addonNameSnapshot,
        'qty': qty,
        'addon_price': addonPrice,
        'total_price': totalPrice,
      };

  SaleItemAddonModel copyWith({
    int? id,
    int? saleItemId,
    int? addonId,
    String? addonNameSnapshot,
    int? qty,
    double? addonPrice,
    double? totalPrice,
  }) {
    return SaleItemAddonModel(
      id: id ?? this.id,
      saleItemId: saleItemId ?? this.saleItemId,
      addonId: addonId ?? this.addonId,
      addonNameSnapshot: addonNameSnapshot ?? this.addonNameSnapshot,
      qty: qty ?? this.qty,
      addonPrice: addonPrice ?? this.addonPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

