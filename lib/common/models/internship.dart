import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

import '/common/models/person.dart';
import '/common/models/visiting_priority.dart';
import 'schedule.dart';

class _MutableElements extends ItemSerializable {
  _MutableElements({
    required this.supervisor,
    required this.date,
    required this.weeklySchedules,
    required this.protections,
    required this.uniform,
  });
  final Person supervisor;
  final DateTimeRange date;
  final List<WeeklySchedule> weeklySchedules;
  final List<String> protections;
  final String uniform;

  _MutableElements.fromSerialized(map)
      : supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
            start: DateTime.parse(map['date'][0]),
            end: DateTime.parse(map['date'][1])),
        weeklySchedules = (map['schedule'] as List)
            .map((e) => WeeklySchedule.fromSerialized(e))
            .toList(),
        protections = ItemSerializable.listFromSerialized(map['protections']),
        uniform = map['uniform'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'name': supervisor.serializedMap(),
        'date': [date.start.toString(), date.end.toString()],
        'schedule': weeklySchedules.map((e) => e.serializedMap()).toList(),
        'protections': protections,
        'uniform': uniform,
      };
}

class Internship extends ItemSerializable {
  // Elements fixed across versions of the same stage
  final String studentId;
  final String teacherId;

  final String enterpriseId;
  final String jobId; // Main job attached to the enterprise
  final List<String>
      extraSpecializationId; // Any extra jobs added to the internship
  final int expectedLength;

  // Elements that can be modified (which increase the version number, but
  // do not require a completely new internship contract)
  final List<_MutableElements> _mutables;
  Person get supervisor => _mutables.last.supervisor;
  DateTimeRange get date => _mutables.last.date;
  List<WeeklySchedule> get weeklySchedules => _mutables.last.weeklySchedules;
  List<String> get protections => _mutables.last.protections;
  String get uniform => _mutables.last.uniform;

  // Elements that are parts of the inner working of the internship (can be
  // modify, but won't generate a new version)
  final int achievedLength;
  final String previousTeacherId; // Keep track of teacherId while transfering
  final bool isTransfering;
  final VisitingPriority visitingPriority;
  final String teacherNotes;

  final bool isClosed; // Finished and evaluation is done
  bool get isEvaluationPending =>
      !isClosed && DateTime.now().compareTo(date.end) >= 0;
  bool get isActive => !isClosed && DateTime.now().compareTo(date.end) < 0;

  Internship._({
    required super.id,
    required this.studentId,
    required this.teacherId,
    required this.previousTeacherId,
    required this.isTransfering,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationId,
    required List<_MutableElements> mutables,
    required this.expectedLength,
    required this.achievedLength,
    required this.visitingPriority,
    required this.teacherNotes,
    required this.isClosed,
  }) : _mutables = mutables;

  Internship({
    super.id,
    required this.studentId,
    required this.teacherId,
    String? previousTeacherId,
    this.isTransfering = false,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationId,
    required Person supervisor,
    required DateTimeRange date,
    required List<WeeklySchedule> weeklySchedules,
    required List<String> protections,
    required String uniform,
    required this.expectedLength,
    required this.achievedLength,
    required this.visitingPriority,
    this.teacherNotes = '',
    required this.isClosed,
  })  : previousTeacherId = previousTeacherId ?? teacherId,
        _mutables = [
          _MutableElements(
              supervisor: supervisor,
              date: date,
              weeklySchedules: weeklySchedules,
              protections: protections,
              uniform: uniform)
        ];

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
        _mutables = (map['mutables'] as List)
            .map(((e) => _MutableElements.fromSerialized(e)))
            .toList(),
        expectedLength = map['expectedLength'],
        achievedLength = map['achievedLength'],
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
      'mutables': _mutables.map((e) => e.serializedMap()).toList(),
      'expectedLength': expectedLength,
      'achievedLength': achievedLength,
      'priority': visitingPriority.index,
      'teacherNotes': teacherNotes,
      'isClosed': isClosed,
    };
  }

  void addVersion({
    required Person supervisor,
    required DateTimeRange date,
    required List<WeeklySchedule> weeklySchedules,
    required List<String> protections,
    required String uniform,
  }) {
    _mutables.add(_MutableElements(
        supervisor: supervisor,
        date: date,
        weeklySchedules: weeklySchedules,
        protections: protections,
        uniform: uniform));
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
    List<String>? protections,
    String? uniform,
    int? expectedLength,
    int? achievedLength,
    VisitingPriority? visitingPriority,
    String? teacherNotes,
    bool? isClosed,
  }) {
    if (supervisor != null ||
        date != null ||
        weeklySchedules != null ||
        protections != null ||
        uniform != null) {
      throw '[supervisor], [date], [weeklySchedules], [protections] or [uniform] '
          'should not be changed via [copyWith], but using [addVersion]';
    }
    return Internship._(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      previousTeacherId: previousTeacherId ?? this.previousTeacherId,
      isTransfering: isTransfering ?? this.isTransfering,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      jobId: jobId ?? this.jobId,
      extraSpecializationId:
          extraSpecializationId ?? this.extraSpecializationId,
      mutables: _mutables,
      expectedLength: expectedLength ?? this.expectedLength,
      achievedLength: achievedLength ?? this.achievedLength,
      visitingPriority: visitingPriority ?? this.visitingPriority,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}
