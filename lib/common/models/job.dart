import 'package:enhanced_containers/enhanced_containers.dart';

import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';

double _doubleFromSerialized(num? number, {double defaultValue = 0}) {
  if (number is int) return number.toDouble();
  return (number ?? defaultValue) as double;
}

List<String> _stringListFromSerialized(List? list) =>
    (list ?? []).map<String>((e) => e).toList();

Map<String, dynamic> _stringMapFromSerialized(Map? list) =>
    (list ?? {}).map((k, v) => MapEntry(k.toString(), v));

class JobSstEvaluation extends ItemSerializable {
  final List<String> dangerousSituations;
  final List<String> equipmentRequired;
  final List<String> incidents;
  String incidentContact;
  final Map<String, dynamic> questions;
  DateTime date;

  void update({
    List<String>? dangerousSituations,
    List<String>? equipmentRequired,
    List<String>? incidents,
    String? incidentContact,
    Map<String, dynamic>? questions,
  }) {
    // TODO Aurelie - Confirm clearing is the desired behavior
    if (dangerousSituations != null) {
      this.dangerousSituations.clear();
      this.dangerousSituations.addAll(dangerousSituations);
    }
    if (equipmentRequired != null) {
      this.equipmentRequired.clear();
      this.equipmentRequired.addAll(equipmentRequired);
    }
    if (incidents != null) {
      this.incidents.clear();
      this.incidents.addAll(incidents);
    }
    if (incidentContact != null && incidentContact.isNotEmpty) {
      this.incidentContact = incidentContact;
    }
    if (questions != null && questions.isNotEmpty) {
      this.questions.clear();
      this.questions.addAll(questions);
    }
    date = DateTime.now();
  }

  bool get isEmpty =>
      dangerousSituations.isEmpty &&
      equipmentRequired.isEmpty &&
      incidents.isEmpty &&
      incidentContact.isEmpty &&
      questions.isEmpty;
  bool get isNotEmpty => !isEmpty;

  JobSstEvaluation({
    required this.dangerousSituations,
    required this.equipmentRequired,
    required this.incidents,
    required this.incidentContact,
    required this.questions,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  JobSstEvaluation.empty({required this.incidentContact})
      : dangerousSituations = [],
        equipmentRequired = [],
        incidents = [],
        questions = {},
        date = DateTime.now();

  JobSstEvaluation.fromSerialized(map)
      : dangerousSituations =
            _stringListFromSerialized(map['dangerousSituations']),
        equipmentRequired = _stringListFromSerialized(map['equipmentRequired']),
        incidents =
            (map['incidents'] as List? ?? []).map<String>((e) => e).toList(),
        incidentContact = map['incidentContact'],
        questions = _stringMapFromSerialized(map['questions']),
        date = DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0);

  @override
  Map<String, dynamic> serializedMap() => {
        'dangerousSituations': dangerousSituations,
        'equipmentRequired': equipmentRequired,
        'incidents': incidents,
        'incidentContact': incidentContact,
        'questions': questions,
        'date': date.millisecondsSinceEpoch,
      };
}

class JobPostIntershipEvaluation extends ItemSerializable {
  JobPostIntershipEvaluation({
    required this.taskVariety,
    required this.skillsRequired,
    required this.autonomyExpected,
    required this.efficiencyWanted,
    required this.welcomingTsa,
    required this.welcomingCommunication,
    required this.welcomingMentalDeficiency,
    required this.welcomingMentalHealthIssue,
    required this.minimalAge,
    required this.uniform,
    required this.requirements,
  });

  JobPostIntershipEvaluation.fromSerialized(map)
      : taskVariety = _doubleFromSerialized(map['taskVariety']),
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
        uniform = map['uniform'],
        requirements = _stringListFromSerialized(map['requirements']);

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
  final String uniform;
  final List<String> requirements;

  @override
  Map<String, dynamic> serializedMap() => {
        'taskVariety': taskVariety,
        'skillsRequired': skillsRequired,
        'autonomyExpected': autonomyExpected,
        'efficiencyWanted': efficiencyWanted,
        'welcomingTSA': welcomingTsa,
        'welcomingCommunication': welcomingCommunication,
        'welcomingMentalDeficiency': welcomingMentalDeficiency,
        'welcomingMentalHealthIssue': welcomingMentalHealthIssue,
        'minimalAge': minimalAge,
        'uniform': uniform,
        'requirements': requirements,
      };
}

double _meanInList(List list, double Function(dynamic) value) =>
    list.fold<double>(0.0, (prev, e) => value(e)) / list.length;

class Job extends ItemSerializable {
// Details
  final Specialization specialization;
  final int positionsOffered;
  int positionsOccupied(context) =>
      InternshipsProvider.of(context, listen: false)
          .where((e) => e.jobId == id && e.isActive)
          .length;
  int positionsRemaining(context) =>
      positionsOffered - positionsOccupied(context);

  // Photos
  final List<String> photosUrl;

  // Post-internship evaluations

  final List<JobPostIntershipEvaluation> postInternshipEvaluations;
  List<JobPostIntershipEvaluation> get _pie => postInternshipEvaluations;

  // Mean values of intership evaluations
  double get taskVariety => _meanInList(_pie, (e) => e.taskVariety);
  List<String> get skillsRequired =>
      _pie.expand((e) => e.skillsRequired).toList();
  double get autonomyExpected => _meanInList(_pie, (e) => e.autonomyExpected);
  double get efficiencyWanted => _meanInList(_pie, (e) => e.efficiencyWanted);

  double get welcomingTsa => _meanInList(_pie, (e) => e.welcomingTsa);
  double get welcomingCommunication =>
      _meanInList(_pie, (e) => e.welcomingCommunication);
  double get welcomingMentalDeficiency =>
      _meanInList(_pie, (e) => e.welcomingMentalDeficiency);
  double get welcomingMentalHealthIssue =>
      _meanInList(_pie, (e) => e.welcomingMentalHealthIssue);

  int get minimalAge =>
      _meanInList(_pie, (e) => (e.minimalAge as int).toDouble()).toInt();
  List<String> get uniform => _pie.map((e) => e.uniform).toList();
  List<String> get requirements => _pie.expand((e) => e.requirements).toList();

  // SST
  final JobSstEvaluation sstEvaluation;

  // Comments
  final List<String> comments;

  Job({
    super.id,
    required this.specialization,
    required this.positionsOffered,
    List<String>? photosUrl,
    List<JobPostIntershipEvaluation>? postInternshipEvaluations,
    required this.sstEvaluation,
    List<String>? comments,
  })  : photosUrl = photosUrl ?? [],
        postInternshipEvaluations = postInternshipEvaluations ?? [],
        comments = comments ?? [];

  Job copyWith({
    ActivitySector? activitySector,
    Specialization? specialization,
    int? positionsOffered,
    List<String>? photosUrl,
    List<JobPostIntershipEvaluation>? postInternshipEvaluations,
    JobSstEvaluation? sstEvaluation,
    List<String>? comments,
    String? id,
  }) {
    return Job(
        specialization: specialization ?? this.specialization,
        positionsOffered: positionsOffered ?? this.positionsOffered,
        photosUrl: photosUrl ?? this.photosUrl,
        postInternshipEvaluations:
            postInternshipEvaluations ?? this.postInternshipEvaluations,
        sstEvaluation: sstEvaluation ?? this.sstEvaluation,
        comments: comments ?? this.comments,
        id: id ?? this.id);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'specialization': specialization.id,
      'positionsOffered': positionsOffered,
      'photosUrl': photosUrl,
      'postInternshipEvaluations':
          postInternshipEvaluations.map((e) => e.serialize()).toList(),
      'sstEvaluations': sstEvaluation.serialize(),
      'comments': comments,
    };
  }

  Job.fromSerialized(map)
      : specialization =
            ActivitySectorsService.specialization(map['specialization']),
        positionsOffered = map['positionsOffered'],
        photosUrl = _stringListFromSerialized(map['photosUrl']),
        postInternshipEvaluations =
            (map['postInternshipEvaluations'] as List? ?? [])
                .map((e) => JobPostIntershipEvaluation.fromSerialized(e))
                .toList(),
        sstEvaluation = JobSstEvaluation.fromSerialized(map['sstEvaluations']),
        comments = _stringListFromSerialized(map['comments']),
        super.fromSerialized(map);
}
