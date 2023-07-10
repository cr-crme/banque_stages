import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'internship_evaluation_attitude.dart';
import 'internship_evaluation_skill.dart';
import 'protections.dart';
import 'schedule.dart';

double _doubleFromSerialized(num? number, {double defaultValue = 0}) {
  if (number is int) return number.toDouble();
  return (number ?? defaultValue) as double;
}

List<String> _stringListFromSerialized(List? list) =>
    (list ?? []).map<String>((e) => e).toList();

class PostIntershipEnterpriseEvaluation extends ItemSerializable {
  PostIntershipEnterpriseEvaluation({
    required this.internshipId,
    required this.taskVariety,
    required this.skillsRequired,
    required this.autonomyExpected,
    required this.efficiencyWanted,
    required this.welcomingTsa,
    required this.welcomingCommunication,
    required this.welcomingMentalDeficiency,
    required this.welcomingMentalHealthIssue,
    required this.minimalAge,
    required this.requirements,
  });

  PostIntershipEnterpriseEvaluation.fromSerialized(map)
      : internshipId = map['internshipId'],
        taskVariety = _doubleFromSerialized(map['taskVariety']),
        skillsRequired = _stringListFromSerialized(map['skillsRequired']),
        autonomyExpected = _doubleFromSerialized(map['autonomyExpected']),
        efficiencyWanted = _doubleFromSerialized(map['efficiencyWanted']),
        welcomingTsa = _doubleFromSerialized(map['welcomingTSA']),
        welcomingCommunication =
            _doubleFromSerialized(map['welcomingCommunication']),
        welcomingMentalDeficiency =
            _doubleFromSerialized(map['welcomingMentalDeficiency']),
        welcomingMentalHealthIssue =
            _doubleFromSerialized(map['welcomingMentalHealthIssue']),
        minimalAge = map['minimalAge'],
        requirements = _stringListFromSerialized(map['requirements']);

  String internshipId;

  // Tasks
  final double taskVariety;
  final List<String> skillsRequired;
  final double autonomyExpected;
  final double efficiencyWanted;

  // Supervision
  final double welcomingTsa;
  final double welcomingCommunication;
  final double welcomingMentalDeficiency;
  final double welcomingMentalHealthIssue;

  // Prerequisites
  final int minimalAge;
  final List<String> requirements;

  @override
  Map<String, dynamic> serializedMap() => {
        'internshipId': internshipId,
        'taskVariety': taskVariety,
        'skillsRequired': skillsRequired,
        'autonomyExpected': autonomyExpected,
        'efficiencyWanted': efficiencyWanted,
        'welcomingTSA': welcomingTsa,
        'welcomingCommunication': welcomingCommunication,
        'welcomingMentalDeficiency': welcomingMentalDeficiency,
        'welcomingMentalHealthIssue': welcomingMentalHealthIssue,
        'minimalAge': minimalAge,
        'requirements': requirements,
      };

  PostIntershipEnterpriseEvaluation deepCopy() {
    return PostIntershipEnterpriseEvaluation(
        internshipId: internshipId,
        taskVariety: taskVariety,
        skillsRequired: [for (final skill in skillsRequired) skill],
        autonomyExpected: autonomyExpected,
        efficiencyWanted: efficiencyWanted,
        welcomingTsa: welcomingTsa,
        welcomingCommunication: welcomingCommunication,
        welcomingMentalDeficiency: welcomingMentalDeficiency,
        welcomingMentalHealthIssue: welcomingMentalHealthIssue,
        minimalAge: minimalAge,
        requirements: [for (final requirement in requirements) requirement]);
  }
}

class _MutableElements extends ItemSerializable {
  _MutableElements({
    required this.versionDate,
    required this.supervisor,
    required this.date,
    required this.weeklySchedules,
    required this.protections,
    required this.uniform,
  });
  final DateTime versionDate;
  final Person supervisor;
  final DateTimeRange date;
  final List<WeeklySchedule> weeklySchedules;
  // TODO Aurelie - Confirm protections and uniform should be moved out
  final Protections protections;
  final Uniform uniform;

  _MutableElements.fromSerialized(map)
      : versionDate = DateTime.fromMillisecondsSinceEpoch(map['versionDate']),
        supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(map['date'][0]),
            end: DateTime.fromMillisecondsSinceEpoch(map['date'][1])),
        weeklySchedules = (map['schedule'] as List)
            .map((e) => WeeklySchedule.fromSerialized(e))
            .toList(),
        protections = Protections.fromSerialized(map['protections']),
        uniform = Uniform.fromSerialized(map['uniform']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'versionDate': versionDate.millisecondsSinceEpoch,
        'name': supervisor.serializedMap(),
        'date': [
          date.start.millisecondsSinceEpoch,
          date.end.millisecondsSinceEpoch
        ],
        'schedule': weeklySchedules.map((e) => e.serializedMap()).toList(),
        'protections': protections.serializedMap(),
        'uniform': uniform.serializedMap(),
      };

  _MutableElements deepCopy() {
    return _MutableElements(
        versionDate: DateTime.fromMillisecondsSinceEpoch(
            versionDate.millisecondsSinceEpoch),
        supervisor: supervisor.deepCopy(),
        date: DateTimeRange(start: date.start, end: date.end),
        weeklySchedules: weeklySchedules.map((e) => e.deepCopy()).toList(),
        protections: protections.deepCopy(),
        uniform: uniform);
  }
}

class Internship extends ItemSerializable {
  // Elements fixed across versions of the same stage
  final String studentId;
  final String teacherId;

  final String enterpriseId;
  final String jobId; // Main job attached to the enterprise
  final List<String>
      extraSpecializationsId; // Any extra jobs added to the internship
  final int expectedLength;

  // Elements that can be modified (which increase the version number, but
  // do not require a completely new internship contract)
  final List<_MutableElements> _mutables;
  int get nbVersions => _mutables.length;
  DateTime get versionDate => _mutables.last.versionDate;
  DateTime versionDateFrom(int version) => _mutables[version].versionDate;
  Person get supervisor => _mutables.last.supervisor;
  Person supervisorFrom(int version) => _mutables[version].supervisor;
  DateTimeRange get date => _mutables.last.date;
  DateTimeRange dateFrom(int version) => _mutables[version].date;
  List<WeeklySchedule> get weeklySchedules => _mutables.last.weeklySchedules;
  List<WeeklySchedule> weeklySchedulesFrom(int version) =>
      _mutables[version].weeklySchedules;
  Protections get protections => _mutables.last.protections;
  Protections protectionsFrom(int version) => _mutables[version].protections;
  Uniform get uniform => _mutables.last.uniform;
  Uniform uniformFrom(int version) => _mutables[version].uniform;

  // Elements that are parts of the inner working of the internship (can be
  // modify, but won't generate a new version)
  final int achievedLength;
  final String previousTeacherId; // Keep track of teacherId while transfering
  final bool isTransfering;
  final VisitingPriority visitingPriority;
  final String teacherNotes;
  final DateTime? endDate;
  final List<InternshipEvaluationSkill> skillEvaluations;
  final List<InternshipEvaluationAttitude> attitudeEvaluations;

  PostIntershipEnterpriseEvaluation? enterpriseEvaluation;

  bool get isClosed => isNotActive && !isEnterpriseEvaluationPending;
  bool get isEnterpriseEvaluationPending =>
      isNotActive && enterpriseEvaluation == null;
  bool get isActive => endDate == null;
  bool get isNotActive => !isActive;

  Internship._({
    required super.id,
    required this.studentId,
    required this.teacherId,
    required this.previousTeacherId,
    required this.isTransfering,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationsId,
    required List<_MutableElements> mutables,
    required this.expectedLength,
    required this.achievedLength,
    required this.visitingPriority,
    required this.teacherNotes,
    required this.endDate,
    required this.skillEvaluations,
    required this.attitudeEvaluations,
    required this.enterpriseEvaluation,
  }) : _mutables = mutables;

  Internship({
    super.id,
    required this.studentId,
    required this.teacherId,
    String? previousTeacherId,
    this.isTransfering = false,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationsId,
    required DateTime versionDate,
    required Person supervisor,
    required DateTimeRange date,
    required List<WeeklySchedule> weeklySchedules,
    required Protections protections,
    required Uniform uniform,
    required this.expectedLength,
    required this.achievedLength,
    required this.visitingPriority,
    this.teacherNotes = '',
    this.endDate,
    this.skillEvaluations = const [],
    this.attitudeEvaluations = const [],
    this.enterpriseEvaluation,
  })  : previousTeacherId = previousTeacherId ?? teacherId,
        _mutables = [
          _MutableElements(
              versionDate: versionDate,
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
        extraSpecializationsId = map['extraSpecializationsId'] == -1
            ? []
            : (map['extraSpecializationsId'] as List)
                .map((e) => e as String)
                .toList(),
        _mutables = (map['mutables'] as List)
            .map(((e) => _MutableElements.fromSerialized(e)))
            .toList(),
        expectedLength = map['expectedLength'],
        achievedLength = map['achievedLength'],
        visitingPriority = VisitingPriority.values[map['priority']],
        teacherNotes = map['teacherNotes'],
        endDate = map['endDate'] == -1
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['endDate']),
        skillEvaluations = map['skillEvaluation'] == null
            ? []
            : (map['skillEvaluation'] as List)
                .map((e) => InternshipEvaluationSkill.fromSerialized(e))
                .toList(),
        attitudeEvaluations = map['attitudeEvaluation'] == null
            ? []
            : (map['attitudeEvaluation'] as List)
                .map((e) => InternshipEvaluationAttitude.fromSerialized(e))
                .toList(),
        enterpriseEvaluation = map['enterpriseEvaluation'] == null
            ? null
            : PostIntershipEnterpriseEvaluation.fromSerialized(
                map['enterpriseEvaluation']),
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
      'extraSpecializationsId':
          extraSpecializationsId.isEmpty ? -1 : extraSpecializationsId,
      'mutables': _mutables.map((e) => e.serializedMap()).toList(),
      'expectedLength': expectedLength,
      'achievedLength': achievedLength,
      'priority': visitingPriority.index,
      'teacherNotes': teacherNotes,
      'endDate': endDate?.millisecondsSinceEpoch ?? -1,
      'skillEvaluation':
          skillEvaluations.map((e) => e.serializedMap()).toList(),
      'attitudeEvaluation':
          attitudeEvaluations.map((e) => e.serializedMap()).toList(),
      'enterpriseEvaluation': enterpriseEvaluation?.serialize(),
    };
  }

  void addVersion({
    required DateTime versionDate,
    required Person supervisor,
    required DateTimeRange date,
    required List<WeeklySchedule> weeklySchedules,
    required Protections protections,
    required Uniform uniform,
  }) {
    _mutables.add(_MutableElements(
        versionDate: versionDate,
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
    List<String>? extraSpecializationsId,
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
    DateTime? endDate,
    List<InternshipEvaluationSkill>? skillEvaluations,
    List<InternshipEvaluationAttitude>? attitudeEvaluations,
    PostIntershipEnterpriseEvaluation? enterpriseEvaluation,
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
      extraSpecializationsId:
          extraSpecializationsId ?? this.extraSpecializationsId,
      mutables: _mutables,
      expectedLength: expectedLength ?? this.expectedLength,
      achievedLength: achievedLength ?? this.achievedLength,
      visitingPriority: visitingPriority ?? this.visitingPriority,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      endDate: endDate ?? this.endDate,
      skillEvaluations: skillEvaluations ?? this.skillEvaluations,
      attitudeEvaluations: attitudeEvaluations ?? this.attitudeEvaluations,
      enterpriseEvaluation: enterpriseEvaluation ?? this.enterpriseEvaluation,
    );
  }

  Internship deepCopy() {
    return Internship._(
      id: id,
      studentId: studentId,
      teacherId: teacherId,
      previousTeacherId: previousTeacherId,
      isTransfering: isTransfering,
      enterpriseId: enterpriseId,
      jobId: jobId,
      extraSpecializationsId: extraSpecializationsId.map((e) => e).toList(),
      mutables: _mutables.map((e) => e).toList(),
      expectedLength: expectedLength,
      achievedLength: achievedLength,
      visitingPriority: VisitingPriority.values[visitingPriority.index],
      teacherNotes: teacherNotes,
      endDate: endDate == null
          ? null
          : DateTime(
              endDate!.year,
              endDate!.month,
              endDate!.day,
            ),
      skillEvaluations: skillEvaluations.map((e) => e.deepCopy()).toList(),
      attitudeEvaluations:
          attitudeEvaluations.map((e) => e.deepCopy()).toList(),
      enterpriseEvaluation: enterpriseEvaluation?.deepCopy(),
    );
  }
}
