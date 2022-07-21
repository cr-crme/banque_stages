import '/misc/custom_containers/item_serializable.dart';

class Job extends ItemSerializable {
  Job(
      {JobActivitySector? activitySector,
      JobSpecialization? specialization,
      this.principalTask = "",
      this.dangerousSituations = "",
      this.protectionEquipements = "",
      this.accidents = "",
      this.stressSituations = "",
      this.minimumAge = 0,
      this.uniform = "",
      this.expectations = "",
      this.supervision = "",
      this.comments = ""})
      : activitySector = activitySector ?? JobActivitySector.values.first,
        specialization = specialization ?? JobSpecialization.values.first;

  Job copyWith(
      {JobActivitySector? activitySector,
      JobSpecialization? specialization,
      String? principalTask,
      String? dangerousSituations,
      String? protectionEquipements,
      String? accidents,
      String? stressSituations,
      int? minimumAge,
      String? uniform,
      String? expectations,
      String? supervision,
      String? comments}) {
    return Job(
        activitySector: activitySector ?? this.activitySector,
        specialization: specialization ?? this.specialization,
        principalTask: principalTask ?? this.principalTask,
        dangerousSituations: dangerousSituations ?? this.dangerousSituations,
        protectionEquipements:
            protectionEquipements ?? this.protectionEquipements,
        accidents: accidents ?? this.accidents,
        stressSituations: stressSituations ?? this.stressSituations,
        minimumAge: minimumAge ?? this.minimumAge,
        uniform: uniform ?? this.uniform,
        expectations: expectations ?? this.expectations,
        supervision: supervision ?? this.supervision,
        comments: comments ?? this.comments);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      "activitySector": activitySector,
      "specialization": specialization,
      "principalTask": principalTask,
      "dangerousSituations": dangerousSituations,
      "protectionEquipements": protectionEquipements,
      "accidents": accidents,
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
        principalTask = map['principalTask'],
        dangerousSituations = map['dangerousSituations'],
        protectionEquipements = map['protectionEquipements'],
        accidents = map['accidents'],
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

  final JobActivitySector activitySector;
  final JobSpecialization specialization;

  final String principalTask;

  final String dangerousSituations;
  final String protectionEquipements;
  final String accidents;
  final String stressSituations;

  final int minimumAge;
  final String uniform;
  final String expectations;
  final String supervision;
  final String comments;
}

enum JobActivitySector {
  secteur1,
  secteur2,
  secteur3;

  @override
  String toString() {
    switch (this) {
      case JobActivitySector.secteur1:
        return "Secteur 1";
      default:
        return super.toString();
    }
  }
}

enum JobSpecialization {
  specialisation1,
  specialisation2,
  specialisation3;

  @override
  String toString() {
    switch (this) {
      case JobSpecialization.specialisation1:
        return "Specialisation 1";
      default:
        return super.toString();
    }
  }
}
