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
  final List<String>
      extraSpecializationId; // Any extra jobs added to the internship
  final Person supervisor;
  final DateTimeRange date;

  // The inner list is a semester schedule.
  // The outer list is if there are multiple schedules during a semester
  final List<WeeklySchedule> weeklySchedules;

  final List<String> protection;
  final String uniform;

  final VisitingPriority visitingPriority;
  final String teacherNotes;

  final bool isClosed; // Finished and evaluation is done
  bool get isEvaluationPending =>
      !isClosed && DateTime.now().compareTo(date.end) >= 0;
  bool get isActive => !isClosed && DateTime.now().compareTo(date.end) < 0;

  Internship({
    super.id,
    required this.studentId,
    required this.teacherId,
    String? previousTeacherId,
    this.isTransfering = false,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationId,
    required this.supervisor,
    required this.date,
    required this.weeklySchedules,
    required this.protection,
    required this.uniform,
    required this.visitingPriority,
    this.teacherNotes = '',
    required this.isClosed,
  }) : previousTeacherId = previousTeacherId ?? teacherId;

  Internship.fromSerialized(map)
      : studentId = map['student'],
        teacherId = map['teacherId'],
        previousTeacherId = map['previousTeacherId'],
        isTransfering = map['isTransfering'],
        enterpriseId = map['enterprise'],
        jobId = map['jobId'],
        extraSpecializationId = map['extraSpecializationId'] ?? [],
        supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
            start: DateTime.parse(map['date'][0]),
            end: DateTime.parse(map['date'][1])),
        weeklySchedules = (map['schedule'] as List)
            .map((e) => WeeklySchedule.fromSerialized(e))
            .toList(),
        protection = ItemSerializable.listFromSerialized(map['protection']),
        uniform = map['uniform'],
        visitingPriority = VisitingPriority.values[map['priority']],
        teacherNotes = map['teacherNotes'],
        isClosed = map['isClosed'],
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
      'extraSpecializationId': extraSpecializationId,
      'name': supervisor.serializedMap(),
      'date': [date.start.toString(), date.end.toString()],
      'schedule': weeklySchedules.map((e) => e.serializedMap()).toList(),
      'protection': protection,
      'uniform': uniform,
      'priority': visitingPriority.index,
      'teacherNotes': teacherNotes,
      'isClosed': isClosed,
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
    List<String>? extraSpecializationId,
    String? program,
    Person? supervisor,
    DateTimeRange? date,
    List<WeeklySchedule>? weeklySchedules,
    List<String>? protection,
    String? uniform,
    VisitingPriority? visitingPriority,
    String? teacherNotes,
    bool? isClosed,
  }) =>
      Internship(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        teacherId: teacherId ?? this.teacherId,
        previousTeacherId: previousTeacherId ?? this.previousTeacherId,
        isTransfering: isTransfering ?? this.isTransfering,
        enterpriseId: enterpriseId ?? this.enterpriseId,
        jobId: jobId ?? this.jobId,
        extraSpecializationId:
            extraSpecializationId ?? this.extraSpecializationId,
        supervisor: supervisor ?? this.supervisor,
        date: date ?? this.date,
        weeklySchedules: weeklySchedules ?? this.weeklySchedules,
        protection: protection ?? this.protection,
        uniform: uniform ?? this.uniform,
        visitingPriority: visitingPriority ?? this.visitingPriority,
        teacherNotes: teacherNotes ?? this.teacherNotes,
        isClosed: isClosed ?? this.isClosed,
      );
}
