import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

class Internship extends ItemSerializable {
  Internship({
    super.id,
    required this.teacherId,
    required this.enterpriseId,
    required this.jobId,
    required this.type,
    this.name = "",
    this.phone = "",
    this.email = "",
    required this.date,
  });

  Internship.fromSerialized(map)
      : teacherId = map['teacher'],
        enterpriseId = map['enterprise'],
        jobId = map['job'],
        type = map['type'],
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
      'type': type,
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
    String? type,
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
        type: type ?? this.type,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        date: date ?? this.date,
        id: id ?? this.id,
      );

  String get title => "Année ${date.start.year}-${date.end.year}. $type";

  final String teacherId;
  final String enterpriseId;
  final String jobId;

  final String type;

  final String name;
  final String phone;
  final String email;

  final DateTimeRange date;
}
