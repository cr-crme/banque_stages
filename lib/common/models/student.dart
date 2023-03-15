import 'dart:math';

import 'package:flutter/material.dart';

import '/common/models/person.dart';

class Student extends Person {
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
  }) : photo = photo ?? Random().nextInt(0xFFFFFF).toString() {
    avatar = CircleAvatar(
        backgroundColor: Color(int.parse(this.photo)).withAlpha(255));
  }

  Student.fromSerialized(map)
      : photo = map['photo'],
        avatar = CircleAvatar(
            backgroundColor: Color(int.parse(map['photo'])).withAlpha(255)),
        program = map['program'],
        group = map['group'],
        contact = Person.fromSerialized(map['contact']),
        contactLink = map['contactLink'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return super.serializedMap()
      ..addAll({
        'photo': photo,
        'program': program,
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
    String? phone,
    String? email,
    String? address,
    String? program,
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
        program: program ?? this.program,
        group: group ?? this.group,
        contact: contact ?? this.contact,
        contactLink: contactLink ?? this.contactLink,
      );

  final String photo;
  late final Widget avatar;

  final String program;
  final String group;

  final Person contact;
  final String contactLink;
}
