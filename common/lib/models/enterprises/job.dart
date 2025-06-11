import 'package:common/exceptions.dart';
import 'package:common/models/generic/serializable_elements.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

part 'package:common/models/enterprises/incidents.dart';
part 'package:common/models/enterprises/job_sst_evaluation.dart';
part 'package:common/models/enterprises/pre_internship_requests.dart';
part 'package:common/models/enterprises/protections.dart';
part 'package:common/models/enterprises/uniforms.dart';

class Job extends ItemSerializable {
  static final String _currentVersion = '1.0.0';
  static String get currentVersion => _currentVersion;

// Details
  final Specialization? _specialization;
  Specialization? get specializationOrNull => _specialization;
  Specialization get specialization {
    if (_specialization == null) {
      throw ArgumentError('No specialization found for this job');
    }
    return _specialization;
  }

  // Reserved to a specific ID (i.e., school, teacher)
  final String? reservedForId;

  // Positions offered by school
  final Map<String, int> positionsOffered;

  // Prerequisites for an internship
  final int minimumAge;
  final PreInternshipRequests preInternshipRequests;
  final Uniforms uniforms;
  final Protections protections;

  // Photos
  final List<String> photosUrl;

  // SST
  final JobSstEvaluation sstEvaluation;
  final Incidents incidents;

  // Comments
  final List<String> comments;

  Job({
    super.id,
    required Specialization? specialization,
    required this.positionsOffered,
    required this.minimumAge,
    required this.preInternshipRequests,
    required this.uniforms,
    required this.protections,
    List<String>? photosUrl,
    required this.sstEvaluation,
    required this.incidents,
    List<String>? comments,
    required this.reservedForId,
  })  : _specialization = specialization,
        photosUrl = photosUrl ?? [],
        comments = comments ?? [];

  Job copyWith({
    String? id,
    Specialization? specialization,
    Map<String, int>? positionsOffered,
    int? minimumAge,
    PreInternshipRequests? preInternshipRequests,
    Uniforms? uniforms,
    Protections? protections,
    List<String>? photosUrl,
    JobSstEvaluation? sstEvaluation,
    Incidents? incidents,
    List<String>? comments,
    String? reservedForId,
  }) {
    return Job(
      id: id ?? this.id,
      specialization: specialization ?? _specialization,
      positionsOffered: positionsOffered ?? this.positionsOffered,
      minimumAge: minimumAge ?? this.minimumAge,
      preInternshipRequests:
          preInternshipRequests?.copyWith(id: this.preInternshipRequests.id) ??
              this.preInternshipRequests,
      uniforms: uniforms?.copyWith(id: this.uniforms.id) ?? this.uniforms,
      protections:
          protections?.copyWith(id: this.protections.id) ?? this.protections,
      photosUrl: photosUrl ?? this.photosUrl,
      sstEvaluation: sstEvaluation ?? this.sstEvaluation,
      incidents: incidents ?? this.incidents,
      comments: comments ?? this.comments,
      reservedForId: reservedForId ?? this.reservedForId,
    );
  }

  static Job get empty {
    final job = Job(
      specialization: null,
      positionsOffered: {},
      minimumAge: 0,
      preInternshipRequests: PreInternshipRequests.empty,
      uniforms: Uniforms.empty,
      protections: Protections.empty,
      photosUrl: [],
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      comments: [],
      reservedForId: null,
    );
    return job.copyWith(
      uniforms: job.uniforms.copyWith(id: job.id),
      protections: job.protections.copyWith(id: job.id),
      sstEvaluation: job.sstEvaluation.copyWith(id: job.id),
    );
  }

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id.serialize(),
        'version': _currentVersion.serialize(),
        'specialization_id': specialization.id.serialize(),
        'positions_offered': positionsOffered.serialize(),
        'minimum_age': minimumAge.serialize(),
        'pre_internship_requests': preInternshipRequests.serialize(),
        'uniforms': uniforms.serialize(),
        'protections': protections.serialize(),
        'photos_url': photosUrl.serialize(),
        'sst_evaluations': sstEvaluation.serialize(),
        'incidents': incidents.serialize(),
        'comments': comments.serialize(),
        'reserved_for_id': reservedForId?.serialize(),
      };

  Job.fromSerialized(super.map)
      : _specialization = ActivitySectorsService.specializationOrNull(
            map['specialization_id']),
        positionsOffered = MapExt.from<int>(map['positions_offered'],
                deserializer: (e) => e) ??
            {},
        minimumAge = IntExt.from(map['minimum_age']) ?? 0,
        preInternshipRequests = PreInternshipRequests.fromSerialized(
            map['pre_internship_requests'] ?? {}, map['version'] ?? '1.0.0'),
        uniforms = Uniforms.fromSerialized(
            (map['uniforms'] as Map? ?? {}).cast<String, dynamic>()
              ..addAll({'id': map['id']}),
            map['version'] ?? '1.0.0'),
        protections = Protections.fromSerialized(
            (map['protections'] as Map? ?? {}).cast<String, dynamic>()
              ..addAll({'id': map['id']})),
        photosUrl = ListExt.from(map['photos_url'],
                deserializer: (e) => StringExt.from(e) ?? '') ??
            [],
        sstEvaluation = JobSstEvaluation.fromSerialized(
            (map['sst_evaluations'] as Map? ?? {}).cast<String, dynamic>()
              ..addAll({'id': map['id']})),
        incidents = Incidents.fromSerialized((map['incidents'] as Map? ?? {})
            .cast<String, dynamic>()
            .map((key, value) => MapEntry(key, value))
          ..addAll({'id': map['id']})),
        comments = ListExt.from(map['comments'],
                deserializer: (e) => StringExt.from(e) ?? '') ??
            [],
        reservedForId = StringExt.from(map['reserved_for_id']),
        super.fromSerialized();

  @override
  String toString() {
    return 'Job(positionsOffered: $positionsOffered, '
        'specialization: $specialization, '
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
