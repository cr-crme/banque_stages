import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/phone_number.dart';
import '/common/models/protections.dart';
import '/common/models/schedule.dart';
import '/common/models/uniform.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/misc/job_data_file_service.dart';
import '/screens/internship_enrollment/steps/requirements_step.dart';
import '/screens/internship_enrollment/steps/schedule_step.dart';

class _InternshipController {
  _InternshipController(Internship internship)
      : supervisor = internship.supervisor.copyWith(),
        _date = DateTimeRange(
            start: internship.date.start, end: internship.date.end),
        _achievedLength = internship.achievedLength,
        weeklySchedules =
            internship.weeklySchedules.map((week) => week.copyWith()).toList(),
        scheduleController = WeeklyScheduleController(
          weeklySchedules:
              internship.weeklySchedules.map((e) => e.deepCopy()).toList(),
          dateRange: internship.date,
        ),
        initialProtectionsStatus = internship.protections.status,
        initialProtections =
            internship.protections.protections.map((e) => e).toList(),
        initialUniformStatus = internship.uniform.status,
        initialUniform = internship.uniform.uniform;

  bool get hasChanged =>
      scheduleController.hasChanged ||
      dateHasChanged ||
      supervisorChanged ||
      protectionsHasChanged ||
      _uniformHasChanged;

  Person supervisor;
  bool get supervisorChanged =>
      supervisor.firstName != supervisorFirstNameController.text ||
      supervisor.lastName != supervisorLastNameController.text ||
      supervisor.phone.toString() != supervisorPhoneController.text ||
      supervisor.email != supervisorEmailController.text;
  final supervisorFormKey = GlobalKey<FormState>();
  late final supervisorFirstNameController =
      TextEditingController(text: supervisor.firstName);
  late final supervisorLastNameController =
      TextEditingController(text: supervisor.lastName);
  late final supervisorPhoneController =
      TextEditingController(text: supervisor.phone.toString());
  late final supervisorEmailController =
      TextEditingController(text: supervisor.email ?? '');

  DateTimeRange _date;
  bool dateHasChanged = false;
  DateTimeRange get date => _date;
  set date(DateTimeRange newDate) {
    _date = newDate;
    dateHasChanged = true;
  }

  bool achievedLengthChanged = false;
  int _achievedLength;
  int get achievedLength => _achievedLength;
  set achievedLength(int newLength) {
    _achievedLength = newLength;
    achievedLengthChanged = true;
  }

  List<WeeklySchedule> weeklySchedules;
  WeeklyScheduleController scheduleController;

  bool _protectionsHasChanged = false;
  bool get protectionsHasChanged =>
      _protectionsHasChanged ||
      initialOtherProtections != otherProtectionController.text;
  late ProtectionsStatus _protectionsStatus = initialProtectionsStatus;
  ProtectionsStatus get protectionsStatus => _protectionsStatus;
  set protectionsStatus(value) {
    _protectionsStatus = value;
    _protectionsHasChanged = true;
  }

  ProtectionsStatus initialProtectionsStatus;
  List<String> initialProtections;
  Protections get protections {
    final List<String> out = [];
    if (protectionsStatus == ProtectionsStatus.none) {
      return Protections(status: ProtectionsStatus.none, protections: []);
    }

    for (final protection in hasProtections.keys) {
      if (hasProtections[protection]!) {
        out.add(protection);
      }
    }

    if (otherProtectionController.text.isNotEmpty) {
      out.add(otherProtectionController.text);
    }
    return Protections(status: protectionsStatus, protections: out);
  }

  late final Map<String, bool> hasProtections = Map.fromIterable(
      RequirementsStep.protectionsList,
      value: (e) => initialProtections.contains(e) ? true : false);
  void setHasProtections(key, value) {
    hasProtections[key] = value;
    _protectionsHasChanged = true;
  }

  late final String initialOtherProtections = initialProtections.firstWhere(
      (e) => !RequirementsStep.protectionsList.contains(e),
      orElse: () => '');
  late final otherProtectionController =
      TextEditingController(text: initialOtherProtections);
  late bool _hasOtherProtections = initialOtherProtections.isNotEmpty;
  bool get hasOtherProtections => _hasOtherProtections;
  set hasOtherProtections(value) {
    _hasOtherProtections = value;
    _protectionsHasChanged = true;
    if (!_hasOtherProtections) otherProtectionController.text = '';
  }

  bool _uniformHasChanged = false;
  final UniformStatus initialUniformStatus;
  final String initialUniform;
  late final uniformController = TextEditingController(text: initialUniform);
  Uniform get uniform =>
      Uniform(status: uniformStatus, uniform: uniformController.text);
  late UniformStatus _uniformStatus = initialUniformStatus;
  UniformStatus get uniformStatus => _uniformStatus;
  set uniformStatus(value) {
    _uniformStatus = value;
    _uniformHasChanged = true;
    if (_uniformStatus == UniformStatus.none) uniformController.text = '';
  }
}

class InternshipDetails extends StatefulWidget {
  const InternshipDetails({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipDetails> createState() => InternshipDetailsState();
}

class InternshipDetailsState extends State<InternshipDetails> {
  bool _isExpanded = false;
  bool _editMode = false;
  bool get editMode => _editMode;
  late var _internshipController = _InternshipController(widget.internship);

  void _onToggleSaveEdit() {
    _editMode = !_editMode;
    if (_editMode) {
      _internshipController = _InternshipController(widget.internship);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
      return;
    }

    // Validate before starting to save
    if (_internshipController.supervisorChanged) {
      if (!_internshipController.supervisorFormKey.currentState!.validate()) {
        // Prevent from exiting the edit mode if the field can't be validated
        _editMode = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remplir tous les champs avec un *.'),
          ),
        );
        return;
      }
    }

    // Saving the values that do not require an extra version
    if (_internshipController.achievedLengthChanged) {
      InternshipsProvider.of(context, listen: false).replace(widget.internship
          .copyWith(achievedLength: _internshipController._achievedLength));
    }

    // Saving the values that require an extra version
    if (_internshipController.hasChanged) {
      widget.internship.addVersion(
          versionDate: DateTime.now(),
          supervisor: widget.internship.supervisor.copyWith(
              firstName:
                  _internshipController.supervisorFirstNameController.text,
              lastName: _internshipController.supervisorLastNameController.text,
              phone: PhoneNumber.fromString(
                  _internshipController.supervisorPhoneController.text),
              email: _internshipController.supervisorEmailController.text),
          date: _internshipController.date,
          weeklySchedules:
              _internshipController.scheduleController.weeklySchedules,
          protections: _internshipController.protections,
          uniform: _internshipController.uniform);

      InternshipsProvider.of(context, listen: false).replace(widget.internship);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _promptDateRange() async {
    final range = await showDateRangePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: _internshipController.date,
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
            body: _InternshipBody(
              internship: widget.internship,
              editMode: _editMode,
              onRequestChangedDates: _promptDateRange,
              internshipController: _internshipController,
              onToggleSaveEdit: _onToggleSaveEdit,
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
    required this.internshipController,
    required this.onToggleSaveEdit,
  });

  final Internship internship;
  final bool editMode;

  final Function() onRequestChangedDates;
  final Function() onToggleSaveEdit;
  final _InternshipController internshipController;

  static const TextStyle _titleStyle = TextStyle(fontWeight: FontWeight.bold);
  static const _interline = 12.0;

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
    required Specialization specialization,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _titleStyle),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(specialization.idWithName),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(specialization.sector.idWithName),
          ),
        ],
      ),
    );
  }

  Widget _buildAddress({required Enterprise enterprise}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adresse de l\'entreprise', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Text(enterprise.address.toString()),
        )
      ],
    );
  }

  Widget _buildSupervisorInfo() {
    return Form(
      key: internshipController.supervisorFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Responsable en milieu de stage', style: _titleStyle),
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: _interline),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!editMode) const Text('Nom'),
                editMode
                    ? Column(
                        children: [
                          TextFormField(
                            controller: internshipController
                                .supervisorFirstNameController,
                            decoration:
                                const InputDecoration(label: Text('* Prénom')),
                            validator: (value) =>
                                value!.isEmpty ? 'Ajouter un prénom' : null,
                          ),
                          TextFormField(
                            controller: internshipController
                                .supervisorLastNameController,
                            decoration:
                                const InputDecoration(label: Text('* Nom')),
                            validator: (value) =>
                                value!.isEmpty ? 'Ajouter un nom' : null,
                          ),
                        ],
                      )
                    : Text(internship.supervisor.fullName),
                const SizedBox(height: 8),
                const Text('Numéro de téléphone'),
                editMode
                    ? TextFormField(
                        controller:
                            internshipController.supervisorPhoneController,
                        keyboardType: TextInputType.phone,
                      )
                    : Text(internship.supervisor.phone.toString()),
                const SizedBox(height: 8),
                const Text('Courriel'),
                editMode
                    ? TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller:
                            internshipController.supervisorEmailController,
                      )
                    : Text(internship.supervisor.email ?? 'Aucun'),
                const SizedBox(height: 8),
              ],
            ),
          )
        ],
      ),
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
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(internshipController.date.start)),
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(internshipController.date.end)),
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
                              initialValue: internshipController.achievedLength
                                  .toString(),
                              onChanged: (newValue) =>
                                  internshipController.achievedLength =
                                      newValue == '' ? 0 : int.parse(newValue),
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                            ),
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
            scheduleController: internshipController.scheduleController,
            leftPadding: 0,
            periodTextSize: 14,
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
          if (editMode)
            _ProtectionRequiredChoser(
                internshipController: internshipController),
          if (!editMode && internship.protections.protections.isEmpty)
            const Text('Aucun'),
          if (!editMode && internship.protections.protections.isNotEmpty)
            ...internship.protections.protections.map((e) => Row(
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
          if (editMode)
            _UniformRequiredChooser(internshipController: internshipController),
          if (!editMode && internship.uniform.status == UniformStatus.none)
            const Text('Aucun'),
          if (!editMode && internship.uniform.status != UniformStatus.none)
            Text(internship.uniform.uniform),
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
            specialization: enterprises[internship.enterpriseId]
                .jobs[internship.jobId]
                .specialization),
        if (internship.extraSpecializationsId.isNotEmpty)
          ...internship.extraSpecializationsId
              .asMap()
              .keys
              .map((indexExtra) => _buildJob(
                    'Métier supplémentaire${internship.extraSpecializationsId.length > 1 ? ' (${indexExtra + 1})' : ''}',
                    specialization: ActivitySectorsService.specialization(
                        internship.extraSpecializationsId[indexExtra]),
                  )),
        _buildAddress(enterprise: enterprises[internship.enterpriseId]),
        Stack(
          alignment: Alignment.topLeft,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width),
            _buildSupervisorInfo(),
            if (internship.isActive)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: onToggleSaveEdit,
                    icon: Icon(
                      editMode ? Icons.save : Icons.edit,
                      color: Colors.black,
                    )),
              ),
          ],
        ),
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
  const _ProtectionRequiredChoser({required this.internshipController});

  final _InternshipController internshipController;

  @override
  State<_ProtectionRequiredChoser> createState() =>
      _ProtectionRequiredChoserState();
}

class _ProtectionRequiredChoserState extends State<_ProtectionRequiredChoser> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioListTile<ProtectionsStatus>(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: ProtectionsStatus.suppliedByEnterprise,
                groupValue: widget.internshipController.protectionsStatus,
                onChanged: (newValue) => setState(() =>
                    widget.internshipController.protectionsStatus = newValue!),
                title: Text(ProtectionsStatus.suppliedByEnterprise.name),
              ),
              RadioListTile<ProtectionsStatus>(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: ProtectionsStatus.suppliedBySchool,
                groupValue: widget.internshipController.protectionsStatus,
                onChanged: (newValue) => setState(() =>
                    widget.internshipController.protectionsStatus = newValue!),
                title: Text(ProtectionsStatus.suppliedBySchool.name),
              ),
              RadioListTile<ProtectionsStatus>(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: ProtectionsStatus.none,
                groupValue: widget.internshipController.protectionsStatus,
                onChanged: (newValue) => setState(() =>
                    widget.internshipController.protectionsStatus = newValue!),
                title: Text(ProtectionsStatus.none.name),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Visibility(
            visible: widget.internshipController.protectionsStatus !=
                ProtectionsStatus.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lesquels ?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ...widget.internshipController.hasProtections.keys.map(
                  (requirement) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    visualDensity: VisualDensity.compact,
                    dense: true,
                    title: Text(
                      requirement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value:
                        widget.internshipController.hasProtections[requirement],
                    onChanged: (newValue) => setState(() => widget
                        .internshipController
                        .setHasProtections(requirement, newValue!)),
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
                  value: widget.internshipController.hasOtherProtections,
                  onChanged: (newValue) => setState(() => widget
                      .internshipController.hasOtherProtections = newValue!),
                ),
                Visibility(
                  visible: widget.internshipController.hasOtherProtections,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Préciser l\'équipement supplémentaire requis : ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextFormField(
                          controller: widget
                              .internshipController.otherProtectionController,
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

class _UniformRequiredChooser extends StatefulWidget {
  const _UniformRequiredChooser({required this.internshipController});

  final _InternshipController internshipController;

  @override
  State<_UniformRequiredChooser> createState() =>
      _UniformRequiredChooserState();
}

class _UniformRequiredChooserState extends State<_UniformRequiredChooser> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            children: [
              RadioListTile<UniformStatus>(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: UniformStatus.suppliedByEnterprise,
                groupValue: widget.internshipController.uniformStatus,
                onChanged: (newValue) => setState(() =>
                    widget.internshipController.uniformStatus = newValue!),
                title: Text(UniformStatus.suppliedByEnterprise.name),
              ),
              RadioListTile<UniformStatus>(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: UniformStatus.suppliedByStudent,
                groupValue: widget.internshipController.uniformStatus,
                onChanged: (newValue) => setState(() =>
                    widget.internshipController.uniformStatus = newValue!),
                title: Text(UniformStatus.suppliedByStudent.name),
              ),
              RadioListTile<UniformStatus>(
                dense: true,
                visualDensity: VisualDensity.compact,
                value: UniformStatus.none,
                groupValue: widget.internshipController.uniformStatus,
                onChanged: (newValue) => setState(() =>
                    widget.internshipController.uniformStatus = newValue!),
                title: Text(UniformStatus.none.name),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Visibility(
            visible:
                widget.internshipController.uniformStatus != UniformStatus.none,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Préciser le type d\'uniforme : ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextFormField(
                    controller: widget.internshipController.uniformController,
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
