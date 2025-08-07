import 'package:collection/collection.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common/models/internships/transportation.dart';
import 'package:common_flutter/widgets/custom_date_picker.dart';
import 'package:common_flutter/widgets/custom_time_picker.dart';
import 'package:crcrme_banque_stages/common/extensions/time_of_day_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ScheduleStep');

class WeeklySchedulesController {
  final List<bool> _useSameScheduleForAllDays = [];
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
    _useSameScheduleForAllDays.add(_useSameScheduleForAllDays.isEmpty
        ? true
        : _useSameScheduleForAllDays.last);
    _hasChanged = true;
  }

  void removedWeeklySchedule(int weeklyIndex) {
    _logger.finer('Removing weekly schedule at index: $weeklyIndex');

    weeklySchedules.removeAt(weeklyIndex);
    _useSameScheduleForAllDays.removeAt(weeklyIndex);
    _hasChanged = true;
  }

  void updateDailyScheduleTime(int weeklyIndex, Day day,
      {required DailySchedule schedule}) {
    _logger.finer(
        'Updating daily schedule (weekly index: $weeklyIndex, day: $day)');
    weeklySchedules[weeklyIndex].schedule[day] = weeklySchedules[weeklyIndex]
            .schedule[day]
            ?.copyWith(blocks: schedule.blocks) ??
        schedule;

    if (_useSameScheduleForAllDays[weeklyIndex]) {
      applySameScheduleForAllDays(weeklyIndex);
    }
    _hasChanged = true;
  }

  void removeDailyScheduleTime(int weeklyIndex, Day day) {
    _logger.finer(
        'Updating daily schedule (weekly index: $weeklyIndex, day: $day)');
    weeklySchedules[weeklyIndex].schedule.remove(day);

    if (_useSameScheduleForAllDays[weeklyIndex]) {
      applySameScheduleForAllDays(weeklyIndex);
    }
    _hasChanged = true;
  }

  void updateDailyScheduleRange(
      int weeklyIndex, time_utils.DateTimeRange newRange) {
    _logger.finer(
        'Updating date range for weekly schedule at index: $weeklyIndex');
    weeklySchedules[weeklyIndex] =
        weeklySchedules[weeklyIndex].copyWith(period: newRange);

    if (_useSameScheduleForAllDays[weeklyIndex]) {
      applySameScheduleForAllDays(weeklyIndex);
    }

    _hasChanged = true;
  }

  void switchApplyToAllDays({required bool value, required int weeklyIndex}) {
    _useSameScheduleForAllDays[weeklyIndex] = value;
    if (_useSameScheduleForAllDays[weeklyIndex]) {
      applySameScheduleForAllDays(weeklyIndex);
    }
    _hasChanged = true;
  }

  void applySameScheduleForAllDays(int weeklyIndex) {
    final schedules = weeklySchedules[weeklyIndex].schedule;
    if (schedules.isEmpty) return;

    // Reference day is the first day with a schedule
    final referenceDay =
        Day.values.firstWhereOrNull((day) => schedules[day] != null);
    if (referenceDay == null) return;

    schedules.forEach((day, schedule) {
      if (day != referenceDay) {
        schedules[day] = schedules[referenceDay]?.duplicate();
      }
    });
    _hasChanged = true;
  }

  void dispose() {}
}

final _defaultDaily = DailySchedule(
  blocks: [
    TimeBlock(
      start: time_utils.TimeOfDay(hour: 9, minute: 0),
      end: time_utils.TimeOfDay(hour: 12, minute: 0),
    ),
    TimeBlock(
      start: time_utils.TimeOfDay(hour: 13, minute: 0),
      end: time_utils.TimeOfDay(hour: 15, minute: 0),
    ),
  ],
);
var _currentDefaultDaily = _defaultDaily.duplicate();

WeeklySchedule _fillNewScheduleList({
  required Map<Day, DailySchedule?> schedule,
  required time_utils.DateTimeRange periode,
}) {
  return WeeklySchedule(schedule: {
    for (var key in schedule.keys) key: schedule[key]?.duplicate()
  }, period: periode);
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
      weeklyScheduleController.weeklySchedules.add(_fillNewScheduleList(
          schedule: weeklyScheduleController.weeklySchedules.isEmpty
              ? {}
              : weeklyScheduleController.weeklySchedules.last.schedule,
          periode: weeklyScheduleController.dateRange!));
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
                  key: ValueKey(weeklyIndex),
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
                  onAddDailyScheduleTime: (day) => setState(() {
                    widget.scheduleController.updateDailyScheduleTime(
                        weeklyIndex, day,
                        schedule: _currentDefaultDaily.duplicate());
                  }),
                  onUpdateDailyScheduleTime: (day, schedule) => setState(() {
                    widget.scheduleController.updateDailyScheduleTime(
                        weeklyIndex, day,
                        schedule: schedule);
                  }),
                  onRemovedDailyScheduleTime: (day) => setState(() {
                    widget.scheduleController
                        .removeDailyScheduleTime(weeklyIndex, day);
                  }),
                  promptChangeWeeks: () => _promptChangeWeek(weeklyIndex),
                  useSameScheduleForAllDays: widget.scheduleController
                      ._useSameScheduleForAllDays[weeklyIndex],
                  onChangedUseSameScheduleForAllDays: (value) {
                    widget.scheduleController.switchApplyToAllDays(
                        value: value, weeklyIndex: weeklyIndex);
                    setState(() {});
                  },
                  editMode: widget.editMode,
                  leftPadding: widget.leftPadding,
                )),
        if (widget.editMode)
          TextButton(
            onPressed: () => setState(() {
              widget.scheduleController.addWeeklySchedule(_fillNewScheduleList(
                  schedule: widget.scheduleController.weeklySchedules.isEmpty
                      ? {}
                      : widget.scheduleController.weeklySchedules.last.schedule,
                  periode: widget.scheduleController.dateRange!));
            }),
            style: Theme.of(context).textButtonTheme.style?.copyWith(
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
    super.key,
    required this.periodName,
    required this.periodTextSize,
    required this.weeklySchedule,
    required this.onRemoveWeeklySchedule,
    required this.onAddDailyScheduleTime,
    required this.onUpdateDailyScheduleTime,
    required this.onRemovedDailyScheduleTime,
    required this.promptChangeWeeks,
    required this.useSameScheduleForAllDays,
    required this.onChangedUseSameScheduleForAllDays,
    required this.editMode,
    this.leftPadding,
  });

  final double? leftPadding;
  final String? periodName;
  final double? periodTextSize;
  final WeeklySchedule weeklySchedule;
  final Function()? onRemoveWeeklySchedule;
  final Function(Day) onAddDailyScheduleTime;
  final Function(Day, DailySchedule) onUpdateDailyScheduleTime;
  final Function(Day) onRemovedDailyScheduleTime;
  final Function() promptChangeWeeks;
  final bool useSameScheduleForAllDays;
  final Function(bool value) onChangedUseSameScheduleForAllDays;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    int? referenceDayIndex; // Used to determine if it's the first checked day

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
      if (editMode)
        if (periodName == null)
          Text('* Sélectionner les journées et heures du stage',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold))
        else
          Text(
              '* Sélectionner les dates, journées et heures de la période de stage',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
      if (periodName != null)
        Padding(
          padding: EdgeInsets.only(
              top: 8.0,
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
                    Text('${editMode ? '* ' : ''}Date de début'),
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(weeklySchedule.period.start))
                  ]),
                  Column(children: [
                    Text('${editMode ? '* ' : ''}Date de fin'),
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
      if (editMode)
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Appliquer le même horaire\n' 'pour tous les jours du stage'),
              SizedBox(width: 8.0),
              Switch(
                  value: useSameScheduleForAllDays,
                  onChanged: onChangedUseSameScheduleForAllDays),
            ],
          ),
        ),
      FormField(validator: (value) {
        if (!editMode) return null;
        if (weeklySchedule.schedule.isEmpty) {
          return 'Veuillez sélectionner au moins un jour.';
        }
        return null;
      }, builder: (state) {
        return Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Column(
                  children: Day.values
                      .asMap()
                      .keys
                      .map(
                        (dayIndex) => Builder(builder: (context) {
                          final day = Day.values[dayIndex];

                          bool isEnabled = true;
                          if (useSameScheduleForAllDays &&
                              weeklySchedule.schedule[day] != null) {
                            if (referenceDayIndex == null) {
                              referenceDayIndex = dayIndex;
                            } else {
                              isEnabled = false;
                            }
                          }

                          return _buildDailyScheduleTile(context,
                              day: day, canChangeTime: isEnabled);
                        }),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      }),
    ]);
  }

  Future<time_utils.TimeOfDay?> _promptTime(BuildContext context,
      {required time_utils.TimeOfDay? initial, String? title}) async {
    final time = await showCustomTimePicker(
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      helpText: title,
      context: context,
      initialTime:
          TimeOfDay(hour: initial?.hour ?? 12, minute: initial?.minute ?? 0),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? Container(),
      ),
    );

    if (time == null) return null;
    return time_utils.TimeOfDay(hour: time.hour, minute: time.minute);
  }

  void _updateBlockStart(
    BuildContext context, {
    required DailySchedule schedule,
    required int blockIndex,
    required Day day,
  }) async {
    final time =
        await _promptTime(context, initial: schedule.blocks[blockIndex].start);
    if (time == null) return;
    schedule.blocks[blockIndex] =
        schedule.blocks[blockIndex].copyWith(start: time);

    // Use this update as the reference for the next updates
    _currentDefaultDaily = schedule.duplicate();
    onUpdateDailyScheduleTime(day, schedule);
  }

  void _updateBlockEnd(
    BuildContext context, {
    required DailySchedule schedule,
    required int blockIndex,
    required Day day,
  }) async {
    final time =
        await _promptTime(context, initial: schedule.blocks[blockIndex].end);
    if (time == null) return;
    schedule.blocks[blockIndex] =
        schedule.blocks[blockIndex].copyWith(end: time);

    // Use this update as the reference for the next updates
    _currentDefaultDaily = schedule.duplicate();
    onUpdateDailyScheduleTime(day, schedule);
  }

  Widget _buildDailyScheduleTile(BuildContext context,
      {required Day day, required bool canChangeTime}) {
    final schedule = weeklySchedule.schedule[day];
    final checkboxCallback = editMode
        ? () {
            if (schedule == null) {
              onAddDailyScheduleTime(day);
            } else {
              onRemovedDailyScheduleTime(day);
            }
          }
        : null;
    if (!editMode && schedule == null) {
      return SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: checkboxCallback,
          child: SizedBox(
            width: 150,
            child: Row(
              children: [
                Visibility(
                  visible: editMode,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSize: true,
                  child: Checkbox(
                    value: schedule != null,
                    onChanged: (_) {
                      if (checkboxCallback != null) {
                        checkboxCallback();
                      }
                    },
                  ),
                ),
                Text(day.name),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
            child: Column(
              children: (schedule?.blocks ?? []).asMap().keys.map((i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ClickableTextField(
                        enabled: editMode,
                        schedule!.blocks[i].start.format(context),
                        onTap: canChangeTime
                            ? () => _updateBlockStart(context,
                                schedule: schedule, blockIndex: i, day: day)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('à'),
                      ),
                      _ClickableTextField(
                        enabled: editMode,
                        schedule.blocks[i].end.format(context),
                        onTap: canChangeTime
                            ? () => _updateBlockEnd(context,
                                schedule: schedule, blockIndex: i, day: day)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: editMode
                            ? (i == 0
                                ? Visibility(
                                    visible: schedule.blocks.length == 1,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    maintainSize: true,
                                    child: _TimeBlockIconButton(
                                        onTap: canChangeTime
                                            ? () {
                                                schedule.blocks.add(
                                                    _currentDefaultDaily
                                                                .blocks.length >
                                                            1
                                                        ? _currentDefaultDaily
                                                            .blocks[1]
                                                        : _defaultDaily
                                                            .blocks[1]);
                                                _currentDefaultDaily =
                                                    schedule.duplicate();
                                                onUpdateDailyScheduleTime(
                                                    day, schedule);
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.add,
                                          color: canChangeTime
                                              ? Colors.green
                                              : Colors.grey,
                                        )),
                                  )
                                : _TimeBlockIconButton(
                                    onTap: canChangeTime
                                        ? () {
                                            schedule.blocks.removeAt(i);
                                            _currentDefaultDaily =
                                                schedule.duplicate();
                                            onUpdateDailyScheduleTime(
                                                day, schedule);
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.remove,
                                      color: canChangeTime
                                          ? Colors.red
                                          : Colors.grey,
                                    )))
                            : Container(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Container(),
      ],
    );
  }
}

class _TimeBlockIconButton extends StatelessWidget {
  const _TimeBlockIconButton({
    required this.onTap,
    required this.icon,
  });

  final Function()? onTap;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: InkWell(
        borderRadius: BorderRadius.circular(25.0),
        hoverColor: icon.color?.withAlpha(10),
        splashColor: icon.color?.withAlpha(30),
        onTap: onTap,
        child: icon,
      ),
    );
  }
}

class _ClickableTextField extends StatelessWidget {
  const _ClickableTextField(this.text,
      {required this.onTap, required this.enabled});

  final String text;
  final bool enabled;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? InkWell(
            onTap: onTap,
            child: Ink(
              width: 66,
              height: 28,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(4.0),
                  color: onTap == null ? Colors.grey[200] : Colors.white),
              child: Center(
                child: Text(text),
              ),
            ),
          )
        : SizedBox(
            width: 50,
            child: Center(child: Text(text)),
          );
  }
}
