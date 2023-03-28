import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/schedule.dart';

class ScheduleStep extends StatefulWidget {
  const ScheduleStep({
    super.key,
  });

  @override
  State<ScheduleStep> createState() => ScheduleStepState();
}

class ScheduleStepState extends State<ScheduleStep> {
  final formKey = GlobalKey<FormState>();

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 90)),
  );

  List<Schedule> schedule = [
    Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 9, minute: 0)),
    Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 9, minute: 0)),
    Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 9, minute: 0)),
    Schedule(
        dayOfWeek: Day.thursday,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 9, minute: 0)),
    Schedule(
        dayOfWeek: Day.friday,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 9, minute: 0)),
  ];

  void _promptDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (range == null) return;

    dateRange = range;
    setState(() {});
  }

  Future<TimeOfDay> _promptTime(TimeOfDay currentTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? Container(),
      ),
    );

    if (time == null) {
      return currentTime;
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRange(dateRange: dateRange, promptDateRange: _promptDateRange),
            const _Hours(),
            _Schedule(
              schedule: schedule,
              onChangedTime: (i) async {
                final start = await _promptTime(schedule[i].start);
                final end = await _promptTime(schedule[i].end);
                setState(() =>
                    schedule[i] = schedule[i].copyWith(start: start, end: end));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.dateRange,
    required this.promptDateRange,
  });

  final DateTimeRange dateRange;
  final Function() promptDateRange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Dates',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 3 / 4,
              child: Column(
                children: [
                  ListTile(
                    title: TextField(
                      decoration: const InputDecoration(
                          labelText: '* Date de début du stage',
                          border: InputBorder.none),
                      controller: TextEditingController(
                          text: DateFormat.yMMMEd().format(dateRange.start)),
                      enabled: false,
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      decoration: const InputDecoration(
                          labelText: '* Date de fin du stage',
                          border: InputBorder.none),
                      controller: TextEditingController(
                          text: DateFormat.yMMMEd().format(dateRange.end)),
                      enabled: false,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.blue,
              ),
              onPressed: promptDateRange,
            )
          ],
        ),
      ],
    );
  }
}

class _Hours extends StatelessWidget {
  const _Hours();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: TextField(
        decoration: InputDecoration(labelText: '* Nombre d\'heures de stage'),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.schedule, required this.onChangedTime});

  final List<Schedule> schedule;
  final Function(int) onChangedTime;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Horaire',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(1),
          5: FlexColumnWidth(1),
        },
        children: schedule
            .asMap()
            .keys
            .map(
              (i) => TableRow(
                children: [
                  Text(
                    schedule[i].dayOfWeek.name,
                    textAlign: TextAlign.right,
                  ),
                  Flexible(child: Container()),
                  Text(schedule[i].start.format(context)),
                  Text(schedule[i].end.format(context)),
                  GestureDetector(
                    onTap: () => onChangedTime(i),
                    child: const Icon(Icons.access_time, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            )
            .toList(),
      )
    ]);
  }
}
