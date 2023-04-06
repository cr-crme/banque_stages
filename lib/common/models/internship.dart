import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

import '/common/models/person.dart';
import '/common/models/visiting_priority.dart';
import 'schedule.dart';

class Internship extends ItemSerializable {
  // Elements fixed across versions of the same stage
  final String studentId;
  final String teacherId;

  final String enterpriseId;
  final String jobId; // Main job attached to the enterprise
  final List<String>
      extraSpecializationId; // Any extra jobs added to the internship
  final int length;

  // Elements that can be modified (which increase the version number, but
  // do not require a completely new internship contract)
  final Person supervisor;
  final DateTimeRange date;
  final List<WeeklySchedule> weeklySchedules;
  final List<String> protections;
  final String uniform;

  // Elements that are parts of the inner working of the internship
  final String previousTeacherId; // Keep track of teacherId while transfering
  final bool isTransfering;

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
    required this.length,
    required this.weeklySchedules,
    required this.protections,
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
        extraSpecializationId = map['extraSpecializationId'] == null
            ? []
            : (map['extraSpecializationId'] as List)
                .map((e) => e as String)
                .toList(),
        supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
            start: DateTime.parse(map['date'][0]),
            end: DateTime.parse(map['date'][1])),
        length = map['length'],
        weeklySchedules = (map['schedule'] as List)
            .map((e) => WeeklySchedule.fromSerialized(e))
            .toList(),
        protections = ItemSerializable.listFromSerialized(map['protections']),
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
      'length': length,
      'schedule': weeklySchedules.map((e) => e.serializedMap()).toList(),
      'protections': protections,
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
    int? length,
    List<WeeklySchedule>? weeklySchedules,
    List<String>? protections,
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
        length: length ?? this.length,
        weeklySchedules: weeklySchedules ?? this.weeklySchedules,
        protections: protections ?? this.protections,
        uniform: uniform ?? this.uniform,
        visitingPriority: visitingPriority ?? this.visitingPriority,
        teacherNotes: teacherNotes ?? this.teacherNotes,
        isClosed: isClosed ?? this.isClosed,
      );
}
