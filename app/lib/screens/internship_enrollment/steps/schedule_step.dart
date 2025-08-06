import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common/models/internships/transportation.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/widgets/checkbox_with_other.dart';
import 'package:common_flutter/widgets/custom_date_picker.dart';
import 'package:crcrme_banque_stages/common/extensions/time_of_day_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ScheduleStep');

class WeeklySchedulesController {
  List<WeeklySchedule> weeklySchedules = [];
  time_utils.DateTimeRange? _dateRange;
  time_utils.DateTimeRange? get dateRange => _dateRange;
  bool _hasChanged = false;

  WeeklySchedulesController({
    List<WeeklySchedule>? weeklySchedules,
    time_utils.DateTimeRange? dateRange,
  })  : _dateRange = dateRange?.copy(),
        weeklySchedules =
            InternshipHelpers.copySchedules(weeklySchedules, keepId: true);

  bool get hasChanged => _hasChanged;
  set dateRange(time_utils.DateTimeRange? newRange) {
    _dateRange = newRange;
    if (weeklySchedules.length == 1) {
      weeklySchedules[0] = weeklySchedules[0].copyWith(period: newRange);
    }
    _hasChanged = true;
  }

  void addWeeklySchedule(WeeklySchedule newSchedule) {
    _logger.finer('Adding new weekly schedule: ${newSchedule.id}');

    weeklySchedules.add(newSchedule);
    _hasChanged = true;
  }

  void removedWeeklySchedule(int weeklyIndex) {
    _logger.finer('Removing weekly schedule at index: $weeklyIndex');

    weeklySchedules.removeAt(weeklyIndex);
    _hasChanged = true;
  }

  void updateDailyScheduleTime(
    int weeklyIndex,
    Day day, {
    required DailySchedule? schedule,
  }) {
    _logger.finer(
        'Updating daily schedule (weekly index: $weeklyIndex, day: $day)');

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
      int weeklyIndex, time_utils.DateTimeRange newRange) {
    _logger.finer(
        'Updating date range for weekly schedule at index: $weeklyIndex');
    weeklySchedules[weeklyIndex] =
        weeklySchedules[weeklyIndex].copyWith(period: newRange);
    _hasChanged = true;
  }

  void dispose() {}
}

const time_utils.TimeOfDay _defaultStart =
    time_utils.TimeOfDay(hour: 9, minute: 0);
const time_utils.TimeOfDay _defaultEnd =
    time_utils.TimeOfDay(hour: 15, minute: 0);
const time_utils.TimeOfDay _defaultBreakStart =
    time_utils.TimeOfDay(hour: 12, minute: 0);
const time_utils.TimeOfDay _defaultBreakEnd =
    time_utils.TimeOfDay(hour: 13, minute: 0);

WeeklySchedule _fillNewScheduleList(time_utils.DateTimeRange dateRange) {
  return WeeklySchedule(schedule: {}, period: dateRange);
}

class ScheduleStep extends StatefulWidget {
  const ScheduleStep({super.key});

  @override
  State<ScheduleStep> createState() => ScheduleStepState();
}

class ScheduleStepState extends State<ScheduleStep> {
  final formKey = GlobalKey<FormState>();

  late final weeklyScheduleController = WeeklySchedulesController();
  List<Transportation> transportations = [];
  int internshipDuration = 0;
  String visitFrequencies = '';

  void onScheduleChanged() {
    if (weeklyScheduleController.dateRange != null &&
        weeklyScheduleController.weeklySchedules.isEmpty) {
      weeklyScheduleController.weeklySchedules
          .add(_fillNewScheduleList(weeklyScheduleController.dateRange!));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building ScheduleStep widget');

    return FocusScope(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRange(
              scheduleController: weeklyScheduleController,
              onScheduleChanged: onScheduleChanged,
            ),
            Visibility(
                visible: weeklyScheduleController.dateRange != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScheduleSelector(
                      scheduleController: weeklyScheduleController,
                      editMode: true,
                      withTitle: true,
                    ),
                    _Hours(
                        onSaved: (value) =>
                            internshipDuration = int.parse(value!)),
                    _Transportations(
                      withTitle: true,
                      transportations: transportations,
                    ),
                    _VisitFrequencies(
                        onSaved: (value) => visitFrequencies = value!)
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

  final WeeklySchedulesController scheduleController;
  final Function() onScheduleChanged;

  @override
  State<_DateRange> createState() => _DateRangeState();
}

class _DateRangeState extends State<_DateRange> {
  bool _isValid = true;

  Future<void> _promptDateRange(context) async {
    final range = await showCustomDateRangePicker(
      helpText: 'Sélectionner les dates',
      saveText: 'Confirmer',
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
    widget.scheduleController.dateRange = range;

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

class _VisitFrequencies extends StatelessWidget {
  const _VisitFrequencies({required this.onSaved});

  final void Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Visites de l\'entreprise', left: 0, bottom: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: TextFormField(
            decoration: const InputDecoration(
                labelText: '* Fréquence des visites de l\'enseignant\u00b7e'),
            keyboardType: TextInputType.number,
            onSaved: onSaved,
          ),
        ),
      ],
    );
  }
}

class _Transportations extends StatefulWidget {
  const _Transportations({
    required this.withTitle,
    required this.transportations,
  });

  final bool withTitle;
  final List<Transportation> transportations;

  @override
  State<_Transportations> createState() => _TransportationsState();
}

class _TransportationsState extends State<_Transportations> {
  void _updateTransportations(Transportation transportation) {
    if (!widget.transportations.contains(transportation)) {
      widget.transportations.add(transportation);
    } else {
      widget.transportations.remove(transportation);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.withTitle)
          const SubTitle('Transport vers l\'entreprise', left: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Transportation.values.map((e) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _updateTransportations(e),
                child: Row(
                  children: [
                    Text(e.toString()),
                    Checkbox(
                      value: widget.transportations.contains(e),
                      side: WidgetStateBorderSide.resolveWith(
                        (states) => BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2.0,
                        ),
                      ),
                      fillColor: WidgetStatePropertyAll(Colors.transparent),
                      checkColor: Colors.black,
                      onChanged: (value) => _updateTransportations(e),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
  void _updateDailySchedule(int weeklyIndex, Day day,
      {required DailySchedule? schedule}) async {
    widget.scheduleController
        .updateDailyScheduleTime(weeklyIndex, day, schedule: schedule);
    setState(() {});
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
        if (widget.withTitle) const SubTitle('Horaire du stage', left: 0),
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
                  onAddDailyScheduleTime: (day) => _updateDailySchedule(
                      weeklyIndex, day,
                      schedule: DailySchedule(
                          start: _defaultStart,
                          end: _defaultEnd,
                          breakStart: _defaultBreakStart,
                          breakEnd: _defaultBreakEnd)),
                  onUpdateDailyScheduleTime: (day) => _updateDailySchedule(
                      weeklyIndex, day,
                      schedule: DailySchedule(
                          start: _defaultStart,
                          end: _defaultEnd,
                          breakStart: _defaultBreakStart,
                          breakEnd: _defaultBreakEnd)),
                  onRemovedDailyScheduleTime: (day) =>
                      _updateDailySchedule(weeklyIndex, day, schedule: null),
                  promptChangeWeeks: () => _promptChangeWeek(weeklyIndex),
                  editMode: widget.editMode,
                  leftPadding: widget.leftPadding,
                )),
        if (widget.editMode)
          TextButton(
            onPressed: () => setState(() => widget.scheduleController
                .addWeeklySchedule(_fillNewScheduleList(
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
    required this.onAddDailyScheduleTime,
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
  final Function(Day) onAddDailyScheduleTime;
  final Function(Day) onUpdateDailyScheduleTime;
  final Function(Day) onRemovedDailyScheduleTime;
  final Function() promptChangeWeeks;
  final bool editMode;

  Widget _daySelectorFormField(BuildContext context) {
    return FormField(
      validator: (value) {
        if (!editMode) return null;
        if (weeklySchedule.schedule.isEmpty) {
          return 'Veuillez sélectionner au moins un jour.';
        }
        return null;
      },
      builder: (state) {
        return editMode
            ? Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '* Sélectionner les journées de stage',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    CheckboxWithOther<Day>(
                      enabled: editMode,
                      elements: [...Day.values],
                      onOptionSelected: (values) {
                        for (final dayName in values) {
                          final day = Day.fromName(dayName);
                          if (weeklySchedule.schedule[day] == null) {
                            onAddDailyScheduleTime(day);
                          }
                        }

                        for (final day in weeklySchedule.schedule.keys) {
                          if (!values.contains(day.name)) {
                            onRemovedDailyScheduleTime(day);
                          }
                        }
                      },
                      showOtherOption: false,
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.red),
                      ),
                  ],
                ),
              )
            : SizedBox.shrink();
      },
    );
  }

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
                        .format(weeklySchedule.period.start))
                  ]),
                  Column(children: [
                    const Text('* Date de fin'),
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(weeklySchedule.period.end))
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
      _daySelectorFormField(context),
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editMode)
              const Text(
                  '* Modifier les jours et les horaires de stage (pause)'),
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
                          '${weeklySchedule.schedule[day]?.end.format(context)}'),
                      Text(
                          '(${weeklySchedule.schedule[day]?.breakStart?.format(context) ?? ''} / '
                          '${weeklySchedule.schedule[day]?.breakEnd?.format(context) ?? ''})'),
                      if (editMode)
                        InkWell(
                          onTap: () => onUpdateDailyScheduleTime(day),
                          child: const Icon(Icons.access_time,
                              color: Colors.black),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
