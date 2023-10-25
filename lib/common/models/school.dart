import 'package:enhanced_containers/enhanced_containers.dart';

import 'package:crcrme_banque_stages/common/models/address.dart';

class School extends ItemSerializable {
  final String name;
  final Address address;

  School({super.id, required this.name, required this.address});

  School.fromSerialized(map)
      : name = map['name'],
        address = Address.fromSerialized(map['address']),
        super.fromSerialized(map);

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
