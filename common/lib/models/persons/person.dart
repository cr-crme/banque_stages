import 'package:common/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/extended_item_serializable.dart';
import 'package:common/models/generic/phone_number.dart';

class Person extends ExtendedItemSerializable {
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime? dateBirth;

  final PhoneNumber phone;
  final String? email;
  final Address address;

  Person({
    super.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dateBirth,
    required this.phone,
    required this.email,
    required this.address,
  });

  static Person get empty => Person(
      firstName: 'Unnamed',
      middleName: null,
      lastName: 'Unnamed',
      address: Address.empty,
      dateBirth: null,
      email: null,
      id: null,
      phone: PhoneNumber.empty);

  Person.fromSerialized(super.map)
      : firstName = map['first_name'] ?? 'Unnamed',
        middleName = map['middle_name'],
        lastName = map['last_name'] ?? 'Unnamed',
        dateBirth = map['date_birth'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['date_birth']),
        phone = map['phone'] == null
            ? PhoneNumber.empty
            : PhoneNumber.fromSerialized(map['phone']),
        email = map['email'],
        address = map['address'] == null
            ? Address.empty
            : Address.fromSerialized(map['address']),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'date_birth': dateBirth?.millisecondsSinceEpoch,
        'phone': phone.serialize(),
        'email': email,
        'address': address.serialize(),
      };

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

  @override
  Person copyWithData(Map<String, dynamic> data) {
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => ![
          'id',
          'first_name',
          'middle_name',
          'last_name',
          'date_birth',
          'phone',
          'email',
          'address',
        ].contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }
    return Person(
      id: data['id']?.toString() ?? id,
      firstName: data['first_name'] ?? firstName,
      middleName: data['middle_name'] ?? middleName,
      lastName: data['last_name'] ?? lastName,
      dateBirth: data['date_birth'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(data['date_birth']),
      phone: data['phone'] == null
          ? phone
          : PhoneNumber.fromSerialized(data['phone'] ?? {}),
      email: data['email'] ?? email,
      address: data['address'] == null
          ? address
          : Address.fromSerialized(data['address']),
    );
  }

  ///
  /// Full name without the middle name
  String get fullName => '$firstName${lastName.isEmpty ? '' : ' $lastName'}';

  @override
  String toString() =>
      '$firstName${middleName == null ? '' : ' $middleName'}${lastName.isEmpty ? '' : ' $lastName'}';
}
