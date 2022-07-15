class Job {
  Job({JobActivitySector? activitySector, JobSpecialization? specialization})
      : activitySector = activitySector ?? JobActivitySector.values.first,
        specialization = specialization ?? JobSpecialization.values.first;

  Job copyWith(
      {JobActivitySector? activitySector, JobSpecialization? specialization}) {
    return Job(
        activitySector: activitySector ?? this.activitySector,
        specialization: specialization ?? this.specialization);
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
