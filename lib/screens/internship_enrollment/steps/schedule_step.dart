import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:crcrme_banque_stages/common/widgets/custom_date_picker.dart';
import 'package:crcrme_banque_stages/common/widgets/custom_time_picker.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyScheduleController {
  List<WeeklySchedule> weeklySchedules = [];
  DateTimeRange? dateRange;
  bool _hasChanged = false;
  bool get hasChanged => _hasChanged;

  WeeklyScheduleController(
      {List<WeeklySchedule>? weeklySchedules, this.dateRange})
      : weeklySchedules = weeklySchedules ?? [];

  void updateDateRange(DateTimeRange newRange) {
    dateRange = newRange;
    _hasChanged = true;
  }

  void removedWeeklySchedule(int weeklyIndex) {
    weeklySchedules.removeAt(weeklyIndex);
    _hasChanged = true;
  }

  void addToDailySchedule(int weeklyIndex, DailySchedule newDay) {
    weeklySchedules[weeklyIndex].schedule.add(newDay);
    weeklySchedules[weeklyIndex]
        .schedule
        .sort((a, b) => a.dayOfWeek.asInt - b.dayOfWeek.asInt);
    _hasChanged = true;
  }

  void updateDailyScheduleTime(
      int weeklyIndex, int dailyIndex, TimeOfDay start, TimeOfDay end) {
    weeklySchedules[weeklyIndex].schedule[dailyIndex] =
        weeklySchedules[weeklyIndex]
            .schedule[dailyIndex]
            .copyWith(start: start, end: end);
    _hasChanged = true;
  }

  void removedDailyScheduleTime(context, int weeklyIndex, int dailyIndex) {
    if (weeklySchedules[weeklyIndex].schedule.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Au moins une plage horaire est nécessaire'),
      ));
      return;
    }
    weeklySchedules[weeklyIndex].schedule.removeAt(dailyIndex);
    _hasChanged = true;
  }

  void updateDailyScheduleRange(int weeklyIndex, DateTimeRange newRange) {
    weeklySchedules[weeklyIndex] =
        weeklySchedules[weeklyIndex].copyWith(period: newRange);
    _hasChanged = true;
  }
}

const TimeOfDay _defaultStart = TimeOfDay(hour: 9, minute: 0);
const TimeOfDay _defaultEnd = TimeOfDay(hour: 15, minute: 0);

WeeklySchedule _fillNewScheduleList(DateTimeRange dateRange) {
  return WeeklySchedule(schedule: [
    DailySchedule(
        dayOfWeek: Day.monday, start: _defaultStart, end: _defaultEnd),
    DailySchedule(
        dayOfWeek: Day.tuesday, start: _defaultStart, end: _defaultEnd),
    DailySchedule(
        dayOfWeek: Day.wednesday, start: _defaultStart, end: _defaultEnd),
    DailySchedule(
        dayOfWeek: Day.thursday, start: _defaultStart, end: _defaultEnd),
    DailySchedule(
        dayOfWeek: Day.friday, start: _defaultStart, end: _defaultEnd),
  ], period: dateRange);
}

class ScheduleStep extends StatefulWidget {
  const ScheduleStep({super.key});

  @override
  State<ScheduleStep> createState() => ScheduleStepState();
}

class ScheduleStepState extends State<ScheduleStep> {
  final formKey = GlobalKey<FormState>();

  late final scheduleController = WeeklyScheduleController();
  int intershipLength = 0;

  void onScheduleChanged() {
    if (scheduleController.dateRange != null &&
        scheduleController.weeklySchedules.isEmpty) {
      scheduleController.weeklySchedules
          .add(_fillNewScheduleList(scheduleController.dateRange!));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRange(
              scheduleController: scheduleController,
              onScheduleChanged: onScheduleChanged,
            ),
            Visibility(
                visible: scheduleController.dateRange != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScheduleSelector(
                      scheduleController: scheduleController,
                      editMode: true,
                      withTitle: true,
                    ),
                    _Hours(
                        onSaved: (value) =>
                            intershipLength = int.parse(value!)),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class _DateRange extends StatefulWidget {
  const _DateRange(
      {required this.scheduleController, required this.onScheduleChanged});

  final WeeklyScheduleController scheduleController;
  final Function() onScheduleChanged;

  @override
  State<_DateRange> createState() => _DateRangeState();
}

class _DateRangeState extends State<_DateRange> {
  bool _isValid = true;

  Future<void> _promptDateRange(context) async {
    final range = await showCustomDateRangePicker(
      helpText: 'Sélectionner les dates',
      saveText: 'Enregistrer',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange: widget.scheduleController.dateRange,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (range == null) return;

    _isValid = true;
    widget.scheduleController.updateDateRange(range);

    widget.onScheduleChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Dates de stage', top: 0, left: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FormField<void>(
                    validator: (value) {
                      if (widget.scheduleController.dateRange == null) {
                        _isValid = false;
                        setState(() {});
                        return 'Nope';
                      } else {
                        _isValid = true;
                        setState(() {});
                        return null;
                      }
                    },
                    builder: (state) => Text(
                      '* Sélectionner les dates',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: _isValid ? Colors.black : Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      await _promptDateRange(context);
                      setState(() {});
                    },
                  )
                ],
              ),
              Visibility(
                visible: widget.scheduleController.dateRange != null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 36,
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Date de début',
                            border: InputBorder.none),
                        controller: TextEditingController(
                            text: widget.scheduleController.dateRange == null
                                ? null
                                : DateFormat.yMMMEd('fr_CA').format(widget
                                    .scheduleController.dateRange!.start)),
                        enabled: false,
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Date de fin', border: InputBorder.none),
                        controller: TextEditingController(
                            text: widget.scheduleController.dateRange == null
                                ? null
                                : DateFormat.yMMMEd('fr_CA').format(
                                    widget.scheduleController.dateRange!.end)),
                        enabled: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hours extends StatelessWidget {
  const _Hours({required this.onSaved});

  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Nombre d\'heures', left: 0, bottom: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: TextFormField(
            decoration: const InputDecoration(
                labelText: '* Nombre total d\'heures de stage à faire'),
            validator: (text) =>
                text!.isEmpty ? 'Indiquer un nombre d\'heures.' : null,
            keyboardType: TextInputType.number,
            onSaved: onSaved,
          ),
        ),
      ],
    );
  }
}

class ScheduleSelector extends StatefulWidget {
  const ScheduleSelector({
    super.key,
    required this.scheduleController,
    required this.editMode,
    required this.withTitle,
    this.leftPadding,
    this.periodTextSize,
  });

  final WeeklyScheduleController scheduleController;
  final bool editMode;
  final bool withTitle;
  final double? leftPadding;
  final double? periodTextSize;

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  void _promptNewDayToDailySchedule(weeklyIndex) async {
    final day = await _promptDay(context);
    if (day == null || !mounted) return;
    final start = await _promptTime(context,
        title: 'Heure de début', initial: _defaultStart);
    if (start == null || !mounted) return;
    final end =
        await _promptTime(context, title: 'Heure de fin', initial: _defaultEnd);
    if (end == null) return;

    widget.scheduleController.addToDailySchedule(
        weeklyIndex, DailySchedule(dayOfWeek: day, start: start, end: end));
    setState(() {});
  }

  void _promptUpdateToDailySchedule(int weeklyIndex, int dailyIndex) async {
    final start = await _promptTime(context,
        title: 'Heure de début',
        initial: widget.scheduleController.weeklySchedules[weeklyIndex]
            .schedule[dailyIndex].start);
    if (start == null || !mounted) return;
    final end = await _promptTime(context,
        title: 'Heure de fin',
        initial: widget.scheduleController.weeklySchedules[weeklyIndex]
            .schedule[dailyIndex].end);
    if (end == null) return;

    widget.scheduleController
        .updateDailyScheduleTime(weeklyIndex, dailyIndex, start, end);
    setState(() {});
  }

  Future<Day?> _promptDay(BuildContext context) async {
    final choice = (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Sélectionner la journée'),
          content: Padding(
            padding: const EdgeInsets.only(left: 12.0),
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

  Future<TimeOfDay?> _promptTime(BuildContext context,
      {required TimeOfDay initial, String? title}) async {
    final time = await showCustomTimePicker(
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      hourLabelText: 'Heure',
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

  void _promptChangeWeek(weeklyIndex) async {
    final range = await showCustomDateRangePicker(
      helpText: 'Sélectionner les dates',
      saveText: 'Enregistrer',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange:
          widget.scheduleController.weeklySchedules[weeklyIndex].period,
      firstDate:
          widget.scheduleController.weeklySchedules[weeklyIndex].period == null
              ? DateTime.now()
              : DateTime(widget.scheduleController.weeklySchedules[weeklyIndex]
                      .period!.start.year -
                  1),
      lastDate:
          widget.scheduleController.weeklySchedules[weeklyIndex].period == null
              ? DateTime.now()
              : DateTime(widget.scheduleController.weeklySchedules[weeklyIndex]
                      .period!.start.year +
                  2),
    );
    if (range == null) return;

    widget.scheduleController.updateDailyScheduleRange(weeklyIndex, range);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.withTitle) const SubTitle('Horaire', left: 0),
        ...widget.scheduleController.weeklySchedules
            .asMap()
            .keys
            .map<Widget>((weeklyIndex) => _ScheduleSelector(
                  periodName:
                      widget.scheduleController.weeklySchedules.length > 1
                          ? 'Période ${weeklyIndex + 1}'
                          : null,
                  periodTextSize: widget.periodTextSize,
                  weeklySchedule:
                      widget.scheduleController.weeklySchedules[weeklyIndex],
                  onRemoveWeeklySchedule:
                      widget.scheduleController.weeklySchedules.length > 1
                          ? () => setState(() => widget.scheduleController
                              .removedWeeklySchedule(weeklyIndex))
                          : null,
                  onAddDayToDailySchedule: () =>
                      _promptNewDayToDailySchedule(weeklyIndex),
                  onUpdateDailyScheduleTime: (dailyIndex) =>
                      _promptUpdateToDailySchedule(weeklyIndex, dailyIndex),
                  onRemovedDailyScheduleTime: (dailyIndex) => setState(() =>
                      widget.scheduleController.removedDailyScheduleTime(
                          context, weeklyIndex, dailyIndex)),
                  promptChangeWeeks: () => _promptChangeWeek(weeklyIndex),
                  editMode: widget.editMode,
                  leftPadding: widget.leftPadding,
                ))
            .toList(),
        if (widget.editMode)
          TextButton(
            onPressed: () => setState(() => widget
                .scheduleController.weeklySchedules
                .add(_fillNewScheduleList(
                    widget.scheduleController.dateRange!))),
            style: Theme.of(context).textButtonTheme.style!.copyWith(
                backgroundColor: Theme.of(context)
                    .elevatedButtonTheme
                    .style!
                    .backgroundColor),
            child: const Text('Ajouter une période'),
          ),
      ],
    );
  }
}

class _ScheduleSelector extends StatelessWidget {
  const _ScheduleSelector({
    required this.periodName,
    required this.periodTextSize,
    required this.weeklySchedule,
    required this.onRemoveWeeklySchedule,
    required this.onAddDayToDailySchedule,
    required this.onUpdateDailyScheduleTime,
    required this.onRemovedDailyScheduleTime,
    required this.promptChangeWeeks,
    required this.editMode,
    this.leftPadding,
  });

  final double? leftPadding;
  final String? periodName;
  final double? periodTextSize;
  final WeeklySchedule weeklySchedule;
  final Function()? onRemoveWeeklySchedule;
  final Function() onAddDayToDailySchedule;
  final Function(int) onUpdateDailyScheduleTime;
  final Function(int) onRemovedDailyScheduleTime;
  final Function() promptChangeWeeks;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (periodName != null)
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 8.0, bottom: 4.0, left: leftPadding ?? 12),
              child: Text(
                periodName!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold, fontSize: periodTextSize),
              ),
            ),
            if (editMode)
              IconButton(
                onPressed: onRemoveWeeklySchedule,
                icon: const Icon(Icons.delete, color: Colors.red),
              )
          ],
        ),
      if (periodName != null)
        Padding(
          padding: EdgeInsets.only(
              left: 8.0,
              right: editMode ? 8.0 : 24.0,
              bottom: leftPadding ?? 12),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    const Text('* Date de début'),
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(weeklySchedule.period!.start))
                  ]),
                  Column(children: [
                    const Text('* Date de fin'),
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(weeklySchedule.period!.end))
                  ]),
                ],
              ),
              if (editMode)
                IconButton(
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: promptChangeWeeks,
                )
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editMode)
              const Text('* Modifier les jours et les horaires de stage'),
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
                ...weeklySchedule.schedule.asMap().keys.map(
                      (i) => TableRow(
                        children: [
                          Text(weeklySchedule.schedule[i].dayOfWeek.name),
                          Container(),
                          Text(
                              weeklySchedule.schedule[i].start.format(context)),
                          Text(weeklySchedule.schedule[i].end.format(context)),
                          if (editMode)
                            InkWell(
                              onTap: () => onUpdateDailyScheduleTime(i),
                              child: const Icon(Icons.access_time,
                                  color: Colors.black),
                            ),
                          if (editMode)
                            InkWell(
                              onTap: () => onRemovedDailyScheduleTime(i),
                              child:
                                  const Icon(Icons.delete, color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                if (editMode)
                  TableRow(children: [
                    Container(),
                    Container(),
                    Container(),
                    Container(),
                    InkWell(
                      onTap: onAddDayToDailySchedule,
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                    Container(),
                  ]),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
