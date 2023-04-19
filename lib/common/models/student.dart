import 'dart:math';

import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/common/models/person.dart';
import '/common/models/phone_number.dart';

enum Program {
  fpt,
  fms,
}

extension ProgramNamed on Program {
  String get title {
    switch (this) {
      case Program.fpt:
        return 'FPT';
      case Program.fms:
        return 'FMS';
    }
  }
}

class Student extends Person {
  final String photo;
  late final Widget avatar;

  final String teacherId;
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
    required this.teacherId,
    required this.program,
    required this.group,
    required this.contact,
    required this.contactLink,
  }) : photo = photo ?? Random().nextInt(0x00FF00).toString() {
    avatar = CircleAvatar(
        backgroundColor: Color(int.parse(this.photo)).withAlpha(255));
  }

  Student.fromSerialized(map)
      : photo = map['photo'],
        avatar = CircleAvatar(
            backgroundColor: Color(int.parse(map['photo'])).withAlpha(255)),
        teacherId = map['teacherId'],
        program = Program.values[map['program']],
        group = map['group'],
        contact = Person.fromSerialized(map['contact']),
        contactLink = map['contactLink'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'photo': photo,
        'teacherId': teacherId,
        'program': program.index,
        'group': group,
        'contact': contact.serializedMap(),
        'contactLink': contactLink,
      });
  }

  @override
  Student copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateBirth,
    PhoneNumber? phone,
    String? email,
    Address? address,
    String? teacherId,
    Program? program,
    String? group,
    Person? contact,
    String? contactLink,
    String? id,
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
        teacherId: teacherId ?? this.teacherId,
        program: program ?? this.program,
        group: group ?? this.group,
        contact: contact ?? this.contact,
        contactLink: contactLink ?? this.contactLink,
      );
}
