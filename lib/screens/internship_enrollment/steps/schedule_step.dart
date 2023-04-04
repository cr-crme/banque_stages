import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/schedule.dart';
import '/common/widgets/sub_title.dart';
import '/misc/form_service.dart';

class ScheduleStep extends StatefulWidget {
  const ScheduleStep({super.key});

  @override
  State<ScheduleStep> createState() => ScheduleStepState();
}

class ScheduleStepState extends State<ScheduleStep> {
  final formKey = GlobalKey<FormState>();

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(const Duration(days: 90)),
  );

  final TimeOfDay defaultStart = const TimeOfDay(hour: 9, minute: 0);
  final TimeOfDay defaultEnd = const TimeOfDay(hour: 15, minute: 0);
  late List<List<Schedule>> schedule = [_fillNewScheduleList()];

  List<Schedule> _fillNewScheduleList() {
    return [
      Schedule(dayOfWeek: Day.monday, start: defaultStart, end: defaultEnd),
      Schedule(dayOfWeek: Day.tuesday, start: defaultStart, end: defaultEnd),
      Schedule(dayOfWeek: Day.wednesday, start: defaultStart, end: defaultEnd),
      Schedule(dayOfWeek: Day.thursday, start: defaultStart, end: defaultEnd),
      Schedule(dayOfWeek: Day.friday, start: defaultStart, end: defaultEnd),
    ];
  }

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

  void _onRemovedPeriod(int scheduleIndex) async {
    schedule.removeAt(scheduleIndex);
    setState(() {});
  }

  void _onAddedTime(int scheduleIndex) async {
    final day = await _promptDay();
    if (day == null) return;
    final start =
        await _promptTime(title: 'Heure de début', initial: defaultStart);
    if (start == null) return;
    final end = await _promptTime(title: 'Heure de fin', initial: defaultEnd);
    if (end == null) return;

    schedule[scheduleIndex]
        .add(Schedule(dayOfWeek: day, start: start, end: end));
    setState(() {});
  }

  void _onUpdatedTime(int scheduleIndex, int i) async {
    final start = await _promptTime(
        title: 'Heure de début', initial: schedule[scheduleIndex][i].start);
    if (start == null) return;
    final end = await _promptTime(
        title: 'Heure de fin', initial: schedule[scheduleIndex][i].end);
    if (end == null) return;

    schedule[scheduleIndex][i] =
        schedule[scheduleIndex][i].copyWith(start: start, end: end);
    setState(() {});
  }

  void _onRemovedTime(int scheduleIndex, int index) async {
    schedule[scheduleIndex].removeAt(index);
    setState(() {});
  }

  Future<Day?> _promptDay() async {
    final choice = (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Sélectionner la journée'),
          content: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: Day.values
                  .map((day) => GestureDetector(
                      onTap: () => Navigator.of(context).pop(day),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(day.name),
                      )))
                  .toList(),
            ),
          )),
    ));
    return choice;
  }

  Future<TimeOfDay?> _promptTime(
      {required TimeOfDay initial, String? title}) async {
    final time = await showTimePicker(
      helpText: title,
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? Container(),
      ),
    );
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRange(dateRange: dateRange, promptDateRange: _promptDateRange),
            const _Hours(),
            _buildSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Horaire', left: 0),
        ...schedule
            .asMap()
            .keys
            .map<Widget>((i) => _Schedule(
                  periodName: schedule.length > 1 ? 'Période ${i + 1}' : null,
                  schedule: schedule[i],
                  onPeriodRemove:
                      schedule.length > 1 ? () => _onRemovedPeriod(i) : null,
                  onAddTime: () => _onAddedTime(i),
                  onChangedTime: (index) => _onUpdatedTime(i, index),
                  onDeleteTime: (index) => _onRemovedTime(i, index),
                ))
            .toList(),
        TextButton(
          onPressed: () => setState(() => schedule.add(_fillNewScheduleList())),
          child: const Text('Ajouter une période'),
        ),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Dates', top: 0, left: 0),
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
    return ListTile(
      title: TextFormField(
        decoration:
            const InputDecoration(labelText: '* Nombre d\'heures de stage'),
        validator: FormService.textNotEmptyValidator,
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({
    required this.periodName,
    required this.schedule,
    required this.onPeriodRemove,
    required this.onAddTime,
    required this.onChangedTime,
    required this.onDeleteTime,
  });

  final String? periodName;
  final List<Schedule> schedule;
  final Function()? onPeriodRemove;
  final Function() onAddTime;
  final Function(int) onChangedTime;
  final Function(int) onDeleteTime;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (periodName != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10.0),
              child: Text(
                periodName!,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: onPeriodRemove,
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
      const Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Text('* Sélectionner les jours et les horaires de stage'),
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
        children: [
          ...schedule.asMap().keys.map(
                (i) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        schedule[i].dayOfWeek.name,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Container(),
                    Text(schedule[i].start.format(context)),
                    Text(schedule[i].end.format(context)),
                    GestureDetector(
                      onTap: () => onChangedTime(i),
                      child: const Icon(Icons.access_time, color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () => onDeleteTime(i),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
          TableRow(children: [
            Container(),
            Container(),
            Container(),
            Container(),
            GestureDetector(
              onTap: onAddTime,
              child: const Icon(Icons.add, color: Colors.black),
            ),
            Container(),
          ]),
        ],
      ),
    ]);
  }
}
