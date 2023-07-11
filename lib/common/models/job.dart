import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:enhanced_containers/enhanced_containers.dart';

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
    // TODO Aurelie - Confirm clearing when changing page is the desired behavior
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
  List<PostIntershipEnterpriseEvaluation> postInternshipEnterpriseEvaluations(
      context) {
    final internships = [
      for (final internship in InternshipsProvider.of(context, listen: false))
        if (internship.jobId == id) internship
    ];
    return [
      for (final evaluation in internships.map((e) => e.enterpriseEvaluation))
        if (evaluation != null) evaluation
    ];
  }

  // SST
  final JobSstEvaluation sstEvaluation;

  // Comments
  final List<String> comments;

  Job({
    super.id,
    required this.specialization,
    required this.positionsOffered,
    List<String>? photosUrl,
    required this.sstEvaluation,
    List<String>? comments,
  })  : photosUrl = photosUrl ?? [],
        comments = comments ?? [];

  Job copyWith({
    ActivitySector? activitySector,
    Specialization? specialization,
    int? positionsOffered,
    List<String>? photosUrl,
    JobSstEvaluation? sstEvaluation,
    List<String>? comments,
    String? id,
  }) {
    return Job(
        specialization: specialization ?? this.specialization,
        positionsOffered: positionsOffered ?? this.positionsOffered,
        photosUrl: photosUrl ?? this.photosUrl,
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
      'sstEvaluations': sstEvaluation.serialize(),
      'comments': comments,
    };
  }

  Job.fromSerialized(map)
      : specialization =
            ActivitySectorsService.specialization(map['specialization']),
        positionsOffered = map['positionsOffered'],
        photosUrl = _stringListFromSerialized(map['photosUrl']),
        sstEvaluation = JobSstEvaluation.fromSerialized(map['sstEvaluations']),
        comments = _stringListFromSerialized(map['comments']),
        super.fromSerialized(map);
}
