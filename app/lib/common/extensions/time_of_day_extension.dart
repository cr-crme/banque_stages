import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:flutter/material.dart';

extension TimeOfDayExtension on time_utils.TimeOfDay {
  String format(context) {
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return timeOfDay.format(context).toString();
  }
}
