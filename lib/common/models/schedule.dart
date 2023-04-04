import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

enum Day { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

extension DayAsString on Day {
  String get name {
    switch (this) {
      case (Day.sunday):
        return 'Dimanche';
      case (Day.monday):
        return 'Lundi';
      case (Day.tuesday):
        return 'Mardi';
      case (Day.wednesday):
        return 'Mercredi';
      case (Day.thursday):
        return 'Jeudi';
      case (Day.friday):
        return 'Vendredi';
      case (Day.saturday):
        return 'Samedi';
    }
  }
}

class Schedule extends ItemSerializable {
  Schedule({
    required this.dayOfWeek,
    required this.start,
    required this.end,
  });

  final Day dayOfWeek;
  final TimeOfDay start;
  final TimeOfDay end;

  Schedule.fromSerialized(map)
      : dayOfWeek = Day.values[map['day']],
        start = TimeOfDay(hour: map['start'][0], minute: map['start'][1]),
        end = TimeOfDay(hour: map['end'][0], minute: map['end'][1]);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'day': dayOfWeek.index,
      'start': [start.hour, start.minute],
      'end': [end.hour, end.minute],
    };
  }

  Schedule copyWith({Day? dayOfWeek, TimeOfDay? start, TimeOfDay? end}) {
    return Schedule(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
