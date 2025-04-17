import 'package:common/exceptions.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

part 'package:common/models/enterprises/incidents.dart';
part 'package:common/models/enterprises/job_sst_evaluation.dart';
part 'package:common/models/enterprises/pre_internship_request.dart';
part 'package:common/models/enterprises/protections.dart';
part 'package:common/models/enterprises/uniforms.dart';

List<String> _stringListFromSerialized(List? list) =>
    (list ?? []).map<String>((e) => e).toList();

class Job extends ItemSerializable {
  static final String _currentVersion = '1.0.0';

// Details
  // Specialization get specialization {
  //   if (_specialization == null) {
  //     throw ArgumentError('No specialization found for this job');
  //   }
  //   return _specialization;
  // }

  // final Specialization? _specialization;
  final int positionsOffered;
  // TODO Implement this App side with an extension on
  // int positionsOccupied(context) =>
  //     InternshipsProvider.of(context, listen: false)
  //         .where((e) => e.jobId == id && e.isActive)
  //         .length;
  // TODO Implement this App side with an extension on
  // int positionsRemaining(context) =>
  //     positionsOffered - positionsOccupied(context);

  // Prerequisites for an internship
  final int minimumAge;
  final List<PreInternshipRequest> preInternshipRequests;
  final Uniforms uniforms;
  final Protections protections;

  // Photos
  final List<String> photosUrl;

  // Post-internship evaluations
  // TODO Implement this App side with an extension on
  // List<PostInternshipEnterpriseEvaluation> postInternshipEnterpriseEvaluations(
  //     context) {
  //   final internships = [
  //     for (final internship in InternshipsProvider.of(context, listen: false))
  //       if (internship.jobId == id) internship
  //   ];
  //   return [
  //     for (final evaluation in internships.map((e) => e.enterpriseEvaluation))
  //       if (evaluation != null) evaluation
  //   ];
  // }

  // SST
  final JobSstEvaluation sstEvaluation;
  final Incidents incidents;

  // Comments
  final List<String> comments;

  Job({
    super.id,
    // required Specialization specialization,
    required this.positionsOffered,
    required this.minimumAge,
    required this.preInternshipRequests,
    required this.uniforms,
    required this.protections,
    List<String>? photosUrl,
    required this.sstEvaluation,
    required this.incidents,
    List<String>? comments,
  })  : // _specialization = specialization,
        photosUrl = photosUrl ?? [],
        comments = comments ?? [];

  Job copyWith({
    String? id,
    Specialization? specialization,
    int? positionsOffered,
    int? minimumAge,
    List<PreInternshipRequest>? preInternshipRequests,
    Uniforms? uniforms,
    Protections? protections,
    List<String>? photosUrl,
    JobSstEvaluation? sstEvaluation,
    Incidents? incidents,
    List<String>? comments,
  }) {
    return Job(
      id: id ?? this.id,
      // specialization: specialization ?? this.specialization,
      positionsOffered: positionsOffered ?? this.positionsOffered,
      minimumAge: minimumAge ?? this.minimumAge,
      preInternshipRequests:
          preInternshipRequests ?? this.preInternshipRequests,
      uniforms: uniforms ?? this.uniforms,
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
        'version': _currentVersion,
        // 'specialization': specialization.id,
        'positions_offered': positionsOffered,
        'minimum_age': minimumAge,
        'pre_internship_requests': preInternshipRequests
            .map((e) => e._toInt(_currentVersion))
            .toList(),
        'uniforms': uniforms.serialize(),
        'protections': protections.serialize(),
        'photos_url': photosUrl,
        'sst_evaluations': sstEvaluation.serialize(),
        'incidents': incidents.serialize(),
        'comments': comments,
      };

  Job.fromSerialized(super.map)
      : // _specialization = map['specialization'] == null
        //     ? null
        //     : ActivitySectorsService.specialization(map['specialization']),
        positionsOffered = map['positions_offered'] ?? 0,
        minimumAge = map['minimum_age'] ?? 0,
        preInternshipRequests = (map['pre_internship_requests'] as List? ?? [])
            .map((e) => PreInternshipRequest._fromInt(e, map['version']))
            .toList(),
        uniforms =
            Uniforms.fromSerialized(map['uniforms'] ?? {}, map['version']),
        protections = Protections.fromSerialized(map['protections'] ?? {}),
        photosUrl = _stringListFromSerialized(map['photos_url']),
        sstEvaluation =
            JobSstEvaluation.fromSerialized(map['sst_evaluations'] ?? {}),
        incidents = Incidents.fromSerialized(map['incidents'] ?? {}),
        comments = _stringListFromSerialized(map['comments']),
        super.fromSerialized();

  @override
  String toString() {
    return 'Job(positionsOffered: $positionsOffered, '
        'minimumAge: $minimumAge, '
        'preInternshipRequests: $preInternshipRequests, '
        'photosUrl: $photosUrl, '
        'comments: $comments, '
        'uniforms: $uniforms, '
        'protections: $protections, '
        'incidents: $incidents, '
        'sstEvaluation: $sstEvaluation)';
  }
}
