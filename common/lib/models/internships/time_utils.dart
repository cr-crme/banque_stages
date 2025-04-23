class TimeOfDay {
  final int hour;
  final int minute;
  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});

  @override
  String toString() {
    return 'DateTimeRange(start: $start, end: $end)';
  }
}
