import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class SchoolBoard extends ItemSerializable {
  final String name;

  SchoolBoard({
    super.id,
    required this.name,
  });

  static SchoolBoard get empty => SchoolBoard(name: 'Unnamed', id: null);

  SchoolBoard.fromSerialized(super.map)
      : name = map['name'] ?? 'Unnamed',
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {'name': name};

  SchoolBoard copyWith({
    String? id,
    String? name,
  }) =>
      SchoolBoard(
        id: id ?? this.id,
        name: name ?? this.name,
      );

      SchoolBoard copyWithData({
    String? name,

  @override
  String toString() => name;
}
