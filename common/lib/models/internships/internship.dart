import 'package:common/exceptions.dart';
import 'package:common/models/internships/internship_evaluation_attitude.dart';
import 'package:common/models/internships/internship_evaluation_skill.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/person.dart';
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
    required this.versionDate,
    required this.supervisor,
    required this.date,
    required this.weeklySchedules,
  });
  final DateTime versionDate;
  final Person supervisor;
  final DateTimeRange date;
  final List<WeeklySchedule> weeklySchedules;

  _MutableElements.fromSerialized(super.map)
      : versionDate = DateTime.fromMillisecondsSinceEpoch(map['versionDate']),
        supervisor = Person.fromSerialized(map['name']),
        date = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(map['date'][0]),
            end: DateTime.fromMillisecondsSinceEpoch(map['date'][1])),
        weeklySchedules = (map['schedule'] as List)
            .map((e) => WeeklySchedule.fromSerialized(e))
            .toList(),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'versionDate': versionDate.millisecondsSinceEpoch,
        'name': supervisor.serialize(),
        'date': [
          date.start.millisecondsSinceEpoch,
          date.end.millisecondsSinceEpoch
        ],
        'schedule': weeklySchedules.map((e) => e.serialize()).toList(),
      };
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

  // void removeSupervisingTeacher(String id) =>
  //     _extraSupervisingTeacherIds.remove(id);

  // final String enterpriseId;
  // final String jobId; // Main job attached to the enterprise
  // final List<String>
  //     extraSpecializationsId; // Any extra jobs added to the internship
  // final int expectedLength;

  // // Elements that can be modified (which increase the version number, but
  // // do not require a completely new internship contract)
  // final List<_MutableElements> _mutables;
  // int get nbVersions => _mutables.length;
  // DateTime get versionDate => _mutables.last.versionDate;
  // DateTime versionDateFrom(int version) => _mutables[version].versionDate;
  // Person get supervisor => _mutables.last.supervisor;
  // Person supervisorFrom(int version) => _mutables[version].supervisor;
  // DateTimeRange get date => _mutables.last.date;
  // DateTimeRange dateFrom(int version) => _mutables[version].date;
  // List<WeeklySchedule> get weeklySchedules => _mutables.last.weeklySchedules;
  // List<WeeklySchedule> weeklySchedulesFrom(int version) =>
  //     _mutables[version].weeklySchedules;

  // // Elements that are parts of the inner working of the internship (can be
  // // modify, but won't generate a new version)
  // final int achievedLength;
  // final VisitingPriority visitingPriority;
  // final String teacherNotes;
  // final DateTime? endDate;
  // final List<InternshipEvaluationSkill> skillEvaluations;
  // final List<InternshipEvaluationAttitude> attitudeEvaluations;

  // PostInternshipEnterpriseEvaluation? enterpriseEvaluation;

  // bool get isClosed => isNotActive && !isEnterpriseEvaluationPending;
  // bool get isEnterpriseEvaluationPending =>
  //     isNotActive && enterpriseEvaluation == null;
  // bool get isActive => endDate == null;
  // bool get isNotActive => !isActive;
  // bool get shouldTerminate =>
  //     isActive && date.end.difference(DateTime.now()).inDays <= -1;

  Internship._({
    required super.id,
    required this.studentId,
    required this.signatoryTeacherId,
    required List<String> extraSupervisingTeacherIds,
    // required this.enterpriseId,
    // required this.jobId,
    // required this.extraSpecializationsId,
    // required List<_MutableElements> mutables,
    // required this.expectedLength,
    // required this.achievedLength,
    // required this.visitingPriority,
    // required this.teacherNotes,
    // required this.endDate,
    // required this.skillEvaluations,
    // required this.attitudeEvaluations,
    // required this.enterpriseEvaluation,
  }) :
        //  _mutables = mutables,
        _extraSupervisingTeacherIds = extraSupervisingTeacherIds {
    _extraSupervisingTeacherIds.remove(signatoryTeacherId);
  }

  Internship({
    super.id,
    required this.studentId,
    required this.signatoryTeacherId,
    required List<String> extraSupervisingTeacherIds,
    // required this.enterpriseId,
    // required this.jobId,
    // required this.extraSpecializationsId,
    // required DateTime versionDate,
    // required Person supervisor,
    // required DateTimeRange date,
    // required List<WeeklySchedule> weeklySchedules,
    // required this.expectedLength,
    // required this.achievedLength,
    // required this.visitingPriority,
    // this.teacherNotes = '',
    // this.endDate,
    // this.skillEvaluations = const [],
    // this.attitudeEvaluations = const [],
    // this.enterpriseEvaluation,
  }) : _extraSupervisingTeacherIds = extraSupervisingTeacherIds
  // _mutables = [
  //   _MutableElements(
  //     versionDate: versionDate,
  //     supervisor: supervisor,
  //     date: date,
  //     weeklySchedules: weeklySchedules,
  //   )
  // ]
  {
    _extraSupervisingTeacherIds.remove(signatoryTeacherId);
  }

  Internship.fromSerialized(super.map)
      : studentId = map['student_id'] ?? '',
        signatoryTeacherId = map['signatory_teacher_id'] ?? '',
        _extraSupervisingTeacherIds =
            _stringListFromSerialized(map['extra_supervising_teacher_ids']),
        // enterpriseId = map['enterprise'] ?? '',
        // jobId = map['jobId'] ?? '',
        // extraSpecializationsId =
        //     _stringListFromSerialized(map['extraSpecializationsId']),
        // _mutables = (map['mutables'] as List?)
        //         ?.map(((e) => _MutableElements.fromSerialized(e)))
        //         .toList() ??
        //     [],
        // expectedLength = map['expectedLength'] ?? -1,
        // achievedLength = map['achievedLength'] ?? -1,
        // visitingPriority = map['priority'] == null
        //     ? VisitingPriority.notApplicable
        //     : VisitingPriority.values[map['priority']],
        // teacherNotes = map['teacherNotes'] ?? '',
        // endDate = map['endDate'] == null || map['endDate'] == -1
        //     ? null
        //     : DateTime.fromMillisecondsSinceEpoch(map['endDate']),
        // skillEvaluations = (map['skillEvaluation'] as List?)
        //         ?.map((e) => InternshipEvaluationSkill.fromSerialized(e))
        //         .toList() ??
        //     [],
        // attitudeEvaluations = (map['attitudeEvaluation'] as List?)
        //         ?.map((e) => InternshipEvaluationAttitude.fromSerialized(e))
        //         .toList() ??
        //     [],
        // enterpriseEvaluation = map['enterpriseEvaluation'] == null ||
        //         map['enterpriseEvaluation'] == -1
        //     ? null
        //     : PostInternshipEnterpriseEvaluation.fromSerialized(
        //         map['enterpriseEvaluation']),
        super.fromSerialized() {
    _extraSupervisingTeacherIds.remove(signatoryTeacherId);
    // _mutables.sort((a, b) => a.versionDate.compareTo(b.versionDate));
    // if (_mutables.isNotEmpty) {
    //   _mutables.last.weeklySchedules.sort((a, b) => a.start.compareTo(b.start));
    // }
  }

  @override
  Map<String, dynamic> serializedMap() => {
        'version': _currentVersion,
        'student_id': studentId,
        'signatory_teacher_id': signatoryTeacherId,
        'extra_supervising_teacher_ids':
            _serializeList(_extraSupervisingTeacherIds),
        // 'enterprise': enterpriseId,
        // 'jobId': jobId,
        // 'extraSpecializationsId': _serializeList(extraSpecializationsId),
        // 'mutables': _mutables.map((e) => e.serialize()).toList(),
        // 'expectedLength': expectedLength,
        // 'achievedLength': achievedLength,
        // 'priority': visitingPriority.index,
        // 'teacherNotes': teacherNotes,
        // 'endDate': endDate?.millisecondsSinceEpoch ?? -1,
        // 'skillEvaluation': skillEvaluations.map((e) => e.serialize()).toList(),
        // 'attitudeEvaluation':
        //     attitudeEvaluations.map((e) => e.serialize()).toList(),
        // 'enterpriseEvaluation': enterpriseEvaluation?.serialize() ?? -1,
      };

  void addVersion({
    required DateTime versionDate,
    required Person supervisor,
    required DateTimeRange date,
    required List<WeeklySchedule> weeklySchedules,
  }) {
    // _mutables.add(_MutableElements(
    //   versionDate: versionDate,
    //   supervisor: supervisor,
    //   date: date,
    //   weeklySchedules: weeklySchedules,
    // ));
  }

  Internship copyWith({
    String? id,
    String? studentId,
    String? signatoryTeacherId,
    List<String>? extraSupervisingTeacherIds,
    String? enterpriseId,
    String? jobId,
    List<String>? extraSpecializationsId,
    Person? supervisor,
    DateTimeRange? date,
    List<WeeklySchedule>? weeklySchedules,
    int? expectedLength,
    int? achievedLength,
    VisitingPriority? visitingPriority,
    String? teacherNotes,
    DateTime? endDate,
    List<InternshipEvaluationSkill>? skillEvaluations,
    List<InternshipEvaluationAttitude>? attitudeEvaluations,
    PostInternshipEnterpriseEvaluation? enterpriseEvaluation,
  }) {
    if (supervisor != null || date != null || weeklySchedules != null) {
      throw ArgumentError('[supervisor], [date] or [weeklySchedules]'
          'should not be changed via [copyWith], but using [addVersion]');
    }
    return Internship._(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      signatoryTeacherId: signatoryTeacherId ?? this.signatoryTeacherId,
      extraSupervisingTeacherIds:
          extraSupervisingTeacherIds ?? _extraSupervisingTeacherIds,
      // enterpriseId: enterpriseId ?? this.enterpriseId,
      // jobId: jobId ?? this.jobId,
      // extraSpecializationsId:
      //     extraSpecializationsId ?? this.extraSpecializationsId,
      // mutables: _mutables,
      // expectedLength: expectedLength ?? this.expectedLength,
      // achievedLength: achievedLength ?? this.achievedLength,
      // visitingPriority: visitingPriority ?? this.visitingPriority,
      // teacherNotes: teacherNotes ?? this.teacherNotes,
      // endDate: endDate ?? this.endDate,
      // skillEvaluations: skillEvaluations ?? this.skillEvaluations,
      // attitudeEvaluations: attitudeEvaluations ?? this.attitudeEvaluations,
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

    return Internship(
      id: data['id']?.toString() ?? id,
      studentId: data['student_id'] ?? studentId,
      signatoryTeacherId: data['signatory_teacher_id'] ?? signatoryTeacherId,
      extraSupervisingTeacherIds:
          _stringListFromSerialized(data['extra_supervising_teacher_ids']),
    );
  }

  @override
  String toString() {
    return 'Internship{studentId: $studentId, '
        'signatoryTeacherId: $signatoryTeacherId, '
        'extraSupervisingTeacherIds: $_extraSupervisingTeacherIds, '
        // 'enterpriseId: $enterpriseId, '
        // 'jobId: $jobId, '
        // 'extraSpecializationsId: $extraSpecializationsId, '
        // 'mutables: $_mutables, '
        // 'expectedLength: $expectedLength, '
        // 'achievedLength: $achievedLength, '
        // 'visitingPriority: $visitingPriority, '
        // 'teacherNotes: $teacherNotes, '
        // 'endDate: $endDate, '
        // 'skillEvaluations: $skillEvaluations, '
        // 'attitudeEvaluations: $attitudeEvaluations, '
        // 'enterpriseEvaluation: $enterpriseEvaluation'
        '}';
  }
}
