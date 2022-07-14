import 'package:flutter/material.dart';

import '/common/models/activity_types.dart';

class ActivityTypesProvider extends ChangeNotifier {
  ActivityTypesProvider({Map<ActivityTypes, bool>? activityTypes})
      : _activityTypes = activityTypes ?? ActivityTypes.emptyMap;

  final Map<ActivityTypes, bool> _activityTypes;

  Map<ActivityTypes, bool> get activityTypes => _activityTypes;

  void update(ActivityTypes key, bool newValue) {
    _activityTypes[key] = newValue;
    notifyListeners();
  }
}
