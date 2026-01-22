/// Model mapped to the `addons` table.
class AddonModel {
  const AddonModel({
    this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  final int? id;
  final String name;
  final double price;
  final bool isActive;

  factory AddonModel.fromMap(Map<String, Object?> map) {
    final name = map['name'];
    final price = map['price'];
    final isActive = map['is_active'];

    if (name == null || price == null || isActive == null) {
      throw ArgumentError('Missing required addon fields in map: $map');
    }

    return AddonModel(
      id: map['id'] as int?,
      name: name as String,
      price: (price as num).toDouble(),
      isActive: (isActive as int) == 1,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'is_active': isActive ? 1 : 0,
      };

  AddonModel copyWith({
    int? id,
    String? name,
    double? price,
    bool? isActive,
  }) {
    return AddonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
    );
  }
}

