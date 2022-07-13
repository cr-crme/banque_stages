enum ActivityTypes {
  activity1,
  activity2;

  String get humanName {
    switch (this) {
      case ActivityTypes.activity1:
        return "Activité 1";
      case ActivityTypes.activity2:
        return "Activité 2";
      default:
        return name;
    }
  }
}
