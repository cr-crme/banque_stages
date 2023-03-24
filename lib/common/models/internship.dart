import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

import '/common/models/person.dart';
import '/common/models/visiting_priority.dart';
import 'schedule.dart';

class Internship extends ItemSerializable {
  final String studentId;
  final String teacherId;
  final String previousTeacherId; // Keep track of teacherId while transfering
  final bool isTransfering;

  final String enterpriseId;
  final String jobId; // Main job attached to the enterprise
  final List<String> extraJobsId; // Any extra jobs added to the internship
  final String program;
  final Person supervisor;
  final DateTimeRange date;
  final List<Schedule> schedule;

  final List<String> protection;
  final String uniform;

  final VisitingPriority visitingPriority;
  final String teacherNotes;

  Internship({
    super.id,
    required this.studentId,
    required this.teacherId,
    String? previousTeacherId,
    this.isTransfering = false,
    required this.enterpriseId,
    required this.jobId,
    required this.extraJobsId,
    required this.program,
    required this.supervisor,
    required this.date,
    required this.schedule,
    required this.protection,
    required this.uniform,
    required this.visitingPriority,
    this.teacherNotes = '',
  }) : previousTeacherId = previousTeacherId ?? teacherId;

  Internship.fromSerialized(map)
      : studentId = map['student'],
        teacherId = map['teacherId'],
        previousTeacherId = map['previousTeacherId'],
        isTransfering = map['isTransfering'],
        enterpriseId = map['enterprise'],
        jobId = map['jobId'],
        extraJobsId = map['extraJobsId'] ?? [],
        program = map['program'],
        supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
            start: DateTime.parse(map['date'][0]),
            end: DateTime.parse(map['date'][1])),
        schedule = (map['schedule'] as List)
            .map<Schedule>((e) => Schedule.fromSerialized(e))
            .toList(),
        protection = ItemSerializable.listFromSerialized(map['protection']),
        uniform = map['uniform'],
        visitingPriority = VisitingPriority.values[map['priority']],
        teacherNotes = map['teacherNotes'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'student': studentId,
      'teacherId': teacherId,
      'previousTeacherId': previousTeacherId,
      'isTransfering': isTransfering,
      'enterprise': enterpriseId,
      'jobId': jobId,
      'extraJobsId': extraJobsId,
      'program': program,
      'name': supervisor.serializedMap(),
      'date': [date.start.toString(), date.end.toString()],
      'schedule': schedule.map<Map>((e) => e.serializedMap()).toList(),
      'protection': protection,
      'uniform': uniform,
      'priority': visitingPriority.index,
      'teacherNotes': teacherNotes,
    };
  }

  Internship copyWith({
    String? id,
    String? studentId,
    String? teacherId,
    String? previousTeacherId,
    bool? isTransfering,
    String? enterpriseId,
    String? jobId,
    List<String>? extraJobsId,
    String? program,
    Person? supervisor,
    DateTimeRange? date,
    List<Schedule>? schedule,
    List<String>? protection,
    String? uniform,
    VisitingPriority? visitingPriority,
    String? teacherNotes,
  }) =>
      Internship(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        teacherId: teacherId ?? this.teacherId,
        previousTeacherId: previousTeacherId ?? this.previousTeacherId,
        isTransfering: isTransfering ?? this.isTransfering,
        enterpriseId: enterpriseId ?? this.enterpriseId,
        jobId: jobId ?? this.jobId,
        extraJobsId: extraJobsId ?? this.extraJobsId,
        program: program ?? this.program,
        supervisor: supervisor ?? this.supervisor,
        date: date ?? this.date,
        schedule: schedule ?? this.schedule,
        protection: protection ?? this.protection,
        uniform: uniform ?? this.uniform,
        visitingPriority: visitingPriority ?? this.visitingPriority,
        teacherNotes: teacherNotes ?? this.teacherNotes,
      );
}
