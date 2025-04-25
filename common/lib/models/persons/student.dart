import 'dart:math';

import 'package:common/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';

enum Program {
  fpt,
  fms,
  undefined;

  int _toInt(String version) {
    if (version == '1.0.0') {
      return index;
    }
    throw WrongVersionException(version, '1.0.0');
  }

  static Program _fromInt(int index, String version) {
    if (version == '1.0.0') {
      return Program.values[index];
    }
    throw WrongVersionException(version, '1.0.0');
  }

  @override
  String toString() {
    switch (this) {
      case Program.fpt:
        return 'FPT';
      case Program.fms:
        return 'FMS';
      case Program.undefined:
        return 'Undefined';
    }
  }
}

class Student extends Person {
  final _currentVersion = '1.0.0';

  final String photo;

  final Program program;
  final String group;

  final Person contact;
  final String contactLink;

  Student({
    super.id,
    required super.firstName,
    super.middleName,
    required super.lastName,
    required super.dateBirth,
    required super.phone,
    required super.email,
    required super.address,
    String? photo,
    required this.program,
    required this.group,
    required this.contact,
    required this.contactLink,
  }) : photo = photo ?? Random().nextInt(0xFFFFFF).toString();

  Student.fromSerialized(super.map)
      : photo = map['photo'] ?? Random().nextInt(0xFFFFFF).toString(),
        program = map['program'] == null
            ? Program.undefined
            : Program._fromInt(map['program'] as int, map['version']),
        group = map['group'] ?? '',
        contact = Person.fromSerialized(map['contact'] ?? {}),
        contactLink = map['contact_link'] ?? '',
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'version': _currentVersion,
        'photo': photo,
        'program': program._toInt(_currentVersion),
        'group': group,
        'contact': contact.serialize(),
        'contact_link': contactLink,
      });
  }

  Student get limitedInfo => Student(
        id: id,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        group: group,
        program: program,
        address: Address.empty,
        contact: Person.empty,
        phone: PhoneNumber.empty,
        contactLink: '',
        dateBirth: null,
        email: null,
      );

  @override
  Student copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateBirth,
    PhoneNumber? phone,
    String? email,
    Address? address,
    String? photo,
    Program? program,
    String? group,
    Person? contact,
    String? contactLink,
  }) =>
      Student(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        middleName: middleName ?? this.middleName,
        lastName: lastName ?? this.lastName,
        dateBirth: dateBirth ?? this.dateBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        program: program ?? this.program,
        group: group ?? this.group,
        contact: contact ?? this.contact,
        contactLink: contactLink ?? this.contactLink,
        photo: photo ?? this.photo,
      );

  Student copyWithData(Map<String, dynamic> data) {
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => ![
          'id',
          'version',
          'first_name',
          'middle_name',
          'last_name',
          'date_birth',
          'phone',
          'email',
          'address',
          'photo',
          'program',
          'group',
          'contact',
          'contact_link',
        ].contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }
    return Student(
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
      photo: data['photo'] ?? photo,
      program: data['program'] == null
          ? program
          : Program._fromInt(data['program'] as int, _currentVersion),
      group: data['group'] ?? group,
      contact: data['contact'] == null
          ? contact
          : Person.fromSerialized(data['contact']),
      contactLink: data['contact_link'] ?? contactLink,
    );
  }

  @override
  String toString() {
    return 'Student{${super.toString()}, photo: $photo, program: $program, group: $group, contact: $contact, contactLink: $contactLink}';
  }
}
