import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

class Internship extends ItemSerializable {
  Internship({
    super.id,
    required this.teacherId,
    required this.studentId,
    required this.enterpriseId,
    required this.jobId,
    required this.type,
    required this.supervisorName,
    required this.supervisorPhone,
    required this.supervisorEmail,
    required this.date,
    required this.protection,
    required this.uniform,
  });

  Internship.fromSerialized(map)
      : teacherId = map['teacher'],
        studentId = map['student'],
        enterpriseId = map['enterprise'],
        jobId = map['job'],
        type = map['type'],
        supervisorName = map['name'],
        supervisorPhone = map['phone'],
        supervisorEmail = map['email'],
        date = DateTimeRange(
          start: DateTime.parse(map['start']),
          end: DateTime.parse(map['end']),
        ),
        protection = ItemSerializable.listFromSerialized(map['protection']),
        uniform = map['uniform'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'teacher': teacherId,
      'student': studentId,
      'enterprise': enterpriseId,
      'job': jobId,
      'type': type,
      'name': supervisorName,
      'phone': supervisorPhone,
      'email': supervisorEmail,
      'start': date.start.toString(),
      'end': date.end.toString(),
      'protection': protection,
      'uniform': uniform,
      'id': id,
    };
  }

  Internship copyWith({
    String? teacherId,
    String? studentId,
    String? enterpriseId,
    String? jobId,
    String? type,
    String? supervisorName,
    String? supervisorPhone,
    String? supervisorEmail,
    DateTimeRange? date,
    List<String>? protection,
    String? uniform,
    String? id,
  }) =>
      Internship(
        teacherId: teacherId ?? this.teacherId,
        studentId: studentId ?? this.studentId,
        enterpriseId: enterpriseId ?? this.enterpriseId,
        jobId: jobId ?? this.jobId,
        type: type ?? this.type,
        supervisorName: supervisorName ?? this.supervisorName,
        supervisorPhone: supervisorPhone ?? this.supervisorPhone,
        supervisorEmail: supervisorEmail ?? this.supervisorEmail,
        date: date ?? this.date,
        protection: protection ?? this.protection,
        uniform: uniform ?? this.uniform,
        id: id ?? this.id,
      );

  String get title => "Année ${date.start.year}-${date.end.year}. $type";

  final String studentId;
  final String teacherId;
  final String enterpriseId;
  final String jobId;

  final String type;

  final String supervisorName;
  final String supervisorPhone;
  final String supervisorEmail;

  final DateTimeRange date;

  final List<String> protection;
  final String uniform;
}
