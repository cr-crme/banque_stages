import 'dart:math';

import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';

enum Program {
  fpt,
  fms,
  undefined;

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
  final String photo;
  Widget get avatar =>
      CircleAvatar(backgroundColor: Color(int.parse(photo)).withAlpha(255));

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
    super.phone,
    required super.email,
    required super.address,
    String? photo,
    required this.program,
    required this.group,
    required this.contact,
    required this.contactLink,
  }) : photo = photo ?? Random().nextInt(0xFFFFFF).toString();

  bool hasActiveInternship(BuildContext context) {
    final internships = InternshipsProvider.of(context, listen: false);
    for (final internship in internships) {
      if (internship.isActive && internship.studentId == id) return true;
    }
    return false;
  }

  Student.fromSerialized(super.map)
      : photo = map['photo'] ?? Random().nextInt(0xFFFFFF).toString(),
        program = map['program'] == null
            ? Program.undefined
            : Program.values[map['program']],
        group = map['group'] ?? '',
        contact = Person.fromSerialized(map['contact'] ?? {}),
        contactLink = map['contactLink'] ?? '',
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'photo': photo,
        'program': program.index,
        'group': group,
        'contact': contact.serialize(),
        'contactLink': contactLink,
      });
  }

  Student get limitedInfo => Student(
        id: id,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        group: group,
        program: program,
        address: null,
        contact: Person.empty,
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
}
