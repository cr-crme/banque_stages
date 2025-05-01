import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common/models/persons/person.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/custom_date_picker.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_exit_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/screens/internship_enrollment/steps/schedule_step.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _InternshipController {
  _InternshipController(Internship internship)
      : supervisor = internship.supervisor.copyWith(),
        _dates = time_utils.DateTimeRange(
            start: internship.dates.start, end: internship.dates.end),
        _achievedLength = internship.achievedDuration,
        weeklySchedules =
            internship.weeklySchedules.map((week) => week.copyWith()).toList(),
        scheduleController = WeeklyScheduleController(
          weeklySchedules: internship.weeklySchedules
              .map((e) => e.copyWith(schedule: [...e.schedule]))
              .toList(),
          dateRange: internship.dates,
        );

  bool get hasChanged =>
      scheduleController.hasChanged || dateHasChanged || supervisorChanged;

  Person supervisor;
  bool get supervisorChanged =>
      supervisor.firstName != supervisorFirstNameController.text ||
      supervisor.lastName != supervisorLastNameController.text ||
      supervisor.phone.toString() != supervisorPhoneController.text ||
      (supervisor.email ?? '') != supervisorEmailController.text;
  final supervisorFormKey = GlobalKey<FormState>();
  late final supervisorFirstNameController =
      TextEditingController(text: supervisor.firstName);
  late final supervisorLastNameController =
      TextEditingController(text: supervisor.lastName);
  late final supervisorPhoneController =
      TextEditingController(text: supervisor.phone.toString());
  late final supervisorEmailController =
      TextEditingController(text: supervisor.email ?? '');

  time_utils.DateTimeRange _dates;
  bool dateHasChanged = false;
  time_utils.DateTimeRange get dates => _dates;
  set date(time_utils.DateTimeRange newDates) {
    _dates = newDates;
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
}

class InternshipDetails extends StatefulWidget {
  const InternshipDetails({super.key, required this.internshipId});

  final String internshipId;

  @override
  State<InternshipDetails> createState() => InternshipDetailsState();
}

class InternshipDetailsState extends State<InternshipDetails> {
  bool _isExpanded = false;
  bool _editMode = false;
  bool get editMode => _editMode;

  late Internship _internship;
  late _InternshipController _internshipController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _internship = InternshipsProvider.of(context)
        .firstWhere((e) => e.id == widget.internshipId);

    _internshipController = _InternshipController(_internship);
  }

  void _toggleEditMode({bool save = true}) {
    if (_editMode) {
      _editMode = false;
      if (!save) {
        setState(() {});
        return;
      }
    } else {
      _editMode = true;
      _internshipController = _InternshipController(_internship);
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
    bool hasChanged = false;
    if (_internshipController.achievedLengthChanged) {
      _internship = _internship.copyWith(
          achievedDuration: _internshipController._achievedLength);
      hasChanged = true;
    }

    // Saving the values that require an extra version
    if (_internshipController.hasChanged) {
      _internship.addVersion(
          creationDate: DateTime.now(),
          supervisor: _internship.supervisor.copyWith(
              firstName:
                  _internshipController.supervisorFirstNameController.text,
              lastName: _internshipController.supervisorLastNameController.text,
              phone: PhoneNumber.fromString(
                  _internshipController.supervisorPhoneController.text),
              email: _internshipController.supervisorEmailController.text),
          dates: _internshipController.dates,
          weeklySchedules: _internshipController
              .scheduleController.weeklySchedules
              .map((e) => e.duplicate())
              .toList());

      hasChanged = true;
    }

    if (hasChanged) {
      InternshipsProvider.of(context, listen: false).replace(_internship);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _promptDateRange() async {
    final range = await showCustomDateRangePicker(
      helpText: 'Sélectionner les dates',
      saveText: 'Confirmer',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDateRange: _internshipController.dates,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (range == null) return;

    _internshipController.date = range;
    setState(() {});
  }

  Future<bool> preventClosingIfEditing() async {
    final shouldQuit = await ConfirmExitDialog.show(context,
        content: Text.rich(TextSpan(children: [
          const TextSpan(
              text: '** Vous quittez la page sans avoir '
                  'cliqué sur Enregistrer '),
          WidgetSpan(
              child: SizedBox(
            height: 22,
            width: 22,
            child: Icon(
              Icons.save,
              color: Theme.of(context).primaryColor,
            ),
          )),
          const TextSpan(
            text: '. **\n\nToutes vos modifications seront perdues.',
          ),
        ])),
        isEditing: editMode);
    if (shouldQuit) _toggleEditMode(save: false);
    return !shouldQuit;
  }

  @override
  Widget build(BuildContext context) {
    final myId = TeachersProvider.of(context).currentTeacherId;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ExpansionPanelList(
        elevation: 0,
        expansionCallback: (index, isExpanded) async {
          if (_isExpanded && _editMode) {
            if (await preventClosingIfEditing()) return;
          }
          setState(() => _isExpanded = !_isExpanded);
        },
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Détails du stage',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.black)),
                if (_isExpanded &&
                    _internship.isActive &&
                    _internship.supervisingTeacherIds.contains(myId))
                  IconButton(
                      onPressed: _toggleEditMode,
                      icon: Icon(
                        editMode ? Icons.save : Icons.edit,
                        color: Theme.of(context).primaryColor,
                      )),
              ],
            ),
            body: _InternshipBody(
              internship: _internship,
              editMode: _editMode,
              onRequestChangedDates: _promptDateRange,
              internshipController: _internshipController,
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
  });

  final Internship internship;
  final bool editMode;

  final Function() onRequestChangedDates;
  final _InternshipController internshipController;

  static const TextStyle _titleStyle = TextStyle(fontWeight: FontWeight.bold);
  static const _interline = 12.0;

  Widget _buildTeachers(
      {required List<String> supervisors, required String signatoryTeacher}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Enseignant\u00b7e\u00b7s superviseur\u00b7e\u00b7s de stage\u00a0:',
            style: _titleStyle),
        ItemizedText(supervisors),
        const SizedBox(height: 12),
        const Text('Signataire du contrat de stage\u00a0:', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Text(signatoryTeacher),
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
            child: Text('Secteur ${specialization.sector.idWithName}'),
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
            const Text('Dates du stage', style: _titleStyle),
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
                        .format(internshipController.dates.start)),
                    Text(DateFormat.yMMMEd('fr_CA')
                        .format(internshipController.dates.end)),
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
                Text('Total prévu : ${internship.expectedDuration}h'),
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
                        : Text(internship.achievedDuration.toString()),
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

  @override
  Widget build(BuildContext context) {
    final teachers = TeachersProvider.of(context);
    final enterprises = EnterprisesProvider.of(context);

    late final Job job;
    try {
      job = enterprises[internship.enterpriseId].jobs[internship.jobId];
    } catch (e) {
      return SizedBox(
        height: 50,
        child: Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor)),
      );
    }

    final supervisors =
        teachers.where((e) => internship.supervisingTeacherIds.contains(e.id));
    final signatoryTeacher =
        teachers.firstWhere((e) => e.id == internship.signatoryTeacherId);

    return FocusScope(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeachers(
              supervisors: supervisors.map((e) => e.fullName).toList(),
              signatoryTeacher: signatoryTeacher.fullName),
          _buildJob(
              'Métier${internship.extraSpecializationIds.isNotEmpty ? ' principal' : ''}',
              specialization: job.specialization),
          if (internship.extraSpecializationIds.isNotEmpty)
            ...internship.extraSpecializationIds
                .asMap()
                .keys
                .map((indexExtra) => _buildJob(
                      'Métier supplémentaire${internship.extraSpecializationIds.length > 1 ? ' (${indexExtra + 1})' : ''}',
                      specialization: ActivitySectorsService.specialization(
                          internship.extraSpecializationIds[indexExtra]),
                    )),
          _buildAddress(enterprise: enterprises[internship.enterpriseId]),
          Stack(
            alignment: Alignment.topLeft,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width),
              _buildSupervisorInfo(),
            ],
          ),
          _buildDates(),
          _buildTime(),
          _buildSchedule(),
        ],
      ),
    );
  }
}
