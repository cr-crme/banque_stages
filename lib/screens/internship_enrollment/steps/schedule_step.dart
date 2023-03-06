import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  List<TimeStamp> days = [
    TimeStamp("Lundi"),
    TimeStamp("Mardi"),
    TimeStamp("Mercredi"),
    TimeStamp("Jeudi"),
    TimeStamp("Vendredi"),
  ];

  void askDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: dateRange,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (range != null) {
      setState(() {
        dateRange = range;
      });
    }
  }

  Future<TimeOfDay> askTime(TimeOfDay currentTime) async {
    final time =
        await showTimePicker(context: context, initialTime: currentTime);

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
            Text(
              "Dates",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(
              title: TextField(
                decoration: const InputDecoration(
                    labelText: "* Date de début du stage"),
                controller: TextEditingController(
                    text: DateFormat.yMMMEd().format(dateRange.start)),
                enabled: false,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: askDateRange,
              ),
            ),
            ListTile(
              title: TextField(
                decoration:
                    const InputDecoration(labelText: "* Date de fin du stage"),
                controller: TextEditingController(
                    text: DateFormat.yMMMEd().format(dateRange.end)),
                enabled: false,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: askDateRange,
              ),
            ),
            const ListTile(
              title: TextField(
                decoration:
                    InputDecoration(labelText: "* Nombre d'heures de stage"),
                keyboardType: TextInputType.number,
              ),
            ),
            Text(
              "Horaire",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...days.map(
              (day) => ListTile(
                leading: Checkbox(
                    value: day.selected,
                    onChanged: (value) =>
                        setState(() => day.selected = value ?? false)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day.name),
                    Row(
                      children: [
                        Text(day.start.format(context)),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final t = await askTime(day.start);
                            setState(() => day.start = t);
                          },
                        ),
                        Text(day.end.format(context)),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final t = await askTime(day.end);
                            setState(() => day.end = t);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeStamp {
  TimeStamp(String weekday) : name = weekday;

  String name;
  bool selected = true;
  TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 15, minute: 0);
}
