import 'package:common/models/generic/address.dart';
import 'package:enhanced_containers/enhanced_containers.dart';

class School extends ItemSerializable {
  final String name;
  final Address address;

  School({super.id, required this.name, required this.address});

  School.fromSerialized(super.map)
      : name = map['name'] ?? 'Unnamed school',
        address = Address.fromSerialized(map['address'] ?? {}),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() {
    return {'name': name, 'address': address.serialize()};
  }

  School copyWith({String? id, String? name, Address? address}) => School(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
      );
}
