import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/widgets/custom_date_picker.dart';
import 'package:common_flutter/widgets/custom_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO Check this file

extension TimeOfDayExtension on time_utils.TimeOfDay {
  String format(context) {
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return timeOfDay.format(context).toString();
  }
}

class WeeklySchedulesController {
  List<WeeklySchedule> weeklySchedules = [];
  time_utils.DateTimeRange? _dateRange;
  time_utils.DateTimeRange? get dateRange => _dateRange;
  bool _hasChanged = false;
  WeeklySchedulesController({
    List<WeeklySchedule>? weeklySchedules,
    time_utils.DateTimeRange? dateRange,
  }) : _dateRange = dateRange?.copy(),
       weeklySchedules = InternshipHelpers.copySchedules(
         weeklySchedules,
         keepId: true,
       );

  bool get hasChanged => _hasChanged;
  set dateRange(time_utils.DateTimeRange? newRange) {
    _dateRange = newRange;
    if (weeklySchedules.length == 1) {
      weeklySchedules[0] = weeklySchedules[0].copyWith(period: newRange);
    }
    _hasChanged = true;
  }

  void addWeeklySchedule(WeeklySchedule newSchedule) {
    weeklySchedules.add(newSchedule);
    _hasChanged = true;
  }

  void removedWeeklySchedule(int weeklyIndex) {
    weeklySchedules.removeAt(weeklyIndex);
    _hasChanged = true;
  }

  void updateDailyScheduleTime(
    int weeklyIndex,
    Day day, {
    required DailySchedule? schedule,
  }) {
    if (schedule == null) {
      weeklySchedules[weeklyIndex].schedule.remove(day);
    } else {
      weeklySchedules[weeklyIndex].schedule[day] =
          weeklySchedules[weeklyIndex].schedule[day]?.copyWith(
            start: schedule.start,
            end: schedule.end,
            breakStart: schedule.breakStart,
            breakEnd: schedule.breakEnd,
          ) ??
          schedule;
    }

    _hasChanged = true;
  }

  void updateDailyScheduleRange(
    int weeklyIndex,
    time_utils.DateTimeRange newRange,
  ) {
    weeklySchedules[weeklyIndex] = weeklySchedules[weeklyIndex].copyWith(
      period: newRange,
    );
    _hasChanged = true;
  }

  void dispose() {}
}

const time_utils.TimeOfDay _defaultStart = time_utils.TimeOfDay(
  hour: 9,
  minute: 0,
);
const time_utils.TimeOfDay _defaultEnd = time_utils.TimeOfDay(
  hour: 15,
  minute: 0,
);
const time_utils.TimeOfDay _defaultBreakStart = time_utils.TimeOfDay(
  hour: 12,
  minute: 0,
);
const time_utils.TimeOfDay _defaultBreakEnd = time_utils.TimeOfDay(
  hour: 13,
  minute: 0,
);

WeeklySchedule _fillNewScheduleList(time_utils.DateTimeRange dateRange) {
  return WeeklySchedule(schedule: {}, period: dateRange);
}

class ScheduleListTile extends StatefulWidget {
  const ScheduleListTile({
    super.key,
    required this.scheduleController,
    required this.editMode,
  });

  final bool editMode;
  final WeeklySchedulesController scheduleController;

  @override
  State<ScheduleListTile> createState() => _ScheduleListTileState();
}

class _ScheduleListTileState extends State<ScheduleListTile> {
  final formKey = GlobalKey<FormState>();

  void onScheduleChanged() {
    if (widget.scheduleController.dateRange != null &&
        widget.scheduleController.weeklySchedules.isEmpty) {
      widget.scheduleController.weeklySchedules.add(
        _fillNewScheduleList(widget.scheduleController.dateRange!),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateRange(
            scheduleController: widget.scheduleController,
            onScheduleChanged: onScheduleChanged,
            editMode: widget.editMode,
          ),
          Visibility(
            visible: widget.scheduleController.dateRange != null,
            child: ScheduleSelector(
              scheduleController: widget.scheduleController,
              editMode: widget.editMode,
              withTitle: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRange extends StatefulWidget {
  const _DateRange({
    required this.scheduleController,
    required this.onScheduleChanged,
    required this.editMode,
  });

  final WeeklySchedulesController scheduleController;
  final Function() onScheduleChanged;
  final bool editMode;

  @override
  State<_DateRange> createState() => _DateRangeState();
}

class _DateRangeState extends State<_DateRange> {
  bool _isValid = true;

  Future<void> _promptDateRange(context) async {
    final referenceDate =
        (widget.scheduleController.dateRange?.start ?? DateTime.now());
    final range = await showCustomDateRangePicker(
      helpText: 'Sélectionner les dates',
      saveText: 'Confirmer',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange: widget.scheduleController.dateRange,
      firstDate: DateTime(referenceDate.year - 1),
      lastDate: DateTime(referenceDate.year + 2),
    );
    if (range == null) return;

    _isValid = true;
    widget.scheduleController.dateRange = range;

    widget.onScheduleChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dates de stage'),

        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.editMode)
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
                      builder:
                          (state) => Text(
                            '* Sélectionner les dates',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall!.copyWith(
                              color: _isValid ? Colors.black : Colors.red,
                            ),
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
                    ),
                  ],
                ),
              Visibility(
                visible: widget.scheduleController.dateRange != null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                        initialValue:
                            widget.scheduleController.dateRange == null
                                ? null
                                : DateFormat.yMMMEd('fr_CA').format(
                                  widget.scheduleController.dateRange!.start,
                                ),
                        style: TextStyle(color: Colors.black),
                        enabled: false,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                        initialValue:
                            widget.scheduleController.dateRange == null
                                ? null
                                : DateFormat.yMMMEd('fr_CA').format(
                                  widget.scheduleController.dateRange!.end,
                                ),
                        style: TextStyle(color: Colors.black),
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

class ScheduleSelector extends StatefulWidget {
  const ScheduleSelector({
    super.key,
    required this.scheduleController,
    required this.editMode,
    required this.withTitle,
    this.leftPadding,
    this.periodTextSize,
  });

  final WeeklySchedulesController scheduleController;
  final bool editMode;
  final bool withTitle;
  final double? leftPadding;
  final double? periodTextSize;

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  void _promptNewDayToDailySchedule(int weeklyIndex, Day day) async {
    Future<time_utils.TimeOfDay?> promptTime({
      required time_utils.TimeOfDay initial,
      String? title,
    }) async => _promptTime(context, initial: initial, title: title);

    final start = await promptTime(
      title: 'Heure de début',
      initial: _defaultStart,
    );
    if (start == null || !mounted) return;

    final end = await promptTime(title: 'Heure de fin', initial: _defaultEnd);
    if (end == null || !mounted) return;

    final breakStart = await promptTime(
      title: 'Heure de début de pause',
      initial: _defaultBreakStart,
    );
    if (breakStart == null || !mounted) return;

    final breakEnd = await promptTime(
      title: 'Heure de fin de pause',
      initial: _defaultBreakEnd,
    );
    if (breakEnd == null || !mounted) return;

    widget.scheduleController.updateDailyScheduleTime(
      weeklyIndex,
      day,
      schedule: DailySchedule(
        start: start,
        end: end,
        breakStart: breakStart,
        breakEnd: breakEnd,
      ),
    );
    setState(() {});
  }

  Future<time_utils.TimeOfDay?> _promptTime(
    BuildContext context, {
    required time_utils.TimeOfDay initial,
    String? title,
  }) async {
    final time = await showCustomTimePicker(
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      helpText: title,
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? Container(),
          ),
    );

    if (time == null) return null;
    return time_utils.TimeOfDay(hour: time.hour, minute: time.minute);
  }

  void _promptChangeWeek(weeklyIndex) async {
    final period =
        widget.scheduleController.weeklySchedules[weeklyIndex].period;
    final range = await showCustomDateRangePicker(
      helpText: 'Sélectionner les dates',
      saveText: 'Confirmer',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange: period,
      firstDate: DateTime(period.start.year - 1),
      lastDate: DateTime(period.start.year + 2),
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
        if (widget.withTitle) const Text('Horaire (pause)'),
        ...widget.scheduleController.weeklySchedules.asMap().keys.map<Widget>(
          (weeklyIndex) => _ScheduleSelector(
            periodName:
                widget.scheduleController.weeklySchedules.length > 1
                    ? 'Période ${weeklyIndex + 1}'
                    : null,
            periodTextSize: widget.periodTextSize,
            weeklySchedule:
                widget.scheduleController.weeklySchedules[weeklyIndex],
            onRemoveWeeklySchedule:
                widget.scheduleController.weeklySchedules.length > 1
                    ? () => setState(
                      () => widget.scheduleController.removedWeeklySchedule(
                        weeklyIndex,
                      ),
                    )
                    : null,
            onAddDayToDailySchedule:
                (day) => _promptNewDayToDailySchedule(weeklyIndex, day),
            onUpdateDailyScheduleTime: (dailyIndex) {},
            // TODO THIS: _promptTime(weeklyIndex, dailyIndex),
            onRemovedDailyScheduleTime:
                (day) => setState(
                  () => widget.scheduleController.updateDailyScheduleTime(
                    weeklyIndex,
                    day,
                    schedule: null,
                  ),
                ),
            promptChangeWeeks: () => _promptChangeWeek(weeklyIndex),
            editMode: widget.editMode,
            leftPadding: widget.leftPadding,
          ),
        ),
        if (widget.editMode)
          TextButton(
            onPressed:
                () => setState(
                  () => widget.scheduleController.addWeeklySchedule(
                    _fillNewScheduleList(widget.scheduleController.dateRange!),
                  ),
                ),
            style: Theme.of(context).textButtonTheme.style!.copyWith(
              backgroundColor:
                  Theme.of(context).elevatedButtonTheme.style!.backgroundColor,
            ),
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
  final Function(Day) onAddDayToDailySchedule;
  final Function(Day) onUpdateDailyScheduleTime;
  final Function(Day) onRemovedDailyScheduleTime;
  final Function() promptChangeWeeks;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (periodName != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 8.0,
                  bottom: 4.0,
                  left: leftPadding ?? 12,
                ),
                child: Text(
                  periodName!,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: periodTextSize,
                  ),
                ),
              ),
              if (editMode)
                IconButton(
                  onPressed: onRemoveWeeklySchedule,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
            ],
          ),
        if (periodName != null)
          Padding(
            padding: EdgeInsets.only(
              left: 8.0,
              right: editMode ? 8.0 : 24.0,
              bottom: leftPadding ?? 12,
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('* Date de début'),
                        Text(
                          DateFormat.yMMMEd(
                            'fr_CA',
                          ).format(weeklySchedule.period.start),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('* Date de fin'),
                        Text(
                          DateFormat.yMMMEd(
                            'fr_CA',
                          ).format(weeklySchedule.period.end),
                        ),
                      ],
                    ),
                  ],
                ),
                if (editMode)
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.blue,
                    ),
                    onPressed: promptChangeWeeks,
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (editMode)
                const Text(
                  '* Modifier les jours et les horaires de stage (pause)',
                ),
              Table(
                defaultVerticalAlignment:
                    ResponsiveService.getScreenSize(context) == ScreenSize.small
                        ? TableCellVerticalAlignment.top
                        : TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(1.7),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                  3: FlexColumnWidth(0.7),
                  4: FlexColumnWidth(0.7),
                },
                children: [
                  ...weeklySchedule.schedule.keys.map(
                    (day) => TableRow(
                      children: [
                        Text(day.name),
                        Text(
                          '${weeklySchedule.schedule[day]?.start.format(context)} / '
                          '${weeklySchedule.schedule[day]?.end.format(context)}',
                        ),
                        Text(
                          '(${weeklySchedule.schedule[day]?.breakStart?.format(context) ?? ''} / '
                          '${weeklySchedule.schedule[day]?.breakEnd?.format(context) ?? ''})',
                        ),
                        if (editMode)
                          InkWell(
                            onTap: () => onUpdateDailyScheduleTime(day),
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.black,
                            ),
                          ),
                        if (editMode)
                          InkWell(
                            onTap: () => onRemovedDailyScheduleTime(day),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
