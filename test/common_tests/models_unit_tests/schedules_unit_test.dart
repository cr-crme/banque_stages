import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('DailySchedule', () {
    test('"Day" is the right label', () {
      expect(Day.values.length, 7);
      expect(Day.monday.name, 'Lundi');
      expect(Day.tuesday.name, 'Mardi');
      expect(Day.wednesday.name, 'Mercredi');
      expect(Day.thursday.name, 'Jeudi');
      expect(Day.friday.name, 'Vendredi');
      expect(Day.saturday.name, 'Samedi');
      expect(Day.sunday.name, 'Dimanche');
    });

    test('"copyWith" behaves properly', () {
      final dailySchedule = dummyDailySchedule();

      final dailyScheduleSame = dailySchedule.copyWith();
      expect(dailyScheduleSame.id, dailySchedule.id);
      expect(dailyScheduleSame.dayOfWeek, dailySchedule.dayOfWeek);
      expect(
          dailyScheduleSame.start.toString(), dailySchedule.start.toString());
      expect(dailyScheduleSame.end.toString(), dailySchedule.end.toString());

      final dailyScheduleDifferent = dailySchedule.copyWith(
        id: 'newId',
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 1, minute: 2),
        end: const TimeOfDay(hour: 3, minute: 4),
      );

      expect(dailyScheduleDifferent.id, 'newId');
      expect(dailyScheduleDifferent.dayOfWeek, Day.tuesday);
      expect(dailyScheduleDifferent.start, const TimeOfDay(hour: 1, minute: 2));
      expect(dailyScheduleDifferent.end, const TimeOfDay(hour: 3, minute: 4));
    });

    test('serialization and deserialization works', () {
      final dailySchedule = dummyDailySchedule();
      final serialized = dailySchedule.serialize();
      final deserialized = DailySchedule.fromSerialized(serialized);

      expect(serialized, {
        'id': dailySchedule.id,
        'day': dailySchedule.dayOfWeek.index,
        'start': [9, 0],
        'end': [15, 0],
      });

      expect(deserialized.id, dailySchedule.id);
      expect(deserialized.dayOfWeek, dailySchedule.dayOfWeek);
      expect(deserialized.start, dailySchedule.start);
      expect(deserialized.end, dailySchedule.end);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = DailySchedule.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.dayOfWeek, Day.monday);
      expect(emptyDeserialized.start, const TimeOfDay(hour: 0, minute: 0));
      expect(emptyDeserialized.end, const TimeOfDay(hour: 0, minute: 0));
    });
  });

  group('WeeklySchedule', () {
    test('"copyWith" behaves properly', () {
      final schedule = dummyWeeklySchedule();

      final scheduleSame = schedule.copyWith();
      expect(scheduleSame.id, schedule.id);
      for (int i = 0; i < scheduleSame.schedule.length; i++) {
        expect(scheduleSame.schedule[i].id, schedule.schedule[i].id);
      }
      expect(scheduleSame.period.toString(), schedule.period.toString());

      final scheduleDifferent = schedule.copyWith(
          id: 'newId',
          schedule: [
            dummyDailySchedule(id: 'newDailyScheduleId'),
            dummyDailySchedule(id: 'newDailyScheduleId2'),
          ],
          period: DateTimeRange(
              start: DateTime(2020, 2, 3), end: DateTime(2020, 2, 4)));

      expect(scheduleDifferent.id, 'newId');
      expect(scheduleDifferent.schedule.length, 2);
      expect(scheduleDifferent.schedule[0].id, 'newDailyScheduleId');
      expect(scheduleDifferent.schedule[1].id, 'newDailyScheduleId2');
      expect(scheduleDifferent.period!.start, DateTime(2020, 2, 3));
      expect(scheduleDifferent.period!.end, DateTime(2020, 2, 4));
    });

    test('serialization and deserialization works', () {
      final weeklySchedule = dummyWeeklySchedule();
      final serialized = weeklySchedule.serialize();
      final deserialized = WeeklySchedule.fromSerialized(serialized);

      expect(serialized, {
        'id': weeklySchedule.id,
        'days': weeklySchedule.schedule.map((e) => e.serialize()).toList(),
        'start': weeklySchedule.period!.start.millisecondsSinceEpoch,
        'end': weeklySchedule.period!.end.millisecondsSinceEpoch,
      });

      expect(deserialized.id, weeklySchedule.id);
      expect(deserialized.schedule.length, weeklySchedule.schedule.length);
      expect(deserialized.period, weeklySchedule.period);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          WeeklySchedule.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.schedule.length, 0);
      expect(emptyDeserialized.period, isNull);
    });
  });
}
