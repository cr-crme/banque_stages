import '/misc/custom_containers/item_serializable.dart';

class Job extends ItemSerializable {
  Job({
    this.activitySector = "",
    this.specialization = "",
    this.totalSlot = 1,
    this.occupiedSlot = 0,
    List<String>? pictures,
    this.taskVariety = 2.5,
    List<String>? skillsRequired,
    this.autonomyExpected = 2.5,
    this.efficiencyWanted = 2.5,
    this.welcomingTSA = 2.5,
    this.welcomingCommunication = 2.5,
    this.welcomingMentalDeficiency = 2.5,
    this.welcomingMentalHealthIssue = 2.5,
    List<String>? equipmentRequired,
    List<String>? dangerousSituations,
    List<String>? pastWounds,
    List<String>? pastIncidents,
    this.minimalAge = 0,
    this.uniform = "",
    List<String>? requiredForJob,
    List<String>? comments,
    id,
  })  : pictures = pictures ?? [],
        skillsRequired = skillsRequired ?? [],
        equipmentRequired = equipmentRequired ?? [],
        dangerousSituations = dangerousSituations ?? [],
        pastWounds = pastWounds ?? [],
        pastIncidents = pastIncidents ?? [],
        requiredForJob = requiredForJob ?? [],
        comments = comments ?? [],
        super(id: id);

  Job copyWith({
    String? activitySector,
    String? specialization,
    int? totalSlot,
    int? occupiedSlot,
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
        totalSlot: totalSlot ?? this.totalSlot,
        occupiedSlot: occupiedSlot ?? this.occupiedSlot,
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
      "activitySector": activitySector,
      "specialization": specialization,
      "totalSlot": totalSlot,
      "occupiedSlot": occupiedSlot,
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

  Job.fromSerialized(Map<String, dynamic> map)
      : activitySector = map['activitySector'],
        specialization = map['specialization'],
        totalSlot = map['totalSlot'],
        occupiedSlot = map['occupiedSlot'],
        pictures = map['pictures'] ?? [],
        taskVariety = map['taskVariety'],
        skillsRequired = map['skillsRequired'] ?? [],
        autonomyExpected = map['autonomyExpected'],
        efficiencyWanted = map['efficiencyWanted'],
        welcomingTSA = map['welcomingTSA'],
        welcomingCommunication = map['welcomingCommunication'],
        welcomingMentalDeficiency = map['welcomingMentalDeficiency'],
        welcomingMentalHealthIssue = map['welcomingMentalHealthIssue'],
        equipmentRequired = map['equipmentRequired'] ?? [],
        dangerousSituations = map['dangerousSituations'] ?? [],
        pastWounds = map['pastWounds'] ?? [],
        pastIncidents = map['pastIncidents'] ?? [],
        minimalAge = map['minimalAge'],
        uniform = map['uniform'],
        requiredForJob = map['requiredForJob'] ?? [],
        comments = map['comments'] ?? [],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Job.fromSerialized(map);
  }

  final String activitySector;
  final String specialization;

  final int totalSlot;
  final int occupiedSlot;

  final List<String> pictures;

  final double taskVariety;
  final List<String> skillsRequired;
  final double autonomyExpected;
  final double efficiencyWanted;

  final double welcomingTSA;
  final double welcomingCommunication;
  final double welcomingMentalDeficiency;
  final double welcomingMentalHealthIssue;

  final List<String> equipmentRequired;
  final List<String> dangerousSituations;
  final List<String> pastWounds;
  final List<String> pastIncidents;

  final int minimalAge;
  final String uniform;
  final List<String> requiredForJob;

  final List<String> comments;
}

const List<String> jobActivitySectors = [
  "Secteur 1",
  "Secteur 2",
  "Secteur 3",
  "Secteur 4"
];
const List<String> jobSpecializations = [
  "Spécialisation 1",
  "Spécialisation 2",
  "Spécialisation 3",
  "Spécialisation 4",
  "Spécialisation 5",
  "Spécialisation 6"
];
