import 'package:common/models/generic/address.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class School extends ItemSerializable {
  final String name;
  final Address address;

  School({
    super.id,
    required this.name,
    required this.address,
  });

  static School get empty => School(
        name: 'Unnamed',
        id: null,
        address: Address.empty,
      );

  School.fromSerialized(super.map)
      : name = map['name'] ?? 'Unnamed school',
        address = Address.fromSerialized(map['address'] ?? {}),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'name': name,
      'address': address.serialize(),
    };
  }

  School copyWith({String? id, String? name, Address? address}) => School(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
      );
}
