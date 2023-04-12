import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/schedule.dart';
import '/common/models/student.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/sub_title.dart';
import '/screens/internship_enrollment/steps/schedule_step.dart';

class _MutableInternshipElements {
  _MutableInternshipElements(Internship internship)
      : supervisor = internship.supervisor.copyWith(),
        date = DateTimeRange(
            start: internship.date.start, end: internship.date.end),
        weeklySchedules =
            internship.weeklySchedules.map((week) => week.copyWith()).toList(),
        protections = internship.protections.map((e) => e).toList(),
        uniform = internship.uniform;

  Person supervisor;
  DateTimeRange date;
  List<WeeklySchedule> weeklySchedules;
  List<String> protections;
  String uniform;
}

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  final Map<String, bool> _expanded = {};

  void _prepareExpander(List<Internship> internships) {
    if (_expanded.length != internships.length) {
      for (final internship in internships) {
        _expanded[internship.id] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allInternships = InternshipsProvider.of(context);
    final internships = allInternships.byStudentId(widget.student.id);
    _prepareExpander(internships);

    return ListView.builder(
      itemCount: internships.length,
      itemBuilder: (context, index) {
        final internship = internships[index];
        return ExpansionPanelList(
          expansionCallback: (int panelIndex, bool isExpanded) =>
              setState(() => _expanded[internship.id] = !isExpanded),
          children: [
            ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: _expanded[internship.id]!,
              headerBuilder: (context, isExpanded) => ListTile(
                title: SubTitle(
                  'Année ${internship.date.start.year}-${internship.date.end.year}',
                  top: 0,
                  left: 0,
                  bottom: 0,
                ),
              ),
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InternshipDetails(internship: internship),
                  ]),
            ),
          ],
        );
      },
    );
  }
}

class _InternshipDetails extends StatefulWidget {
  const _InternshipDetails({required this.internship});

  final Internship internship;

  @override
  State<_InternshipDetails> createState() => _InternshipDetailsState();
}

class _InternshipDetailsState extends State<_InternshipDetails> {
  bool _isExpanded = true;
  bool _editMode = false;
  _MutableInternshipElements? _currentInternshipModification;

  void _onToggleSaveEdit() {
    _editMode = !_editMode;
    _currentInternshipModification =
        _MutableInternshipElements(widget.internship);
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

    _currentInternshipModification!.date = range;
  }

  void _onUpdatedTime(int indexWeek, int indexDay) async {
    final start = await _promptTime(
        title: 'Heure de début',
        initial: _currentInternshipModification!
            .weeklySchedules[indexWeek].schedule[indexDay].start);
    if (start == null) return;
    final end = await _promptTime(
        title: 'Heure de fin',
        initial: _currentInternshipModification!
            .weeklySchedules[indexWeek].schedule[indexDay].end);
    if (end == null) return;

    _currentInternshipModification!
            .weeklySchedules[indexWeek].schedule[indexDay] =
        _currentInternshipModification!
            .weeklySchedules[indexWeek].schedule[indexDay]
            .copyWith(start: start, end: end);
    setState(() {});
  }

  void _onRemovedTime(int indexWeek, int indexDay) async {
    _currentInternshipModification!.weeklySchedules[indexWeek].schedule
        .removeAt(indexDay);
    setState(() {});
  }

  Future<TimeOfDay?> _promptTime(
      {required TimeOfDay initial, String? title}) async {
    final time = await showTimePicker(
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
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
                  onUpdateDayScheduleTime: _onUpdatedTime,
                  onDeleteDayScheduleTime: _onRemovedTime,
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
    required this.onUpdateDayScheduleTime,
    required this.onDeleteDayScheduleTime,
  });

  final Internship internship;
  final bool editMode;

  final Function() onRequestChangedDates;
  final Function(int indexWeek, int indexDay) onUpdateDayScheduleTime;
  final Function(int indexWeek, int indexDay) onDeleteDayScheduleTime;

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
            scheduleController: WeeklyScheduleController(
              weeklySchedules:
                  internship.weeklySchedules.map((e) => e.deepCopy()).toList(),
              dateRange: internship.date,
            ),
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
          if (internship.protections.isEmpty) const Text('Aucun'),
          if (internship.protections.isNotEmpty)
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
          Text(internship.uniform == '' ? 'Aucun' : internship.uniform),
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
            'Métier${internship.extraSpecializationId.isNotEmpty ? ' principal' : ''}',
            specializationId: internship.jobId,
            enterprises: enterprises),
        if (internship.extraSpecializationId.isNotEmpty)
          ...internship.extraSpecializationId.asMap().keys.map(
                (indexExtra) => _buildJob(
                    'Métier secondaire${internship.extraSpecializationId.length > 1 ? ' (${indexExtra + 1})' : ''}',
                    specializationId:
                        internship.extraSpecializationId[indexExtra],
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
