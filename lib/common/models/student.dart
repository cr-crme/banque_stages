import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/item_serializable.dart';

class Student extends ItemSerializable {
  Student({
    super.id,
    this.name = "",
    this.email = "",
  });

  Student.fromSerialized(map)
      : name = map['n'],
        email = map['e'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(map) {
    return Student.fromSerialized(map);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'n': name,
      'e': email,
      'id': id,
    };
  }

  Student copyWith({
    String? name,
    String? email,
    String? id,
  }) =>
      Student(
        name: name ?? this.name,
        email: email ?? this.email,
        id: id ?? this.id,
      );

  final String name;
  final String email;
}
