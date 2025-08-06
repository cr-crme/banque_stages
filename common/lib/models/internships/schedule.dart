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

  static fromName(String name) {
    return Day.values.firstWhere(
      (element) => element.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Day.monday,
    );
  }

  @override
  String toString() => name;
}

class DailySchedule extends ItemSerializable {
  DailySchedule({
    super.id,
    required this.start,
    required this.end,
    required this.breakStart,
    required this.breakEnd,
  });

  final TimeOfDay start;
  final TimeOfDay end;
  final TimeOfDay? breakStart;
  final TimeOfDay? breakEnd;

  DailySchedule.fromSerialized(super.map)
      : start = map['start'] == null
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
        start: start,
        end: end,
        breakStart: breakStart,
        breakEnd: breakEnd,
      );

  DailySchedule copyWith({
    String? id,
    TimeOfDay? start,
    TimeOfDay? end,
    TimeOfDay? breakStart,
    TimeOfDay? breakEnd,
  }) =>
      DailySchedule(
        id: id ?? this.id,
        start: start ?? this.start,
        end: end ?? this.end,
        breakStart: breakStart ?? this.breakStart,
        breakEnd: breakEnd ?? this.breakEnd,
      );

  @override
  String toString() {
    return 'DailySchedule(id: $id, start: $start, end: $end)';
  }
}

class WeeklySchedule extends ItemSerializable {
  WeeklySchedule({
    super.id,
    required this.schedule,
    required this.period,
  });

  final Map<Day, DailySchedule?> schedule;
  final DateTimeRange period;

  WeeklySchedule.fromSerialized(super.map)
      : schedule = (map['days'] as Map?)?.map((day, e) =>
                MapEntry(Day.values[day], DailySchedule.fromSerialized(e))) ??
            {},
        period = DateTimeRange(
            start: DateTime.fromMillisecondsSinceEpoch(map['start'] ?? 0),
            end: DateTime.fromMillisecondsSinceEpoch(map['end'] ?? 0)),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'days': schedule.map((day, e) => MapEntry(day.index, e?.serialize())),
        'start': period.start.millisecondsSinceEpoch,
        'end': period.end.millisecondsSinceEpoch,
      };

  ///
  /// Similar to [copyWith], but enforce the change of id
  WeeklySchedule duplicate() => WeeklySchedule(
        schedule: schedule.map((day, e) => MapEntry(day, e?.duplicate())),
        period: period,
      );

  WeeklySchedule copyWith({
    String? id,
    Map<Day, DailySchedule>? schedule,
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

class InternshipHelpers {
  static List<WeeklySchedule> copySchedules(
    List<WeeklySchedule>? schedules, {
    bool keepId = true,
  }) =>
      schedules
          ?.map(
            (schedule) => WeeklySchedule(
              id: keepId ? schedule.id : null,
              period: DateTimeRange(
                start: schedule.period.start,
                end: schedule.period.end,
              ),
              schedule: schedule.schedule.map(
                (day, entry) => MapEntry(
                  day,
                  entry == null
                      ? null
                      : DailySchedule(
                          id: keepId ? entry.id : null,
                          start: TimeOfDay(
                            hour: entry.start.hour,
                            minute: entry.start.minute,
                          ),
                          end: TimeOfDay(
                            hour: entry.end.hour,
                            minute: entry.end.minute,
                          ),
                          breakStart: entry.breakStart == null
                              ? null
                              : TimeOfDay(
                                  hour: entry.breakStart!.hour,
                                  minute: entry.breakStart!.minute,
                                ),
                          breakEnd: entry.breakEnd == null
                              ? null
                              : TimeOfDay(
                                  hour: entry.breakEnd!.hour,
                                  minute: entry.breakEnd!.minute,
                                ),
                        ),
                ),
              ),
            ),
          )
          .toList() ??
      [];

  static bool areSchedulesEqual(
    List<WeeklySchedule> listA,
    List<WeeklySchedule> listB,
  ) {
    if (listA.length != listB.length) return false;

    for (int i = 0; i < listA.length; i++) {
      final a = listA[i];
      final b = listB[i];

      if (a.period.start != b.period.start || a.period.end != b.period.end) {
        return false;
      }

      if (a.schedule.length != b.schedule.length) return false;

      if (a.schedule.keys.length != b.schedule.keys.length) return false;
      if (a.schedule.keys
          .toSet()
          .difference(b.schedule.keys.toSet())
          .isNotEmpty) {
        return false;
      }

      final days = a.schedule.keys.toList();
      for (final day in days) {
        final dayA = a.schedule[day]!;
        final dayB = b.schedule[day]!;

        if (dayA.start.hour != dayB.start.hour ||
            dayA.start.minute != dayB.start.minute ||
            dayA.end.hour != dayB.end.hour ||
            dayA.end.minute != dayB.end.minute) {
          return false;
        }
      }
    }
    return true;
  }
}
