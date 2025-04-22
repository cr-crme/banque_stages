import 'package:common/exceptions.dart';
import 'package:common/models/internships/internship_evaluation_attitude.dart';
import 'package:common/models/internships/internship_evaluation_skill.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

double _doubleFromSerialized(num? number, {double defaultValue = 0}) {
  if (number is int) return number.toDouble();
  return (number ?? defaultValue) as double;
}

List<String> _stringListFromSerialized(List? list) {
  if (list == null ||
      list.isEmpty ||
      (list.length == 1 && list[0] == 'EMPTY')) {
    return [];
  }
  return list.map<String>((e) => e).toList();
}

List _serializeList(List list) {
  if (list.isEmpty) return ['EMPTY'];
  return list;
}

class PostInternshipEnterpriseEvaluation extends ItemSerializable {
  PostInternshipEnterpriseEvaluation({
    super.id,
    required this.internshipId,
    required this.skillsRequired,
    required this.taskVariety,
    required this.trainingPlanRespect,
    required this.autonomyExpected,
    required this.efficiencyExpected,
    required this.supervisionStyle,
    required this.easeOfCommunication,
    required this.absenceAcceptance,
    required this.supervisionComments,
    required this.acceptanceTsa,
    required this.acceptanceLanguageDisorder,
    required this.acceptanceIntellectualDisability,
    required this.acceptancePhysicalDisability,
    required this.acceptanceMentalHealthDisorder,
    required this.acceptanceBehaviorDifficulties,
  });

  PostInternshipEnterpriseEvaluation.fromSerialized(super.map)
      : internshipId = map['internshipId'] ?? '',
        skillsRequired = _stringListFromSerialized(map['skillsRequired']),
        taskVariety = _doubleFromSerialized(map['taskVariety']),
        trainingPlanRespect = _doubleFromSerialized(map['trainingPlanRespect']),
        autonomyExpected = _doubleFromSerialized(map['autonomyExpected']),
        efficiencyExpected = _doubleFromSerialized(map['efficiencyExpected']),
        supervisionStyle = _doubleFromSerialized(map['supervisionStyle']),
        easeOfCommunication = _doubleFromSerialized(map['easeOfCommunication']),
        absenceAcceptance = _doubleFromSerialized(map['absenceAcceptance']),
        supervisionComments = map['supervisionComments'] ?? '',
        acceptanceTsa = _doubleFromSerialized(map['acceptanceTSA']),
        acceptanceLanguageDisorder =
            _doubleFromSerialized(map['acceptanceLanguageDisorder']),
        acceptanceIntellectualDisability =
            _doubleFromSerialized(map['acceptanceIntellectualDisability']),
        acceptancePhysicalDisability =
            _doubleFromSerialized(map['acceptancePhysicalDisability']),
        acceptanceMentalHealthDisorder =
            _doubleFromSerialized(map['acceptanceMentalHealthDisorder']),
        acceptanceBehaviorDifficulties =
            _doubleFromSerialized(map['acceptanceBehaviorDifficulties']),
        super.fromSerialized();

  String internshipId;

  // Prerequisites
  final List<String> skillsRequired;

  // Tasks
  final double taskVariety;
  final double trainingPlanRespect;
  final double autonomyExpected;
  final double efficiencyExpected;

  // Management
  final double supervisionStyle;
  final double easeOfCommunication;
  final double absenceAcceptance;
  final String supervisionComments;

  // Supervision
  final double acceptanceTsa;
  final double acceptanceLanguageDisorder;
  final double acceptanceIntellectualDisability;
  final double acceptancePhysicalDisability;
  final double acceptanceMentalHealthDisorder;
  final double acceptanceBehaviorDifficulties;
  bool get hasDisorder =>
      acceptanceTsa >= 0 ||
      acceptanceLanguageDisorder >= 0 ||
      acceptanceIntellectualDisability >= 0 ||
      acceptancePhysicalDisability >= 0 ||
      acceptanceMentalHealthDisorder >= 0 ||
      acceptanceBehaviorDifficulties >= 0;

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'internshipId': internshipId,
        'skillsRequired': skillsRequired,
        'taskVariety': taskVariety,
        'trainingPlanRespect': trainingPlanRespect,
        'autonomyExpected': autonomyExpected,
        'efficiencyExpected': efficiencyExpected,
        'supervisionStyle': supervisionStyle,
        'easeOfCommunication': easeOfCommunication,
        'absenceAcceptance': absenceAcceptance,
        'supervisionComments': supervisionComments,
        'acceptanceTSA': acceptanceTsa,
        'acceptanceLanguageDisorder': acceptanceLanguageDisorder,
        'acceptanceIntellectualDisability': acceptanceIntellectualDisability,
        'acceptancePhysicalDisability': acceptancePhysicalDisability,
        'acceptanceMentalHealthDisorder': acceptanceMentalHealthDisorder,
        'acceptanceBehaviorDifficulties': acceptanceBehaviorDifficulties,
      };
}

class _MutableElements extends ItemSerializable {
  _MutableElements({
    required this.creationDate,
    required this.supervisorId,
    required this.dates,
    required this.weeklySchedules,
  });
  final DateTime creationDate;
  final String supervisorId;
  final DateTimeRange dates;
  final List<WeeklySchedule> weeklySchedules;

  _MutableElements.fromSerialized(super.map)
      : creationDate =
            DateTime.fromMillisecondsSinceEpoch(map['creation_date']),
        supervisorId = map['supervisor_id'] ?? -1,
        dates = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(map['starting_date']),
            end: DateTime.fromMillisecondsSinceEpoch(map['ending_date'])),
        weeklySchedules = (map['schedules'] as List)
            .map((e) => WeeklySchedule.fromSerialized(e))
            .toList(),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'creation_date': creationDate.millisecondsSinceEpoch,
        'supervisor_id': supervisorId,
        'starting_date': dates.start.millisecondsSinceEpoch,
        'ending_date': dates.end.millisecondsSinceEpoch,
        'schedules': weeklySchedules.map((e) => e.serialize()).toList(),
      };

  @override
  String toString() {
    return 'MutableElements{creationDate: $creationDate, '
        'supervisor_id: $supervisorId, '
        'dates: $dates, '
        'weeklySchedules: $weeklySchedules}';
  }
}

class Internship extends ItemSerializable {
  final String _currentVersion = '1.0.0';

  // Elements fixed across versions of the same stage
  final String studentId;
  final String signatoryTeacherId;
  final List<String> _extraSupervisingTeacherIds;
  List<String> get supervisingTeacherIds =>
      [signatoryTeacherId, ..._extraSupervisingTeacherIds];

  // void addSupervisingTeacher(context, {required String teacherId}) {
  //   // TODO Implement this method with an extension on App side

  //   if (teacherId == signatoryTeacherId ||
  //       _extraSupervisingTeacherIds.contains(teacherId)) {
  //     // If the teacher is already assigned, do nothing
  //     return;
  //   }

  //   // Make sure the student is in a group supervised by the teacher
  //   final students = StudentsProvider.allStudentsLimitedInfo(context);
  //   final student = students.firstWhere((e) => e.id == studentId);
  //   final teacher = TeachersProvider.of(context, listen: false)[teacherId];
  //   if (!teacher.groups.contains(student.group)) {
  //     throw Exception(
  //         'The teacher ${teacher.fullName} is not assigned to the group ${student.group}');
  //   }

  //   _extraSupervisingTeacherIds.add(teacherId);
  // }

  // TODO Add a call to the database?
  void removeSupervisingTeacher(String id) =>
      _extraSupervisingTeacherIds.remove(id);

  final String enterpriseId;
  final String jobId; // Main job attached to the enterprise
  final List<String>
      extraSpecializationIds; // Any extra jobs added to the internship
  final int expectedDuration;

  // Elements that can be modified (which increase the version number, but
  // do not require a completely new internship contract)
  final List<_MutableElements> _mutables;
  int get nbVersions => _mutables.length;
  DateTime get creationDate => _mutables.last.creationDate;
  DateTime creationDateFrom(int version) => _mutables[version].creationDate;
  String get supervisorId => _mutables.last.supervisorId;
  String supervisorFrom(int version) => _mutables[version].supervisorId;
  DateTimeRange get date => _mutables.last.dates;
  DateTimeRange dateFrom(int version) => _mutables[version].dates;
  List<WeeklySchedule> get weeklySchedules => _mutables.last.weeklySchedules;
  List<WeeklySchedule> weeklySchedulesFrom(int version) =>
      _mutables[version].weeklySchedules;

  // Elements that are parts of the inner working of the internship (can be
  // modify, but won't generate a new version)
  final int achievedDuration;
  final VisitingPriority visitingPriority;
  final String teacherNotes;
  final DateTime? endDate;
  final List<InternshipEvaluationSkill> _skillEvaluations;
  final List<InternshipEvaluationAttitude> _attitudeEvaluations;

  List<InternshipEvaluationSkill> get skillEvaluations =>
      _skillEvaluations.toList(growable: false);
  void addSkillEvaluation(InternshipEvaluationSkill evaluation) {
    // TODO Add a call to the database?
    _skillEvaluations.add(evaluation);
  }

  List<InternshipEvaluationAttitude> get attitudeEvaluations =>
      _attitudeEvaluations.toList(growable: false);
  void addAttitudeEvaluation(InternshipEvaluationAttitude evaluation) {
    // TODO Add a call to the database?
    _attitudeEvaluations.add(evaluation);
  }

  // PostInternshipEnterpriseEvaluation? enterpriseEvaluation;

  // bool get isClosed => isNotActive && !isEnterpriseEvaluationPending;
  // bool get isEnterpriseEvaluationPending =>
  //     isNotActive && enterpriseEvaluation == null;
  bool get isActive => endDate == null;
  bool get isNotActive => !isActive;
  bool get shouldTerminate =>
      isActive && date.end.difference(DateTime.now()).inDays <= -1;

  Internship._({
    required super.id,
    required this.studentId,
    required this.signatoryTeacherId,
    required List<String> extraSupervisingTeacherIds,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationIds,
    required List<_MutableElements> mutables,
    required this.expectedDuration,
    required this.achievedDuration,
    required this.visitingPriority,
    required this.teacherNotes,
    required this.endDate,
    required List<InternshipEvaluationSkill> skillEvaluations,
    required List<InternshipEvaluationAttitude> attitudeEvaluations,
    // required this.enterpriseEvaluation,
  })  : _mutables = mutables,
        _extraSupervisingTeacherIds = extraSupervisingTeacherIds,
        _skillEvaluations = skillEvaluations,
        _attitudeEvaluations = attitudeEvaluations {
    _extraSupervisingTeacherIds.remove(signatoryTeacherId);
  }

  Internship({
    super.id,
    required this.studentId,
    required this.signatoryTeacherId,
    required List<String> extraSupervisingTeacherIds,
    required this.enterpriseId,
    required this.jobId,
    required this.extraSpecializationIds,
    required DateTime creationDate,
    required String supervisorId,
    required DateTimeRange dates,
    required List<WeeklySchedule> weeklySchedules,
    required this.expectedDuration,
    required this.achievedDuration,
    required this.visitingPriority,
    this.teacherNotes = '',
    this.endDate,
    List<InternshipEvaluationSkill> skillEvaluations = const [],
    List<InternshipEvaluationAttitude> attitudeEvaluations = const [],
    // this.enterpriseEvaluation,
  })  : _extraSupervisingTeacherIds = extraSupervisingTeacherIds,
        _mutables = [
          _MutableElements(
            creationDate: creationDate,
            supervisorId: supervisorId,
            dates: dates,
            weeklySchedules: weeklySchedules,
          )
        ],
        _skillEvaluations = [...skillEvaluations],
        _attitudeEvaluations = [...attitudeEvaluations] {
    _extraSupervisingTeacherIds.remove(signatoryTeacherId);
  }

  Internship.fromSerialized(super.map)
      : studentId = map['student_id'] ?? '',
        signatoryTeacherId = map['signatory_teacher_id'] ?? '',
        _extraSupervisingTeacherIds =
            _stringListFromSerialized(map['extra_supervising_teacher_ids']),
        enterpriseId = map['enterprise_id'] ?? '',
        jobId = map['job_id'] ?? '',
        extraSpecializationIds =
            _stringListFromSerialized(map['extra_specialization_ids']),
        _mutables = (map['mutables'] as List?)
                ?.map(((e) => _MutableElements.fromSerialized(e)))
                .toList() ??
            [],
        expectedDuration = map['expected_duration'] ?? -1,
        achievedDuration = map['achieved_duration'] ?? -1,
        visitingPriority = map['priority'] == null
            ? VisitingPriority.notApplicable
            : VisitingPriority.values[map['priority']],
        teacherNotes = map['teacher_notes'] ?? '',
        endDate = map['end_date'] == null || map['end_date'] == -1
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['end_date']),
        _skillEvaluations = (map['skill_evaluations'] as List?)
                ?.map((e) => InternshipEvaluationSkill.fromSerialized(e))
                .toList() ??
            [],
        _attitudeEvaluations = (map['attitude_evaluations'] as List?)
                ?.map((e) => InternshipEvaluationAttitude.fromSerialized(e))
                .toList() ??
            [],
        // enterpriseEvaluation = map['enterpriseEvaluation'] == null ||
        //         map['enterpriseEvaluation'] == -1
        //     ? null
        //     : PostInternshipEnterpriseEvaluation.fromSerialized(
        //         map['enterpriseEvaluation']),
        super.fromSerialized() {
    _extraSupervisingTeacherIds.remove(signatoryTeacherId);
  }

  @override
  Map<String, dynamic> serializedMap() => {
        'version': _currentVersion,
        'student_id': studentId,
        'signatory_teacher_id': signatoryTeacherId,
        'extra_supervising_teacher_ids':
            _serializeList(_extraSupervisingTeacherIds),
        'enterprise_id': enterpriseId,
        'job_id': jobId,
        'extra_specialization_ids': _serializeList(extraSpecializationIds),
        'mutables': _mutables.map((e) => e.serialize()).toList(),
        'expected_duration': expectedDuration,
        'achieved_duration': achievedDuration,
        'priority': visitingPriority.index,
        'teacher_notes': teacherNotes,
        'end_date': endDate?.millisecondsSinceEpoch ?? -1,
        'skill_evaluations':
            _skillEvaluations.map((e) => e.serialize()).toList(),
        'attitude_evaluations':
            _attitudeEvaluations.map((e) => e.serialize()).toList(),
        // 'enterpriseEvaluation': enterpriseEvaluation?.serialize() ?? -1,
      };

  void addVersion({
    required DateTime creationDate,
    required String supervisorId,
    required DateTimeRange dates,
    required List<WeeklySchedule> weeklySchedules,
  }) {
    _mutables.add(_MutableElements(
      creationDate: creationDate,
      supervisorId: supervisorId,
      dates: dates,
      weeklySchedules: weeklySchedules,
    ));
  }

  Internship copyWith({
    String? id,
    String? studentId,
    String? signatoryTeacherId,
    List<String>? extraSupervisingTeacherIds,
    String? enterpriseId,
    String? jobId,
    List<String>? extraSpecializationIds,
    int? expectedDuration,
    int? achievedDuration,
    VisitingPriority? visitingPriority,
    String? teacherNotes,
    DateTime? endDate,
    List<InternshipEvaluationSkill>? skillEvaluations,
    List<InternshipEvaluationAttitude>? attitudeEvaluations,
    PostInternshipEnterpriseEvaluation? enterpriseEvaluation,
  }) {
    return Internship._(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      signatoryTeacherId: signatoryTeacherId ?? this.signatoryTeacherId,
      extraSupervisingTeacherIds:
          extraSupervisingTeacherIds ?? _extraSupervisingTeacherIds,
      enterpriseId: enterpriseId ?? this.enterpriseId,
      jobId: jobId ?? this.jobId,
      extraSpecializationIds:
          extraSpecializationIds ?? this.extraSpecializationIds,
      mutables: _mutables,
      expectedDuration: expectedDuration ?? this.expectedDuration,
      achievedDuration: achievedDuration ?? this.achievedDuration,
      visitingPriority: visitingPriority ?? this.visitingPriority,
      teacherNotes: teacherNotes ?? this.teacherNotes,
      endDate: endDate ?? this.endDate,
      skillEvaluations: skillEvaluations?.toList() ?? this.skillEvaluations,
      attitudeEvaluations:
          attitudeEvaluations?.toList() ?? this.attitudeEvaluations,
      // enterpriseEvaluation: enterpriseEvaluation ?? this.enterpriseEvaluation,
    );
  }

  Internship copyWithData(Map<String, dynamic> data) {
    final availableFields = [
      'version',
      'id',
      'student_id',
      'signatory_teacher_id',
      'extra_supervising_teacher_ids',
      'enterprise_id',
      'job_id',
      'extra_specialization_ids',
      'mutables',
      'expected_duration',
      'achieved_duration',
      'priority',
      'teacher_notes',
      'end_date',
      'skill_evaluations',
      'attitude_evaluations',
    ];
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => !availableFields.contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }

    final version = data['version'];
    if (version == null) {
      throw InvalidFieldException('Version field is required');
    } else if (version != '1.0.0') {
      throw WrongVersionException(version, _currentVersion);
    }

    return Internship._(
      id: data['id']?.toString() ?? id,
      studentId: data['student_id'] ?? studentId,
      signatoryTeacherId: data['signatory_teacher_id'] ?? signatoryTeacherId,
      extraSupervisingTeacherIds:
          _stringListFromSerialized(data['extra_supervising_teacher_ids']),
      enterpriseId: data['enterprise_id'] ?? enterpriseId,
      jobId: data['job_id'] ?? jobId,
      extraSpecializationIds:
          _stringListFromSerialized(data['extra_specialization_ids']),
      mutables: (data['mutables'] as List?)
              ?.map(((e) => _MutableElements.fromSerialized(e)))
              .toList() ??
          _mutables,
      expectedDuration: data['expected_duration'] ?? expectedDuration,
      achievedDuration: data['achieved_duration'] ?? achievedDuration,
      visitingPriority: data['priority'] == null
          ? visitingPriority
          : VisitingPriority.values[data['priority']],
      teacherNotes: data['teacher_notes'] ?? teacherNotes,
      endDate: data['end_date'] == null || data['end_date'] == -1
          ? null
          : DateTime.fromMillisecondsSinceEpoch(data['end_date']),
      skillEvaluations: (data['skill_evaluations'] as List?)
              ?.map((e) => InternshipEvaluationSkill.fromSerialized(e))
              .toList() ??
          skillEvaluations,
      attitudeEvaluations: (data['attitude_evaluations'] as List?)
              ?.map((e) => InternshipEvaluationAttitude.fromSerialized(e))
              .toList() ??
          attitudeEvaluations,
    );
  }

  @override
  String toString() {
    return 'Internship{studentId: $studentId, '
        'signatoryTeacherId: $signatoryTeacherId, '
        'extraSupervisingTeacherIds: $_extraSupervisingTeacherIds, '
        'enterpriseId: $enterpriseId, '
        'jobId: $jobId, '
        'extraSpecializationIds: $extraSpecializationIds, '
        'mutables: $_mutables, '
        'expectedDuration: $expectedDuration days, '
        'achievedDuration: $achievedDuration, '
        'visitingPriority: $visitingPriority, '
        'teacherNotes: $teacherNotes, '
        'endDate: $endDate, '
        'skillEvaluations: $skillEvaluations, '
        'attitudeEvaluations: $attitudeEvaluations, '
        // 'enterpriseEvaluation: $enterpriseEvaluation'
        '}';
  }
}
