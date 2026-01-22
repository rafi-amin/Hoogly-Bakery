/// Model mapped to the `users` table.
class UserModel {
  const UserModel({
    this.id,
    required this.name,
    required this.pin,
    required this.role,
    required this.isActive,
  });

  final int? id;
  final String name;
  final String pin;
  final String role;
  final bool isActive;

  factory UserModel.fromMap(Map<String, Object?> map) {
    final name = map['name'];
    final pin = map['pin'];
    final role = map['role'];
    final isActive = map['is_active'];

    if (name == null || pin == null || role == null || isActive == null) {
      throw ArgumentError('Missing required user fields in map: $map');
    }

    return UserModel(
      id: map['id'] as int?,
      name: name as String,
      pin: pin as String,
      role: role as String,
      isActive: (isActive as int) == 1,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'pin': pin,
        'role': role,
        'is_active': isActive ? 1 : 0,
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? pin,
    String? role,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}

