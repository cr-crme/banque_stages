import 'package:common/exceptions.dart';
import 'package:common/models/address.dart';
import 'package:common/models/person.dart';
import 'package:common/models/phone_number.dart';

List<String> _stringListFromSerialized(List? list) =>
    (list ?? []).map<String>((e) => e).toList();

class Teacher extends Person {
  final String schoolId;
  final List<String> groups;

  Teacher({
    super.id,
    required super.firstName,
    required super.middleName,
    required super.lastName,
    required this.schoolId,
    required this.groups,
    required super.email,
    required super.phone,
    required super.address,
    required super.dateBirth,
  }) {
    if (address.isNotEmpty) {
      throw ArgumentError('Address should not be set for a teacher');
    }
    if (dateBirth != null) {
      throw ArgumentError('Date of birth should not be set for a teacher');
    }
  }

  Teacher.fromSerialized(super.map)
      : schoolId = map['schoolId'] ?? '',
        groups = _stringListFromSerialized(map['groups']),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => super.serializedMap()
    ..addAll({
      'schoolId': schoolId,
      'groups': groups,
    });

  @override
  Teacher copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    String? schoolId,
    List<String>? groups,
    String? email,
    PhoneNumber? phone,
    Address? address,
    DateTime? dateBirth,
  }) =>
      Teacher(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        schoolId: schoolId ?? this.schoolId,
        groups: groups ?? this.groups,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        dateBirth: dateBirth ?? this.dateBirth,
        address: address ?? this.address,
      );

  // TODO : Add to protocol
  List<String> get serializedFields => [
        'id',
        'firstName',
        'middleName',
        'lastName',
        'schoolId',
        'groups',
        'phone',
        'email',
        'dateBirth',
        'address',
      ];

  Teacher copyWithData(Map<String, dynamic> data) {
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => !serializedFields.contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }
    return Teacher(
      id: data['id']?.toString() ?? id,
      firstName: data['firstName'] ?? firstName,
      middleName: data['middleName'] ?? middleName,
      lastName: data['lastName'] ?? lastName,
      schoolId: data['schoolId'] ?? schoolId,
      groups: data['groups'] == null
          ? groups
          : _stringListFromSerialized(data['groups']),
      phone: data['phone'] == null
          ? phone
          : PhoneNumber.fromSerialized(data['phone']),
      email: data['email'] ?? email,
      dateBirth: null,
      address: data['address'] == null
          ? address
          : Address.fromSerialized(data['address']),
    );
  }
}
