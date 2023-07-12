import 'package:enhanced_containers/enhanced_containers.dart';

import 'package:crcrme_banque_stages/common/models/address.dart';

class School extends ItemSerializable {
  final String name;
  final Address address;

  School({required this.name, required this.address});

  School.fromSerialized(map)
      : name = map['name'],
        address = Address.fromSerialized(map['address']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {'name': name, 'address': address.serialize()};
  }

  School copyWith({String? name, Address? address}) => School(
        name: name ?? this.name,
        address: address ?? this.address,
      );
}
