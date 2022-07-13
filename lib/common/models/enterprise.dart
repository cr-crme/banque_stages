import '/common/models/activity_types.dart';

class Enterprise {
  Enterprise({required this.name, this.neq, required this.activityTypes});

  String name;
  String? neq;
  Map<ActivityTypes, bool> activityTypes;
}
