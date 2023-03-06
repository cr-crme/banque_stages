import 'package:enhanced_containers/enhanced_containers.dart';

import '/misc/job_data_file_service.dart';

class Job extends ItemSerializable {
  Job({
    super.id,
    this.activitySector,
    this.specialization,
    this.positionsOffered = 1,
    this.positionsOccupied = 0,
    List<String>? pictures,
    this.taskVariety = -1.0,
    List<String>? skillsRequired,
    this.autonomyExpected = -1.0,
    this.efficiencyWanted = -1.0,
    this.welcomingTSA = -1.0,
    this.welcomingCommunication = -1.0,
    this.welcomingMentalDeficiency = -1.0,
    this.welcomingMentalHealthIssue = -1.0,
    List<String>? equipmentRequired,
    List<String>? dangerousSituations,
    List<String>? pastWounds,
    List<String>? pastIncidents,
    this.minimalAge = 0,
    this.uniform = "",
    List<String>? requiredForJob,
    List<String>? comments,
  })  : pictures = pictures ?? [],
        skillsRequired = skillsRequired ?? [],
        equipmentRequired = equipmentRequired ?? [],
        dangerousSituations = dangerousSituations ?? [],
        pastWounds = pastWounds ?? [],
        pastIncidents = pastIncidents ?? [],
        requiredForJob = requiredForJob ?? [],
        comments = comments ?? [];

  Job copyWith({
    ActivitySector? activitySector,
    Specialization? specialization,
    int? positionsOffered,
    int? positionsOccupied,
    List<String>? pictures,
    double? taskVariety,
    List<String>? skillsRequired,
    double? autonomyExpected,
    double? efficiencyWanted,
    double? welcomingTSA,
    double? welcomingCommunication,
    double? welcomingMentalDeficiency,
    double? welcomingMentalHealthIssue,
    List<String>? equipmentRequired,
    List<String>? dangerousSituations,
    List<String>? pastWounds,
    List<String>? pastIncidents,
    int? minimalAge,
    String? uniform,
    List<String>? requiredForJob,
    List<String>? comments,
    String? id,
  }) {
    return Job(
        activitySector: activitySector ?? this.activitySector,
        specialization: specialization ?? this.specialization,
        positionsOffered: positionsOffered ?? this.positionsOffered,
        positionsOccupied: positionsOccupied ?? this.positionsOccupied,
        pictures: pictures ?? this.pictures,
        taskVariety: taskVariety ?? this.taskVariety,
        skillsRequired: skillsRequired ?? this.skillsRequired,
        autonomyExpected: autonomyExpected ?? this.autonomyExpected,
        efficiencyWanted: efficiencyWanted ?? this.efficiencyWanted,
        welcomingTSA: welcomingTSA ?? this.welcomingTSA,
        welcomingCommunication:
            welcomingCommunication ?? this.welcomingCommunication,
        welcomingMentalDeficiency:
            welcomingMentalDeficiency ?? this.welcomingMentalDeficiency,
        welcomingMentalHealthIssue:
            welcomingMentalHealthIssue ?? this.welcomingMentalHealthIssue,
        equipmentRequired: equipmentRequired ?? this.equipmentRequired,
        dangerousSituations: dangerousSituations ?? this.dangerousSituations,
        pastWounds: pastWounds ?? this.pastWounds,
        pastIncidents: pastIncidents ?? this.pastIncidents,
        minimalAge: minimalAge ?? this.minimalAge,
        uniform: uniform ?? this.uniform,
        requiredForJob: requiredForJob ?? this.requiredForJob,
        comments: comments ?? this.comments,
        id: id ?? this.id);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      "activitySector": activitySector?.id,
      "specialization": specialization?.id,
      "positionsOffered": positionsOffered,
      "positionsOccupied": positionsOccupied,
      "pictures": pictures,
      "taskVariety": taskVariety,
      "skillsRequired": skillsRequired,
      "autonomyExpected": autonomyExpected,
      "efficiencyWanted": efficiencyWanted,
      "welcomingTSA": welcomingTSA,
      "welcomingCommunication": welcomingCommunication,
      "welcomingMentalDeficiency": welcomingMentalDeficiency,
      "welcomingMentalHealthIssue": welcomingMentalHealthIssue,
      "equipmentRequired": equipmentRequired,
      "dangerousSituations": dangerousSituations,
      "pastWounds": pastWounds,
      "pastIncidents": pastIncidents,
      "minimalAge": minimalAge,
      "uniform": uniform,
      "requiredForJob": requiredForJob,
      "comments": comments,
    };
  }

  Job.fromSerialized(map)
      : activitySector = JobDataFileService.fromId(map['activitySector']),
        specialization = JobDataFileService.fromId(map['activitySector'])
            ?.fromId(map['specialization']),
        positionsOffered = map['positionsOffered'],
        positionsOccupied = map['positionsOccupied'],
        pictures = ItemSerializable.listFromSerialized(map['pictures']),
        taskVariety = ItemSerializable.doubleFromSerialized(map['taskVariety']),
        skillsRequired =
            ItemSerializable.listFromSerialized(map['skillsRequired']),
        autonomyExpected =
            ItemSerializable.doubleFromSerialized(map['autonomyExpected']),
        efficiencyWanted =
            ItemSerializable.doubleFromSerialized(map['efficiencyWanted']),
        welcomingTSA =
            ItemSerializable.doubleFromSerialized(map['welcomingTSA']),
        welcomingCommunication = ItemSerializable.doubleFromSerialized(
            map['welcomingCommunication']),
        welcomingMentalDeficiency = ItemSerializable.doubleFromSerialized(
            map['welcomingMentalDeficiency']),
        welcomingMentalHealthIssue = ItemSerializable.doubleFromSerialized(
            map['welcomingMentalHealthIssue']),
        equipmentRequired =
            ItemSerializable.listFromSerialized(map['equipmentRequired']),
        dangerousSituations =
            ItemSerializable.listFromSerialized(map['dangerousSituations']),
        pastWounds = ItemSerializable.listFromSerialized(map['pastWounds']),
        pastIncidents =
            ItemSerializable.listFromSerialized(map['pastIncidents']),
        minimalAge = map['minimalAge'],
        uniform = map['uniform'],
        requiredForJob =
            ItemSerializable.listFromSerialized(map['requiredForJob']),
        comments = ItemSerializable.listFromSerialized(map['comments']),
        super.fromSerialized(map);

  // Details
  final ActivitySector? activitySector;
  final Specialization? specialization;

  final int positionsOffered;
  final int positionsOccupied;

  // Photos
  final List<String> pictures;

  // Tasks
  final double taskVariety;
  final List<String> skillsRequired;
  final double autonomyExpected;
  final double efficiencyWanted;

  // Supervision
  final double welcomingTSA;
  final double welcomingCommunication;
  final double welcomingMentalDeficiency;
  final double welcomingMentalHealthIssue;

  // SST
  final List<String> equipmentRequired;
  final List<String> dangerousSituations;
  final List<String> pastWounds;
  final List<String> pastIncidents;

  // Prerequisites
  final int minimalAge;
  final String uniform;
  final List<String> requiredForJob;

  // Comments
  final List<String> comments;
}
