import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/widgets/custom_date_picker.dart';
import 'package:common_flutter/widgets/custom_time_picker.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension TimeOfDayExtension on time_utils.TimeOfDay {
  String format(context) {
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return timeOfDay.format(context).toString();
  }
}

class InternshipHelpers {
  static List<WeeklySchedule> copySchedules(
    List<WeeklySchedule> schedules, {
    bool keepId = true,
  }) =>
      schedules
          .map(
            (schedule) => WeeklySchedule(
              id: keepId ? schedule.id : null,
              period: time_utils.DateTimeRange(
                start: schedule.period.start,
                end: schedule.period.end,
              ),
              schedule:
                  schedule.schedule
                      .map(
                        (day) => DailySchedule(
                          id: keepId ? day.id : null,
                          dayOfWeek: day.dayOfWeek,
                          start: time_utils.TimeOfDay(
                            hour: day.start.hour,
                            minute: day.start.minute,
                          ),
                          end: time_utils.TimeOfDay(
                            hour: day.end.hour,
                            minute: day.end.minute,
                          ),
                          breakStart:
                              day.breakStart == null
                                  ? null
                                  : time_utils.TimeOfDay(
                                    hour: day.breakStart!.hour,
                                    minute: day.breakStart!.minute,
                                  ),
                          breakEnd:
                              day.breakEnd == null
                                  ? null
                                  : time_utils.TimeOfDay(
                                    hour: day.breakEnd!.hour,
                                    minute: day.breakEnd!.minute,
                                  ),
                        ),
                      )
                      .toList(),
            ),
          )
          .toList();

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

      for (int i = 0; i < a.schedule.length; i++) {
        final dayA = a.schedule[i];
        final dayB = b.schedule[i];

        if (dayA.dayOfWeek != dayB.dayOfWeek ||
            dayA.start.hour != dayB.start.hour ||
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

class SchedulesController {
  List<WeeklySchedule> weeklySchedules = [];
  time_utils.DateTimeRange? _dateRange;
  time_utils.DateTimeRange? get dateRange => _dateRange;
  bool _hasChanged = false;

  SchedulesController({
    List<WeeklySchedule>? weeklySchedules,
    time_utils.DateTimeRange? dateRange,
  }) : _dateRange =
           dateRange == null
               ? null
               : time_utils.DateTimeRange(
                 start: dateRange.start,
                 end: dateRange.end,
               ),
       weeklySchedules =
           weeklySchedules == null
               ? []
               : InternshipHelpers.copySchedules(weeklySchedules, keepId: true);

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

  void addToDailySchedule(int weeklyIndex, DailySchedule newDay) {
    weeklySchedules[weeklyIndex].schedule.add(newDay);
    weeklySchedules[weeklyIndex].schedule.sort(
      (a, b) => a.dayOfWeek.index - b.dayOfWeek.index,
    );
    _hasChanged = true;
  }

  void updateDailyScheduleTime(
    int weeklyIndex,
    int dailyIndex, {
    required time_utils.TimeOfDay start,
    required time_utils.TimeOfDay end,
    required time_utils.TimeOfDay breakStart,
    required time_utils.TimeOfDay breakEnd,
  }) {
    weeklySchedules[weeklyIndex].schedule[dailyIndex] =
        weeklySchedules[weeklyIndex].schedule[dailyIndex].copyWith(
          start: start,
          end: end,
          breakStart: breakStart,
          breakEnd: breakEnd,
        );
    _hasChanged = true;
  }

  void removedDailyScheduleTime(context, int weeklyIndex, int dailyIndex) {
    if (weeklySchedules[weeklyIndex].schedule.length == 1) {
      showSnackBar(
        context,
        message: 'Au moins une plage horaire est nécessaire',
      );
      return;
    }
    weeklySchedules[weeklyIndex].schedule.removeAt(dailyIndex);
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
  return WeeklySchedule(
    schedule: [
      DailySchedule(
        dayOfWeek: Day.monday,
        start: _defaultStart,
        end: _defaultEnd,
        breakStart: _defaultBreakStart,
        breakEnd: _defaultBreakEnd,
      ),
      DailySchedule(
        dayOfWeek: Day.tuesday,
        start: _defaultStart,
        end: _defaultEnd,
        breakStart: _defaultBreakStart,
        breakEnd: _defaultBreakEnd,
      ),
      DailySchedule(
        dayOfWeek: Day.wednesday,
        start: _defaultStart,
        end: _defaultEnd,
        breakStart: _defaultBreakStart,
        breakEnd: _defaultBreakEnd,
      ),
      DailySchedule(
        dayOfWeek: Day.thursday,
        start: _defaultStart,
        end: _defaultEnd,
        breakStart: _defaultBreakStart,
        breakEnd: _defaultBreakEnd,
      ),
      DailySchedule(
        dayOfWeek: Day.friday,
        start: _defaultStart,
        end: _defaultEnd,
        breakStart: _defaultBreakStart,
        breakEnd: _defaultBreakEnd,
      ),
    ],
    period: dateRange,
  );
}

class ScheduleListTile extends StatefulWidget {
  const ScheduleListTile({
    super.key,
    required this.scheduleController,
    required this.editMode,
  });

  final bool editMode;
  final SchedulesController scheduleController;

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

  final SchedulesController scheduleController;
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

  final SchedulesController scheduleController;
  final bool editMode;
  final bool withTitle;
  final double? leftPadding;
  final double? periodTextSize;

  @override
  State<ScheduleSelector> createState() => _ScheduleSelectorState();
}

class _ScheduleSelectorState extends State<ScheduleSelector> {
  void _promptNewDayToDailySchedule(weeklyIndex) async {
    Future<time_utils.TimeOfDay?> promptTime({
      required time_utils.TimeOfDay initial,
      String? title,
    }) async => _promptTime(context, initial: initial, title: title);

    final day = await _promptDay(context);
    if (day == null || !mounted) return;
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

    widget.scheduleController.addToDailySchedule(
      weeklyIndex,
      DailySchedule(
        dayOfWeek: day,
        start: start,
        end: end,
        breakStart: breakStart,
        breakEnd: breakEnd,
      ),
    );
    setState(() {});
  }

  void _promptUpdateToDailySchedule(int weeklyIndex, int dailyIndex) async {
    Future<time_utils.TimeOfDay?> promptTime({
      required time_utils.TimeOfDay initial,
      String? title,
    }) async => _promptTime(context, initial: initial, title: title);

    final start = await _promptTime(
      context,
      title: 'Heure de début',
      initial:
          widget
              .scheduleController
              .weeklySchedules[weeklyIndex]
              .schedule[dailyIndex]
              .start,
    );
    if (start == null || !mounted) return;

    final end = await promptTime(
      title: 'Heure de fin',
      initial:
          widget
              .scheduleController
              .weeklySchedules[weeklyIndex]
              .schedule[dailyIndex]
              .end,
    );
    if (end == null || !mounted) return;

    final breakStart = await promptTime(
      title: 'Heure de début de pause',
      initial:
          widget
              .scheduleController
              .weeklySchedules[weeklyIndex]
              .schedule[dailyIndex]
              .breakStart ??
          _defaultBreakStart,
    );
    if (breakStart == null || !mounted) return;

    final breakEnd = await promptTime(
      title: 'Heure de fin de pause',
      initial:
          widget
              .scheduleController
              .weeklySchedules[weeklyIndex]
              .schedule[dailyIndex]
              .breakEnd ??
          _defaultBreakEnd,
    );
    if (breakEnd == null || !mounted) return;

    widget.scheduleController.updateDailyScheduleTime(
      weeklyIndex,
      dailyIndex,
      start: start,
      end: end,
      breakStart: breakStart,
      breakEnd: breakEnd,
    );
    setState(() {});
  }

  Future<Day?> _promptDay(BuildContext context) async {
    final choice = (await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sélectionner la journée'),
            content: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    Day.values
                        .map(
                          (day) => GestureDetector(
                            onTap: () => Navigator.of(context).pop(day),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(day.name),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
    ));
    return choice;
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
                () => _promptNewDayToDailySchedule(weeklyIndex),
            onUpdateDailyScheduleTime:
                (dailyIndex) =>
                    _promptUpdateToDailySchedule(weeklyIndex, dailyIndex),
            onRemovedDailyScheduleTime:
                (dailyIndex) => setState(
                  () => widget.scheduleController.removedDailyScheduleTime(
                    context,
                    weeklyIndex,
                    dailyIndex,
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
  final Function() onAddDayToDailySchedule;
  final Function(int) onUpdateDailyScheduleTime;
  final Function(int) onRemovedDailyScheduleTime;
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
                  ...weeklySchedule.schedule.asMap().keys.map(
                    (i) => TableRow(
                      children: [
                        Text(weeklySchedule.schedule[i].dayOfWeek.name),
                        Text(
                          '${weeklySchedule.schedule[i].start.format(context)} / '
                          '${weeklySchedule.schedule[i].end.format(context)}',
                        ),
                        Text(
                          '(${weeklySchedule.schedule[i].breakStart?.format(context) ?? ''} / '
                          '${weeklySchedule.schedule[i].breakEnd?.format(context) ?? ''})',
                        ),
                        if (editMode)
                          InkWell(
                            onTap: () => onUpdateDailyScheduleTime(i),
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.black,
                            ),
                          ),
                        if (editMode)
                          InkWell(
                            onTap: () => onRemovedDailyScheduleTime(i),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                  if (editMode)
                    TableRow(
                      children: [
                        Container(),
                        Container(),
                        Container(),
                        InkWell(
                          onTap: onAddDayToDailySchedule,
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                        Container(),
                      ],
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
