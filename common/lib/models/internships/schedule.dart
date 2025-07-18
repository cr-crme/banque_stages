import 'package:common/models/internships/time_utils.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

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
    required this.breakStart,
    required this.breakEnd,
  });

  final Day dayOfWeek;
  final TimeOfDay start;
  final TimeOfDay end;
  final TimeOfDay? breakStart;
  final TimeOfDay? breakEnd;

  DailySchedule.fromSerialized(super.map)
      : dayOfWeek = map['day'] == null ? Day.monday : Day.values[map['day']],
        start = map['start'] == null
            ? const TimeOfDay(hour: 0, minute: 0)
            : TimeOfDay(hour: map['start'][0], minute: map['start'][1]),
        end = map['end'] == null
            ? const TimeOfDay(hour: 0, minute: 0)
            : TimeOfDay(hour: map['end'][0], minute: map['end'][1]),
        breakStart = map['break_start'] == null
            ? null
            : TimeOfDay(
                hour: map['break_start'][0], minute: map['break_start'][1]),
        breakEnd = map['break_end'] == null
            ? null
            : TimeOfDay(hour: map['break_end'][0], minute: map['break_end'][1]),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'day': dayOfWeek.index,
        'start': [start.hour, start.minute],
        'end': [end.hour, end.minute],
        'break_start':
            breakStart != null ? [breakStart!.hour, breakStart!.minute] : null,
        'break_end':
            breakEnd != null ? [breakEnd!.hour, breakEnd!.minute] : null,
      };

  ///
  /// Similar to [copyWith], but enforce the change of id
  DailySchedule duplicate() => DailySchedule(
        dayOfWeek: dayOfWeek,
        start: start,
        end: end,
        breakStart: breakStart,
        breakEnd: breakEnd,
      );

  DailySchedule copyWith({
    String? id,
    Day? dayOfWeek,
    TimeOfDay? start,
    TimeOfDay? end,
    TimeOfDay? breakStart,
    TimeOfDay? breakEnd,
  }) =>
      DailySchedule(
        id: id ?? this.id,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        start: start ?? this.start,
        end: end ?? this.end,
        breakStart: breakStart ?? this.breakStart,
        breakEnd: breakEnd ?? this.breakEnd,
      );

  @override
  String toString() {
    return 'DailySchedule(id: $id, dayOfWeek: ${dayOfWeek.name}, start: $start, end: $end)';
  }
}

class WeeklySchedule extends ItemSerializable {
  WeeklySchedule({
    super.id,
    required this.schedule,
    required this.period,
  });

  final List<DailySchedule> schedule;
  final DateTimeRange period;

  WeeklySchedule.fromSerialized(super.map)
      : schedule = (map['days'] as List?)
                ?.map((e) => DailySchedule.fromSerialized(e))
                .toList() ??
            [],
        period = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(map['start'] ?? 0),
            end: DateTime.fromMillisecondsSinceEpoch(map['end'] ?? 0)),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'days': schedule.map((e) => e.serialize()).toList(),
        'start': period.start.millisecondsSinceEpoch,
        'end': period.end.millisecondsSinceEpoch,
      };

  ///
  /// Similar to [copyWith], but enforce the change of id
  WeeklySchedule duplicate() => WeeklySchedule(
        schedule: schedule.map((e) => e.duplicate()).toList(),
        period: period,
      );

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

  @override
  String toString() {
    return 'WeeklySchedule(id: $id, schedule: $schedule, period: $period)';
  }
}
