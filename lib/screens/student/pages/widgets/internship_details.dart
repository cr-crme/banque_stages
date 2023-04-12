import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/schedule.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/screens/internship_enrollment/steps/requirements_step.dart';
import '/screens/internship_enrollment/steps/schedule_step.dart';

class _InternshipController {
  _InternshipController(Internship internship)
      : supervisor = internship.supervisor.copyWith(),
        date = DateTimeRange(
            start: internship.date.start, end: internship.date.end),
        weeklySchedules =
            internship.weeklySchedules.map((week) => week.copyWith()).toList(),
        protections = internship.protections.map((e) => e).toList(),
        uniform = internship.uniform,
        scheduleController = WeeklyScheduleController(
          weeklySchedules:
              internship.weeklySchedules.map((e) => e.deepCopy()).toList(),
          dateRange: internship.date,
        );

  bool get hasChanged => scheduleController.hasChanged;

  Person supervisor;
  DateTimeRange date;
  List<WeeklySchedule> weeklySchedules;
  List<String> protections;
  String uniform;
  WeeklyScheduleController scheduleController;
}

class InternshipDetails extends StatefulWidget {
  const InternshipDetails({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipDetails> createState() => _InternshipDetailsState();
}

class _InternshipDetailsState extends State<InternshipDetails> {
  bool _isExpanded = true;
  bool _editMode = false;
  late var _internshipController = _InternshipController(widget.internship);

  void _onToggleSaveEdit() {
    _editMode = !_editMode;
    if (_editMode) {
      _internshipController = _InternshipController(widget.internship);
    } else {
      if (_internshipController.hasChanged) {
        widget.internship.addVersion(
            supervisor: widget.internship.supervisor,
            date: widget.internship.date,
            weeklySchedules:
                _internshipController.scheduleController.weeklySchedules,
            protections: widget.internship.protections,
            uniform: widget.internship.uniform);

        InternshipsProvider.of(context, listen: false)
            .replace(widget.internship);
      }
    }
    setState(() {});
  }

  void _promptDateRange() async {
    final range = await showDateRangePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: widget.internship.date,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (range == null) return;

    _internshipController.date = range;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ExpansionPanelList(
        elevation: 0,
        expansionCallback: (index, isExpanded) =>
            setState(() => _isExpanded = !_isExpanded),
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => Text('Détails du stage',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black)),
            body: Stack(
              alignment: Alignment.topRight,
              children: [
                _InternshipBody(
                  internship: widget.internship,
                  editMode: _editMode,
                  onRequestChangedDates: _promptDateRange,
                  scheduleController: _internshipController.scheduleController,
                ),
                IconButton(
                    onPressed: _onToggleSaveEdit,
                    icon: Icon(
                      _editMode ? Icons.save : Icons.edit,
                      color: Colors.black,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _InternshipBody extends StatelessWidget {
  const _InternshipBody({
    required this.internship,
    required this.editMode,
    required this.onRequestChangedDates,
    required this.scheduleController,
  });

  final Internship internship;
  final bool editMode;

  final Function() onRequestChangedDates;
  final WeeklyScheduleController scheduleController;

  static const TextStyle _titleStyle = TextStyle(fontWeight: FontWeight.bold);
  static const _interline = 12.0;

  Widget _buildTextSection({required String title, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Text(text),
        )
      ],
    );
  }

  Widget _buildTeacher({required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enseignant.e superviseur.e de stage', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Text(text),
        )
      ],
    );
  }

  Widget _buildJob(
    String title, {
    required String specializationId,
    required enterprises,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _titleStyle),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(enterprises[internship.enterpriseId]
                .jobs[internship.jobId]
                .specialization
                .idWithName),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(enterprises[internship.enterpriseId]
                .jobs[internship.jobId]
                .specialization
                .sector
                .idWithName),
          ),
        ],
      ),
    );
  }

  Widget _buildSupervisorInfo({required Person person}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Superviseur en milieu de stage', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nom'),
              editMode
                  ? TextFormField(initialValue: person.fullName)
                  : Text(person.fullName),
              const SizedBox(height: 8),
              const Text('Numéro de téléphone'),
              editMode
                  ? TextFormField(initialValue: person.phone.toString())
                  : Text(person.phone.toString()),
              const SizedBox(height: 8),
              const Text('Courriel'),
              editMode
                  ? TextFormField(initialValue: person.email ?? '')
                  : Text(person.email ?? 'Aucun'),
              const SizedBox(height: 8),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDates() {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date du stage', style: _titleStyle),
            Padding(
              padding: const EdgeInsets.only(bottom: _interline),
              child: Table(
                children: [
                  const TableRow(children: [
                    Text('Date de début :'),
                    Text('Date de fin :'),
                  ]),
                  TableRow(children: [
                    Text(DateFormat.yMMMEd().format(internship.date.start)),
                    Text(DateFormat.yMMMEd().format(internship.date.end)),
                  ]),
                ],
              ),
            ),
          ],
        ),
        if (editMode)
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.blue,
            ),
            onPressed: onRequestChangedDates,
          )
      ],
    );
  }

  Widget _buildTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre d\'heures de stage', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(bottom: _interline),
          child: Table(
            children: [
              TableRow(children: [
                Text('Total prévu : ${internship.expectedLength}h'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total fait : '),
                    editMode
                        ? SizedBox(
                            width: 45,
                            child: TextFormField(
                                textAlign: TextAlign.right,
                                initialValue:
                                    internship.achievedLength.toString()),
                          )
                        : Text(internship.achievedLength.toString()),
                    const Text('h'),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Horaire du stage', style: _titleStyle),
          ScheduleSelector(
            withTitle: false,
            editMode: editMode,
            scheduleController: scheduleController,
          )
        ],
      ),
    );
  }

  Widget _buildProtection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EPI requis', style: _titleStyle),
          if (editMode) _ProtectionRequiredChoser(internship: internship),
          if (!editMode && internship.protections.isEmpty) const Text('Aucun'),
          if (!editMode && internship.protections.isNotEmpty)
            ...internship.protections.map((e) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u2022 '),
                    Flexible(child: Text(e)),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildUniform() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Uniforme requis', style: _titleStyle),
          if (editMode) _UniformRequiredChoser(internship: internship),
          if (!editMode && internship.uniform.isEmpty) const Text('Aucun'),
          if (!editMode && internship.uniform.isNotEmpty)
            Text(internship.uniform),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teachers = TeachersProvider.of(context);
    final enterprises = EnterprisesProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTeacher(text: teachers[internship.teacherId].fullName),
        _buildJob(
            'Métier${internship.extraSpecializationsId.isNotEmpty ? ' principal' : ''}',
            specializationId: internship.jobId,
            enterprises: enterprises),
        if (internship.extraSpecializationsId.isNotEmpty)
          ...internship.extraSpecializationsId.asMap().keys.map(
                (indexExtra) => _buildJob(
                    'Métier secondaire${internship.extraSpecializationsId.length > 1 ? ' (${indexExtra + 1})' : ''}',
                    specializationId:
                        internship.extraSpecializationsId[indexExtra],
                    enterprises: enterprises),
              ),
        _buildTextSection(
            title: 'Entreprise',
            text: enterprises[internship.enterpriseId].name),
        _buildTextSection(
            title: 'Adresse de l\'entreprise',
            text: enterprises[internship.enterpriseId].address.toString()),
        _buildSupervisorInfo(person: internship.supervisor),
        _buildDates(),
        _buildTime(),
        _buildSchedule(),
        _buildProtection(),
        _buildUniform(),
      ],
    );
  }
}

class _ProtectionRequiredChoser extends StatefulWidget {
  const _ProtectionRequiredChoser({required this.internship});

  final Internship internship;

  @override
  State<_ProtectionRequiredChoser> createState() =>
      _ProtectionRequiredChoserState();
}

class _ProtectionRequiredChoserState extends State<_ProtectionRequiredChoser> {
  late bool _needProtections = widget.internship.protections.isNotEmpty;
  late final Map<String, bool> _protections = Map.fromIterable(
      RequirementsStep.protectionsList,
      value: (e) => widget.internship.protections.contains(e) ? true : false);
  bool _otherProtections = false;
  String? otherProtection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 125,
                child: RadioListTile(
                  value: true,
                  groupValue: _needProtections,
                  onChanged: (bool? newValue) =>
                      setState(() => _needProtections = newValue!),
                  title: const Text('Oui'),
                ),
              ),
              SizedBox(
                width: 125,
                child: RadioListTile(
                  value: false,
                  groupValue: _needProtections,
                  onChanged: (bool? newValue) =>
                      setState(() => _needProtections = newValue!),
                  title: const Text('Non'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Visibility(
            visible: _needProtections,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesquels ?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ..._protections.keys.map(
                  (requirement) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    visualDensity: VisualDensity.compact,
                    dense: true,
                    title: Text(
                      requirement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _protections[requirement],
                    onChanged: (newValue) =>
                        setState(() => _protections[requirement] = newValue!),
                  ),
                ),
                CheckboxListTile(
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  title: Text(
                    'Autre',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  value: _otherProtections,
                  onChanged: (newValue) =>
                      setState(() => _otherProtections = newValue!),
                ),
                Visibility(
                  visible: _otherProtections,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Précisez l\'équipement supplémentaire requis : ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextFormField(
                          onSaved: (text) => otherProtection = text,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _UniformRequiredChoser extends StatefulWidget {
  const _UniformRequiredChoser({required this.internship});

  final Internship internship;

  @override
  State<_UniformRequiredChoser> createState() => _UniformRequiredChoserState();
}

class _UniformRequiredChoserState extends State<_UniformRequiredChoser> {
  late bool _needUniform = widget.internship.uniform.isNotEmpty;
  String? uniform;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 125,
                child: RadioListTile(
                  value: true,
                  groupValue: _needUniform,
                  onChanged: (bool? newValue) =>
                      setState(() => _needUniform = newValue!),
                  title: const Text('Oui'),
                ),
              ),
              SizedBox(
                width: 125,
                child: RadioListTile(
                  value: false,
                  groupValue: _needUniform,
                  onChanged: (bool? newValue) =>
                      setState(() => _needUniform = newValue!),
                  title: const Text('Non'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Visibility(
            visible: _needUniform,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Précisez l\'équipement supplémentaire requis : ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextFormField(
                    initialValue: widget.internship.uniform,
                    onSaved: (text) => uniform = text,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
