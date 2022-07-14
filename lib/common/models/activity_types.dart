enum ActivityTypes {
  activity1,
  activity2;

  @override
  String toString() {
    switch (this) {
      case ActivityTypes.activity1:
        return "Activité 1";
      case ActivityTypes.activity2:
        return "Activité 2";
      default:
        return super.toString();
    }
  }

  static Map<ActivityTypes, bool> get emptyMap =>
      Map.fromIterable(ActivityTypes.values, value: (key) => false);
}
