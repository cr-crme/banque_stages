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

class DailySchedule extends ItemSerializable {
  DailySchedule({
    required this.dayOfWeek,
    required this.start,
    required this.end,
  });

  final Day dayOfWeek;
  final TimeOfDay start;
  final TimeOfDay end;

  DailySchedule.fromSerialized(map)
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

  DailySchedule copyWith({Day? dayOfWeek, TimeOfDay? start, TimeOfDay? end}) {
    return DailySchedule(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  DailySchedule deepCopy() {
    return DailySchedule(
      dayOfWeek: Day.values[dayOfWeek.index],
      start: TimeOfDay(hour: start.hour, minute: start.minute),
      end: TimeOfDay(hour: end.hour, minute: end.minute),
    );
  }
}

class WeeklySchedule extends ItemSerializable {
  WeeklySchedule({
    required this.schedule,
    required this.period,
  });

  final List<DailySchedule> schedule;
  final DateTimeRange period;

  WeeklySchedule.fromSerialized(map)
      : schedule = (map['days'] as List)
            .map((e) => DailySchedule.fromSerialized(e))
            .toList(),
        period = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(map['start']),
            end: DateTime.fromMillisecondsSinceEpoch(map['end']));

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'days': schedule.map((e) => e.serialize()).toList(),
      'start': period.start.millisecondsSinceEpoch,
      'end': period.end.millisecondsSinceEpoch,
    };
  }

  WeeklySchedule copyWith({
    List<DailySchedule>? schedule,
    DateTimeRange? period,
  }) {
    return WeeklySchedule(
      schedule: schedule ?? this.schedule,
      period: period ?? this.period,
    );
  }

  WeeklySchedule deepCopy() {
    return WeeklySchedule(
        schedule: schedule.map((e) => e.deepCopy()).toList(),
        period: DateTimeRange(start: period.start, end: period.end));
  }
}
