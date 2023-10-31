import 'package:crcrme_banque_stages/common/models/incidents.dart';
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
  final Map<String, dynamic> questions;
  DateTime date;

  bool get isFilled => questions.isNotEmpty;

  void update({
    required Map<String, dynamic> questions,
  }) {
    this.questions.clear();
    this.questions.addAll({...questions});
    this.questions.removeWhere((key, value) => value == null);

    date = DateTime.now();
  }

  JobSstEvaluation({
    super.id,
    required this.questions,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  static JobSstEvaluation get empty => JobSstEvaluation(questions: {});

  JobSstEvaluation.fromSerialized(map)
      : questions = _stringMapFromSerialized(map['questions']),
        date = DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'questions': questions,
        'date': date.millisecondsSinceEpoch,
      };
}

class Job extends ItemSerializable {
// Details
  Specialization get specialization {
    if (_specialization == null) {
      throw ArgumentError('No specialization found for this job');
    }
    return _specialization!;
  }

  final Specialization? _specialization;
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
  final Incidents incidents;

  // Comments
  final List<String> comments;

  Job({
    super.id,
    required Specialization specialization,
    required this.positionsOffered,
    required this.minimumAge,
    required this.preInternshipRequest,
    required this.uniform,
    required this.protections,
    List<String>? photosUrl,
    required this.sstEvaluation,
    required this.incidents,
    List<String>? comments,
  })  : _specialization = specialization,
        photosUrl = photosUrl ?? [],
        comments = comments ?? [];

  Job copyWith({
    Specialization? specialization,
    int? positionsOffered,
    int? minimumAge,
    PreInternshipRequest? preInternshipRequest,
    Uniform? uniform,
    Protections? protections,
    List<String>? photosUrl,
    JobSstEvaluation? sstEvaluation,
    Incidents? incidents,
    List<String>? comments,
    String? id,
  }) {
    return Job(
      id: id ?? this.id,
      specialization: specialization ?? this.specialization,
      positionsOffered: positionsOffered ?? this.positionsOffered,
      minimumAge: minimumAge ?? this.minimumAge,
      preInternshipRequest: preInternshipRequest ?? this.preInternshipRequest,
      uniform: uniform ?? this.uniform,
      protections: protections ?? this.protections,
      photosUrl: photosUrl ?? this.photosUrl,
      sstEvaluation: sstEvaluation ?? this.sstEvaluation,
      incidents: incidents ?? this.incidents,
      comments: comments ?? this.comments,
    );
  }

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'specialization': specialization.id,
        'positionsOffered': positionsOffered,
        'minimumAge': minimumAge,
        'preInternshipRequest': preInternshipRequest.serialize(),
        'uniform': uniform.serialize(),
        'protections': protections.serialize(),
        'photosUrl': photosUrl,
        'sstEvaluations': sstEvaluation.serialize(),
        'incidents': incidents.serialize(),
        'comments': comments,
      };

  Job.fromSerialized(map)
      : _specialization = map['specialization'] == null
            ? null
            : ActivitySectorsService.specialization(map['specialization']),
        positionsOffered = map['positionsOffered'] ?? 0,
        minimumAge = map['minimumAge'] ?? 0,
        preInternshipRequest = PreInternshipRequest.fromSerialized(
            map['preInternshipRequest'] ?? {}),
        uniform = Uniform.fromSerialized(map['uniform'] ?? {}),
        protections = Protections.fromSerialized(map['protections'] ?? {}),
        photosUrl = _stringListFromSerialized(map['photosUrl']),
        sstEvaluation =
            JobSstEvaluation.fromSerialized(map['sstEvaluations'] ?? {}),
        incidents = Incidents.fromSerialized(map['incidents'] ?? {}),
        comments = _stringListFromSerialized(map['comments']),
        super.fromSerialized(map);
}
