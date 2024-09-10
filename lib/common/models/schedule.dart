import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  String get name {
    switch (this) {
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
      case (Day.sunday):
        return 'Dimanche';
    }
  }
}

class DailySchedule extends ItemSerializable {
  DailySchedule({
    super.id,
    required this.dayOfWeek,
    required this.start,
    required this.end,
  });

  final Day dayOfWeek;
  final TimeOfDay start;
  final TimeOfDay end;

  DailySchedule.fromSerialized(super.map)
      : dayOfWeek = map['day'] == null ? Day.monday : Day.values[map['day']],
        start = map['start'] == null
            ? const TimeOfDay(hour: 0, minute: 0)
            : TimeOfDay(hour: map['start'][0], minute: map['start'][1]),
        end = map['end'] == null
            ? const TimeOfDay(hour: 0, minute: 0)
            : TimeOfDay(hour: map['end'][0], minute: map['end'][1]),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'day': dayOfWeek.index,
        'start': [start.hour, start.minute],
        'end': [end.hour, end.minute],
      };

  DailySchedule copyWith({
    String? id,
    Day? dayOfWeek,
    TimeOfDay? start,
    TimeOfDay? end,
  }) =>
      DailySchedule(
        id: id ?? this.id,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        start: start ?? this.start,
        end: end ?? this.end,
      );
}

class WeeklySchedule extends ItemSerializable {
  WeeklySchedule({
    super.id,
    required this.schedule,
    required this.period,
  });

  final List<DailySchedule> schedule;
  final DateTimeRange? period;

  WeeklySchedule.fromSerialized(super.map)
      : schedule = (map['days'] as List?)
                ?.map((e) => DailySchedule.fromSerialized(e))
                .toList() ??
            [],
        period = map['start'] == null || map['end'] == null
            ? null
            : DateTimeRange(
                start: DateTime.fromMillisecondsSinceEpoch(map['start']),
                end: DateTime.fromMillisecondsSinceEpoch(map['end'])),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'days': schedule.map((e) => e.serialize()).toList(),
        'start': period!.start.millisecondsSinceEpoch,
        'end': period!.end.millisecondsSinceEpoch,
      };

  WeeklySchedule copyWith({
    String? id,
    List<DailySchedule>? schedule,
    DateTimeRange? period,
  }) =>
      WeeklySchedule(
        id: id ?? this.id,
        schedule: schedule ?? this.schedule,
        period: period ?? this.period,
      );
}
