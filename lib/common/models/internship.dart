import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

class Internship extends ItemSerializable {
  Internship({
    super.id,
    required this.teacherId,
    required this.enterpriseId,
    required this.jobId,
    this.name = "",
    this.phone = "",
    this.email = "",
    required this.date,
  });

  Internship.fromSerialized(map)
      : teacherId = map['teacher'],
        enterpriseId = map['enterprise'],
        jobId = map['job'],
        name = map['name'],
        phone = map['phone'],
        email = map['email'],
        date = DateTimeRange(
          start: DateTime.parse(map['start']),
          end: DateTime.parse(map['end']),
        ),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'teacher': teacherId,
      'enterprise': enterpriseId,
      'job': jobId,
      'name': name,
      'phone': phone,
      'email': email,
      'start': date.start.toString(),
      'end': date.end.toString(),
      'id': id,
    };
  }

  Internship copyWith({
    String? teacherId,
    String? enterpriseId,
    String? jobId,
    String? name,
    String? phone,
    String? email,
    DateTimeRange? date,
    String? id,
  }) =>
      Internship(
        teacherId: teacherId ?? this.teacherId,
        enterpriseId: enterpriseId ?? this.enterpriseId,
        jobId: jobId ?? this.jobId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        date: date ?? this.date,
        id: id ?? this.id,
      );

  final String teacherId;
  final String enterpriseId;
  final String jobId;

  final String name;
  final String phone;
  final String email;

  final DateTimeRange date;
}
