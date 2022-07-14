import '/common/models/activity_types.dart';

class Enterprise {
  Enterprise(
      {required this.name,
      this.neq,
      required this.activityTypes,
      this.recrutedBy,
      required this.shareToOthers});

  String name;
  String? neq;
  Map<ActivityTypes, bool> activityTypes;
  String? recrutedBy;
  bool shareToOthers;
}
