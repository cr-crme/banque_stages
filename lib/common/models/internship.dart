import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

import '/common/models/person.dart';
import '/common/models/visiting_priority.dart';

class Internship extends ItemSerializable {
  final String studentId;
  final String teacherId;

  final String enterpriseId;
  final String jobId;
  final String type;
  final Person supervisor;
  final DateTimeRange date;

  final List<String> protection;
  final String uniform;

  final VisitingPriority visitingPriority;

  Internship({
    super.id,
    required this.studentId,
    required this.teacherId,
    required this.enterpriseId,
    required this.jobId,
    required this.type,
    required this.supervisor,
    required this.date,
    required this.protection,
    required this.uniform,
    required this.visitingPriority,
  });

  Internship.fromSerialized(map)
      : studentId = map['student'],
        teacherId = map['teacherId'],
        enterpriseId = map['enterprise'],
        jobId = map['job'],
        type = map['type'],
        supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
          start: DateTime.parse(map['start']),
          end: DateTime.parse(map['end']),
        ),
        protection = ItemSerializable.listFromSerialized(map['protection']),
        uniform = map['uniform'],
        visitingPriority = VisitingPriority.values[map['priority']],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'student': studentId,
      'teacherId': teacherId,
      'enterprise': enterpriseId,
      'job': jobId,
      'type': type,
      'name': supervisor.serializedMap(),
      'start': date.start.toString(),
      'end': date.end.toString(),
      'protection': protection,
      'uniform': uniform,
      'priority': visitingPriority.index,
    };
  }

  Internship copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    String? enterpriseId,
    String? jobId,
    String? type,
    Person? supervisor,
    DateTimeRange? date,
    List<String>? protection,
    String? uniform,
    VisitingPriority? visitingPriority,
  }) =>
      Internship(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        teacherId: teacherId ?? this.teacherId,
        enterpriseId: enterpriseId ?? this.enterpriseId,
        jobId: jobId ?? this.jobId,
        type: type ?? this.type,
        supervisor: supervisor ?? this.supervisor,
        date: date ?? this.date,
        protection: protection ?? this.protection,
        uniform: uniform ?? this.uniform,
        visitingPriority: visitingPriority ?? this.visitingPriority,
      );

  String get title => "Année ${date.start.year}-${date.end.year}. $type";
}
