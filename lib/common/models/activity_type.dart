enum ActivityType {
  activity1,
  activity2,
  activity3,
  activity4,
  activity5,
  activity6,
  activity7;

  String get id => name;

  @override
  String toString() {
    switch (this) {
      case ActivityType.activity1:
        return "Activité 1";
      case ActivityType.activity2:
        return "Activité 2";
      case ActivityType.activity3:
        return "Activité 3";
      case ActivityType.activity4:
        return "Activité 4";
      case ActivityType.activity5:
        return "Activité 5";
      case ActivityType.activity6:
        return "Activité 6";
      case ActivityType.activity7:
        return "Test";
      default:
        return super.toString();
    }
  }
}
