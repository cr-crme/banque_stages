import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
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
    required List<String> dangerousSituations,
    required List<String> equipmentRequired,
    required List<String> incidents,
    required String incidentContact,
    required Map<String, dynamic> questions,
  }) {
    this.dangerousSituations.clear();
    this.dangerousSituations.addAll(dangerousSituations);

    this.equipmentRequired.clear();
    this.equipmentRequired.addAll(equipmentRequired);

    this.incidents.clear();
    this.incidents.addAll(incidents);

    this.incidentContact = incidentContact;

    this.questions.clear();
    this.questions.addAll(questions);

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

  // Prerequisites for an internship
  final int minimumAge;
  final PreInternshipRequest preInternshipRequest;
  final Uniform uniform;
  final Protections protections;

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
    required this.minimumAge,
    required this.preInternshipRequest,
    required this.uniform,
    required this.protections,
    List<String>? photosUrl,
    required this.sstEvaluation,
    List<String>? comments,
  })  : photosUrl = photosUrl ?? [],
        comments = comments ?? [];

  Job copyWith({
    ActivitySector? activitySector,
    Specialization? specialization,
    int? positionsOffered,
    int? minimumAge,
    PreInternshipRequest? preInternshipRequest,
    Uniform? uniform,
    Protections? protections,
    List<String>? photosUrl,
    JobSstEvaluation? sstEvaluation,
    List<String>? comments,
    String? id,
  }) {
    return Job(
        specialization: specialization ?? this.specialization,
        positionsOffered: positionsOffered ?? this.positionsOffered,
        minimumAge: minimumAge ?? this.minimumAge,
        preInternshipRequest: preInternshipRequest ?? this.preInternshipRequest,
        uniform: uniform ?? this.uniform,
        protections: protections ?? this.protections,
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
      'minimumAge': minimumAge,
      'preInternshipRequest': preInternshipRequest.serialize(),
      'uniform': uniform.serialize(),
      'protections': protections.serialize(),
      'photosUrl': photosUrl,
      'sstEvaluations': sstEvaluation.serialize(),
      'comments': comments,
    };
  }

  Job.fromSerialized(map)
      : specialization =
            ActivitySectorsService.specialization(map['specialization']),
        positionsOffered = map['positionsOffered'],
        minimumAge = map['minimumAge'],
        preInternshipRequest =
            PreInternshipRequest.fromSerialized(map['preInternshipRequest']),
        uniform = Uniform.fromSerialized(map['uniform']),
        protections = Protections.fromSerialized(map['protections']),
        photosUrl = _stringListFromSerialized(map['photosUrl']),
        sstEvaluation = JobSstEvaluation.fromSerialized(map['sstEvaluations']),
        comments = _stringListFromSerialized(map['comments']),
        super.fromSerialized(map);
}
