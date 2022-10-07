import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/item_serializable.dart';

class Teacher extends ItemSerializable {
  Teacher({
    super.id,
    this.name = "",
    this.email = "",
  });

  Teacher.fromSerialized(map)
      : name = map['n'],
        email = map['e'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'n': name,
      'e': email,
      'id': id,
    };
  }

  Teacher copyWith({
    String? name,
    String? email,
    String? id,
  }) =>
      Teacher(
        name: name ?? this.name,
        email: email ?? this.email,
        id: id ?? this.id,
      );

  final String name;
  final String email;
}
