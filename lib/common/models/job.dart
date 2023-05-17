import 'package:enhanced_containers/enhanced_containers.dart';

import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';

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

  // SST
  final String dangerousSituations;
  final List<String> equipmentRequired;
  final String pastIncidents;
  final String incidentContact;
  final Map<String, dynamic> sstQuestions;
  final DateTime sstLastUpdate;

  // Prerequisites
  final int minimalAge;
  final String uniform;
  final List<String> requirements;

  // Comments
  final List<String> comments;

  Job({
    super.id,
    required this.specialization,
    required this.positionsOffered,
    List<String>? photosUrl,
    this.taskVariety = -1.0,
    List<String>? skillsRequired,
    this.autonomyExpected = -1.0,
    this.efficiencyWanted = -1.0,
    this.welcomingTsa = -1.0,
    this.welcomingCommunication = -1.0,
    this.welcomingMentalDeficiency = -1.0,
    this.welcomingMentalHealthIssue = -1.0,
    this.dangerousSituations = '',
    List<String>? equipmentRequired,
    this.pastIncidents = '',
    this.incidentContact = '',
    Map<String, dynamic>? sstQuestions,
    DateTime? sstLastUpdate,
    this.minimalAge = 0,
    this.uniform = '',
    List<String>? requirements,
    List<String>? comments,
  })  : photosUrl = photosUrl ?? [],
        skillsRequired = skillsRequired ?? [],
        sstLastUpdate = sstLastUpdate ?? DateTime.now(),
        equipmentRequired = equipmentRequired ?? [],
        sstQuestions = sstQuestions ?? {},
        requirements = requirements ?? [],
        comments = comments ?? [];

  Job copyWith({
    ActivitySector? activitySector,
    Specialization? specialization,
    int? positionsOffered,
    List<String>? photosUrl,
    double? taskVariety,
    List<String>? skillsRequired,
    double? autonomyExpected,
    double? efficiencyWanted,
    double? welcomingTsa,
    double? welcomingCommunication,
    double? welcomingMentalDeficiency,
    double? welcomingMentalHealthIssue,
    String? dangerousSituations,
    List<String>? equipmentRequired,
    String? pastIncidents,
    String? incidentContact,
    Map<String, dynamic>? sstQuestions,
    DateTime? sstLastUpdate,
    int? minimalAge,
    String? uniform,
    List<String>? requirements,
    List<String>? comments,
    String? id,
  }) {
    return Job(
        specialization: specialization ?? this.specialization,
        positionsOffered: positionsOffered ?? this.positionsOffered,
        photosUrl: photosUrl ?? this.photosUrl,
        taskVariety: taskVariety ?? this.taskVariety,
        skillsRequired: skillsRequired ?? this.skillsRequired,
        autonomyExpected: autonomyExpected ?? this.autonomyExpected,
        efficiencyWanted: efficiencyWanted ?? this.efficiencyWanted,
        welcomingTsa: welcomingTsa ?? this.welcomingTsa,
        welcomingCommunication:
            welcomingCommunication ?? this.welcomingCommunication,
        welcomingMentalDeficiency:
            welcomingMentalDeficiency ?? this.welcomingMentalDeficiency,
        welcomingMentalHealthIssue:
            welcomingMentalHealthIssue ?? this.welcomingMentalHealthIssue,
        dangerousSituations: dangerousSituations ?? this.dangerousSituations,
        equipmentRequired: equipmentRequired ?? this.equipmentRequired,
        pastIncidents: pastIncidents ?? this.pastIncidents,
        incidentContact: incidentContact ?? this.incidentContact,
        sstQuestions: sstQuestions ?? this.sstQuestions,
        sstLastUpdate: sstLastUpdate ?? this.sstLastUpdate,
        minimalAge: minimalAge ?? this.minimalAge,
        uniform: uniform ?? this.uniform,
        requirements: requirements ?? this.requirements,
        comments: comments ?? this.comments,
        id: id ?? this.id);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'specialization': specialization.id,
      'positionsOffered': positionsOffered,
      'photosUrl': photosUrl,
      'taskVariety': taskVariety,
      'skillsRequired': skillsRequired,
      'autonomyExpected': autonomyExpected,
      'efficiencyWanted': efficiencyWanted,
      'welcomingTSA': welcomingTsa,
      'welcomingCommunication': welcomingCommunication,
      'welcomingMentalDeficiency': welcomingMentalDeficiency,
      'welcomingMentalHealthIssue': welcomingMentalHealthIssue,
      'dangerousSituations': dangerousSituations,
      'equipmentRequired': equipmentRequired,
      'pastIncidents': pastIncidents,
      'incidentContact': incidentContact,
      'sstQuestions': sstQuestions,
      'sstLastUpdate': sstLastUpdate.millisecondsSinceEpoch,
      'minimalAge': minimalAge,
      'uniform': uniform,
      'requirements': requirements,
      'comments': comments,
    };
  }

  Job.fromSerialized(map)
      : specialization =
            ActivitySectorsService.specialization(map['specialization']),
        positionsOffered = map['positionsOffered'],
        photosUrl = ItemSerializable.listFromSerialized(map['photosUrl']),
        taskVariety = ItemSerializable.doubleFromSerialized(map['taskVariety']),
        skillsRequired =
            ItemSerializable.listFromSerialized(map['skillsRequired']),
        autonomyExpected =
            ItemSerializable.doubleFromSerialized(map['autonomyExpected']),
        efficiencyWanted =
            ItemSerializable.doubleFromSerialized(map['efficiencyWanted']),
        welcomingTsa =
            ItemSerializable.doubleFromSerialized(map['welcomingTSA']),
        welcomingCommunication = ItemSerializable.doubleFromSerialized(
            map['welcomingCommunication']),
        welcomingMentalDeficiency = ItemSerializable.doubleFromSerialized(
            map['welcomingMentalDeficiency']),
        welcomingMentalHealthIssue = ItemSerializable.doubleFromSerialized(
            map['welcomingMentalHealthIssue']),
        dangerousSituations = map['dangerousSituations'],
        equipmentRequired =
            ItemSerializable.listFromSerialized(map['equipmentRequired']),
        pastIncidents = map['pastIncidents'],
        incidentContact = map['incidentContact'],
        sstQuestions = ItemSerializable.mapFromSerialized(map['sstQuestions']),
        sstLastUpdate =
            DateTime.fromMillisecondsSinceEpoch(map['sstLastUpdate'] ?? 0),
        minimalAge = map['minimalAge'],
        uniform = map['uniform'],
        requirements = ItemSerializable.listFromSerialized(map['requirements']),
        comments = ItemSerializable.listFromSerialized(map['comments']),
        super.fromSerialized(map);
}
