import 'package:enhanced_containers/enhanced_containers.dart';

import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';

class Person extends ItemSerializable {
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime? dateBirth;

  final PhoneNumber phone;
  final String? email;
  final Address? address;

  String get fullName => '$firstName $lastName';

  Person({
    super.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    DateTime? dateBirth,
    this.phone = const PhoneNumber(),
    this.email,
    this.address,
  }) : dateBirth = dateBirth ?? DateTime(0);

  Person.fromSerialized(map)
      : firstName = map['firstName'],
        middleName = map['middleName'],
        lastName = map['lastName'],
        dateBirth = map['birthDate'] == -1
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['birthDate']),
        phone = PhoneNumber.fromString(map['phone']),
        email = map['email'],
        address = Address.fromSerialized(map['address']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'birthDate': dateBirth?.millisecondsSinceEpoch ?? -1,
      'phone': phone.toString(),
      'email': email,
      'address': address?.serializedMap(),
    };
  }

  Person copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateBirth,
    PhoneNumber? phone,
    String? email,
    Address? address,
  }) =>
      Person(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        dateBirth: dateBirth ?? this.dateBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
      );

  Person deepCopy() {
    return Person(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      dateBirth: dateBirth == null
          ? null
          : DateTime(dateBirth!.year, dateBirth!.month, dateBirth!.day),
      phone: phone.deepCopy(),
      email: email,
      address: address?.deepCopy(),
    );
  }
}
