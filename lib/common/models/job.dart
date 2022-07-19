import '/misc/custom_containers/item_serializable.dart';

class Job extends ItemSerializable {
  Job({JobActivitySector? activitySector, JobSpecialization? specialization})
      : activitySector = activitySector ?? JobActivitySector.values.first,
        specialization = specialization ?? JobSpecialization.values.first;

  Job copyWith(
      {JobActivitySector? activitySector, JobSpecialization? specialization}) {
    return Job(
        activitySector: activitySector ?? this.activitySector,
        specialization: specialization ?? this.specialization);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {"activitySector": activitySector, "specialization": specialization};
  }

  Job.fromSerialized(Map<String, dynamic> map)
      : activitySector = map['activitySector'],
        specialization = map['specialization'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Job.fromSerialized(map);
  }

  final JobActivitySector activitySector;
  final JobSpecialization specialization;
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
