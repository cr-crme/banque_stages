import 'package:common/models/internships/transportation.dart';
import 'package:common_flutter/widgets/custom_date_picker.dart';
import 'package:common_flutter/widgets/schedule_selector.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ScheduleStep');

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
      weeklyScheduleController.weeklySchedules.add(
          WeeklySchedulesController.fillNewScheduleList(
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
                      title: const SubTitle('Horaire du stage', left: 0),
                      scheduleController: weeklyScheduleController,
                      editMode: true,
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
