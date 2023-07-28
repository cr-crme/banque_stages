import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/internship_enrollment/steps/schedule_step.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
        );

  bool get hasChanged =>
      scheduleController.hasChanged || dateHasChanged || supervisorChanged;

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

  void _toggleEditMode({bool save = true}) {
    if (_editMode) {
      _editMode = false;
      if (!save) {
        setState(() {});
        return;
      }
    } else {
      _editMode = true;
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
              _internshipController.scheduleController.weeklySchedules);

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

  Future<bool> preventClosingIfEditing() async {
    if (!editMode) return false;

    final prevent = !(await ConfirmPopDialog.show(context));
    if (!prevent) _toggleEditMode(save: false);
    return prevent;
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Détails du stage',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.black)),
                if (_isExpanded && widget.internship.isActive)
                  IconButton(
                      onPressed: _toggleEditMode,
                      icon: Icon(
                        editMode ? Icons.save : Icons.edit,
                        color: Theme.of(context).primaryColor,
                      )),
              ],
            ),
            body: _InternshipBody(
              internship: widget.internship,
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
          ],
        ),
        _buildDates(),
        _buildTime(),
        _buildSchedule(),
      ],
    );
  }
}
