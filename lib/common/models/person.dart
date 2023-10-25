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

  Person({
    super.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.dateBirth,
    this.phone = const PhoneNumber(),
    this.email,
    this.address,
  });

  static Person get empty => Person(
      firstName: '',
      middleName: null,
      lastName: '',
      address: null,
      dateBirth: null,
      email: null,
      id: null,
      phone: PhoneNumber.empty);

  Person.fromSerialized(map)
      : firstName = map['firstName'],
        middleName = map['middleName'],
        lastName = map['lastName'],
        dateBirth = map['birthDate'] == null
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
      'birthDate': dateBirth?.millisecondsSinceEpoch,
      'phone': phone.toString(),
      'email': email,
      'address': address?.serialize(),
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

  ///
  /// Full name without the middle name
  String get fullName => '$firstName${lastName.isEmpty ? '' : ' $lastName'}';

  @override
  String toString() =>
      '$firstName${middleName == null ? '' : ' $middleName'}${lastName.isEmpty ? '' : ' $lastName'}';
}
