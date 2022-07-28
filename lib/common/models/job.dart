import '/misc/custom_containers/item_serializable.dart';

class Job extends ItemSerializable {
  Job({
    this.activitySector = "",
    this.specialization = "",
    this.totalSlot = 1,
    this.occupiedSlot = 0,
    this.principalTask = "",
    this.dangerousSituations = "",
    this.protectionEquipements = "",
    this.accidentsHistory = "",
    this.stressSituations = "",
    this.minimumAge = 0,
    this.uniform = "",
    this.expectations = "",
    this.supervision = "",
    this.comments = "",
    id,
  }) : super(id: id);

  Job copyWith({
    String? activitySector,
    String? specialization,
    int? totalSlot,
    int? occupiedSlot,
    String? principalTask,
    String? dangerousSituations,
    String? protectionEquipements,
    String? accidentsHistory,
    String? stressSituations,
    int? minimumAge,
    String? uniform,
    String? expectations,
    String? supervision,
    String? comments,
    String? id,
  }) {
    return Job(
        activitySector: activitySector ?? this.activitySector,
        specialization: specialization ?? this.specialization,
        totalSlot: totalSlot ?? this.totalSlot,
        occupiedSlot: occupiedSlot ?? this.occupiedSlot,
        principalTask: principalTask ?? this.principalTask,
        dangerousSituations: dangerousSituations ?? this.dangerousSituations,
        protectionEquipements:
            protectionEquipements ?? this.protectionEquipements,
        accidentsHistory: accidentsHistory ?? this.accidentsHistory,
        stressSituations: stressSituations ?? this.stressSituations,
        minimumAge: minimumAge ?? this.minimumAge,
        uniform: uniform ?? this.uniform,
        expectations: expectations ?? this.expectations,
        supervision: supervision ?? this.supervision,
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
      "principalTask": principalTask,
      "dangerousSituations": dangerousSituations,
      "protectionEquipements": protectionEquipements,
      "accidentsHistory": accidentsHistory,
      "stressSituations": stressSituations,
      "minimumAge": minimumAge,
      "uniform": uniform,
      "expectations": expectations,
      "supervision": supervision,
      "comments": comments
    };
  }

  Job.fromSerialized(Map<String, dynamic> map)
      : activitySector = map['activitySector'],
        specialization = map['specialization'],
        totalSlot = map['totalSlot'],
        occupiedSlot = map['occupiedSlot'],
        principalTask = map['principalTask'],
        dangerousSituations = map['dangerousSituations'],
        protectionEquipements = map['protectionEquipements'],
        accidentsHistory = map['accidentsHistory'],
        stressSituations = map['stressSituations'],
        minimumAge = map['minimumAge'],
        uniform = map['uniform'],
        expectations = map['expectations'],
        supervision = map['supervision'],
        comments = map['comments'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Job.fromSerialized(map);
  }

  final String activitySector;
  final String specialization;

  final int totalSlot;
  final int occupiedSlot;

  final String principalTask;

  final String dangerousSituations;
  final String protectionEquipements;
  final String accidentsHistory;
  final String stressSituations;

  final int minimumAge;
  final String uniform;
  final String expectations;
  final String supervision;
  final String comments;
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
