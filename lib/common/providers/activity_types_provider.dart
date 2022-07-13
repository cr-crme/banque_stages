import 'package:flutter/material.dart';

import '/common/models/activity_types.dart';

class ActivityTypesProvider extends ChangeNotifier {
  ActivityTypesProvider({Map<ActivityTypes, bool>? activityTypes})
      : activityTypes = activityTypes ?? ActivityTypes.emptyMap;

  final Map<ActivityTypes, bool> activityTypes;

  void update(ActivityTypes key, bool newValue) {
    activityTypes[key] = newValue;
    notifyListeners();
  }
}
