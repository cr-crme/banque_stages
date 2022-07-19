enum ActivityType {
  activity1,
  activity2;

  String get id => name;

  @override
  String toString() {
    switch (this) {
      case ActivityType.activity1:
        return "Activité 1";
      case ActivityType.activity2:
        return "Activité 2";
      default:
        return super.toString();
    }
  }
}
