import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required this.type,
    required this.sortOrder,
    required this.isActive,
  });

  /// Category type in DB (e.g. bakery / restaurant / mixed).
  final String type;

  /// Sort order used in the POS UI.
  final int sortOrder;

  /// Whether the category is active in the catalog.
  final bool isActive;

  factory CategoryModel.fromMap(Map<String, Object?> map) {
    final id = map['id'];
    final name = map['name'];
    final type = map['type'];
    final sortOrder = map['sort_order'];
    final isActive = map['is_active'];
    if (id == null ||
        name == null ||
        type == null ||
        sortOrder == null ||
        isActive == null) {
      throw ArgumentError('Missing required category fields in map: $map');
    }

    return CategoryModel(
      id: id as int,
      name: name as String,
      type: type as String,
      sortOrder: sortOrder as int,
      isActive: (isActive as int) == 1,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'sort_order': sortOrder,
        'is_active': isActive ? 1 : 0,
      };

  CategoryModel copyWith({
    int? id,
    String? name,
    String? type,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
