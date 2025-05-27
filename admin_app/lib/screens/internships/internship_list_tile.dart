import 'package:admin_app/providers/enterprises_provider.dart';
import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/internships/confirm_delete_internship_dialog.dart';
import 'package:admin_app/screens/internships/schedule_list_tile.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:admin_app/widgets/custom_date_picker.dart';
import 'package:admin_app/widgets/email_list_tile.dart';
import 'package:admin_app/widgets/phone_list_tile.dart';
import 'package:admin_app/widgets/teacher_picker_tile.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InternshipListTile extends StatefulWidget {
  const InternshipListTile({
    super.key,
    required this.internship,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final Internship internship;
  final bool isExpandable;
  final bool forceEditingMode;

  @override
  State<InternshipListTile> createState() => InternshipListTileState();
}

class InternshipListTileState extends State<InternshipListTile> {
  final _formKey = GlobalKey<FormState>();
  Future<bool> validate() async {
    // We do both like so, so all the fields get validated even if one is not valid
    bool isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  @override
  void dispose() {
    _teacherNotesController.dispose();
    _contactFirstNameController.dispose();
    _contactLastNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _expectedDurationController.dispose();
    _achievedDurationController.dispose();
    _schedulesController.dispose();
    super.dispose();
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  late final _teacherPickerController = TeacherPickerController(
    initial: TeachersProvider.of(context, listen: true).firstWhereOrNull(
      (teacher) => teacher.id == widget.internship.signatoryTeacherId,
    ),
  );
  late final _contactFirstNameController = TextEditingController(
    text: widget.internship.supervisor.firstName,
  );
  late final _contactLastNameController = TextEditingController(
    text: widget.internship.supervisor.lastName,
  );
  late final _contactPhoneController = TextEditingController(
    text: widget.internship.supervisor.phone?.toString(),
  );
  late final _contactEmailController = TextEditingController(
    text: widget.internship.supervisor.email,
  );
  late final _schedulesController = SchedulesController(
    dateRange: widget.internship.dates,
    weeklySchedules: widget.internship.weeklySchedules,
  );
  late final _expectedDurationController = TextEditingController(
    text: widget.internship.expectedDuration.toString(),
  );
  late DateTime? _endDate = widget.internship.endDate;
  bool get _hasEndDate => _endDate != null && _endDate!.year > 0;
  late final _achievedDurationController = TextEditingController(
    text:
        widget.internship.achievedDuration > 0
            ? widget.internship.achievedDuration.toString()
            : '',
  );
  late final _teacherNotesController = TextEditingController(
    text: widget.internship.teacherNotes,
  );

  Internship get editedInternship {
    var internship = widget.internship.copyWith(
      signatoryTeacherId: _teacherPickerController.teacher.id,
      teacherNotes: _teacherNotesController.text,
      expectedDuration: int.tryParse(_expectedDurationController.text) ?? 0,
      achievedDuration: int.tryParse(_achievedDurationController.text) ?? -1,
      endDate: _endDate,
    );

    final schedulesHasChanged =
        !InternshipHelpers.areSchedulesEqual(
          widget.internship.weeklySchedules,
          _schedulesController.weeklySchedules,
        ) ||
        widget.internship.dates != _schedulesController.dateRange;
    final supervisor = internship.supervisor.copyWith(
      firstName: _contactFirstNameController.text,
      lastName: _contactLastNameController.text,
      phone: PhoneNumber.fromString(
        _contactPhoneController.text,
        id: internship.supervisor.phone?.id,
      ),
      email: _contactEmailController.text,
    );

    if (schedulesHasChanged ||
        internship.supervisor.getDifference(supervisor).isNotEmpty) {
      // If a mutable has changed, we cannot edit it from here. We have to
      // create a deep copy of the internship and modify this new instance.
      // The easiest way to do this is to serialize, modify and then deserialize.
      final serialized = internship.serialize();
      final newVersion = InternshipMutableElements(
        creationDate: DateTime.now(),
        supervisor: supervisor,
        dates: _schedulesController.dateRange!,
        weeklySchedules: InternshipHelpers.copySchedules(
          _schedulesController.weeklySchedules,
          keepId: false,
        ),
      );
      (serialized['mutables'] as List).add(newVersion.serialize());
      internship = Internship.fromSerialized(serialized);
    }

    return internship;
  }

  @override
  void initState() {
    super.initState();
    if (widget.forceEditingMode) _onClickedEditing();
  }

  Future<void> _onClickedDeleting() async {
    // Show confirmation dialog
    final answer = await showDialog(
      context: context,
      builder:
          (context) =>
              ConfirmDeleteInternshipDialog(internship: widget.internship),
    );
    if (answer == null || !answer || !mounted) return;

    InternshipsProvider.of(context, listen: false).remove(widget.internship);
  }

  Future<void> _onClickedEditing() async {
    if (_isEditing) {
      // Validate the form
      if (!(await validate()) || !mounted) return;

      // Finish editing
      final newInternship = editedInternship;
      if (newInternship.getDifference(widget.internship).isNotEmpty) {
        InternshipsProvider.of(context, listen: false).replace(newInternship);
      }
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    final student = StudentsProvider.of(
      context,
      listen: true,
    ).firstWhereOrNull((student) => student.id == widget.internship.studentId);
    final enterprise = EnterprisesProvider.of(
      context,
      listen: true,
    ).firstWhereOrNull(
      (enterprise) => enterprise.id == widget.internship.enterpriseId,
    );

    return widget.isExpandable
        ? AnimatedExpandingCard(
          initialExpandedState: _isExpanded,
          onTapHeader: (isExpanded) => setState(() => _isExpanded = isExpanded),
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                child: Text(
                  (student == null || enterprise == null)
                      ? 'En cours de chargement...'
                      : '${student.fullName} - ${enterprise.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_isExpanded)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: _onClickedDeleting,
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _onClickedEditing,
                    ),
                  ],
                ),
            ],
          ),
          child: _buildEditingForm(),
        )
        : _buildEditingForm();
  }

  Widget _buildEditingForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupervisingTeacher(),
            const SizedBox(height: 8),
            _buildSupervisorContact(),
            const SizedBox(height: 8),
            _buildWeeklySchedule(),
            const SizedBox(height: 8.0),
            _buildExpectedDuration(),
            const SizedBox(height: 8.0),
            _buildEndDate(),
            const SizedBox(height: 8.0),
            _buildAchievedDuration(),
            const SizedBox(height: 8),
            _buildTeacherNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisingTeacher() {
    _teacherPickerController.teacher =
        TeachersProvider.of(context, listen: true).firstWhereOrNull(
          (teacher) => teacher.id == widget.internship.signatoryTeacherId,
        ) ??
        Teacher.empty;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TeacherPickerTile(
        title: 'Enseignant·e responsable',
        controller: _teacherPickerController,
        editMode: _isEditing,
      ),
    );
  }

  Widget _buildSupervisorContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isEditing && !_hasEndDate
            ? Text('Contact')
            : Text('Contact : ${widget.internship.supervisor.toString()}'),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing && !_hasEndDate)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactFirstNameController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Le prénom du contact est requis';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _contactLastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de famille',
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Le nom du contact est requis';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              PhoneListTile(
                controller: _contactPhoneController,
                isMandatory: false,
                enabled: _isEditing && !_hasEndDate,
              ),
              const SizedBox(height: 4),
              EmailListTile(
                controller: _contactEmailController,
                isMandatory: false,
                enabled: _isEditing && !_hasEndDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySchedule() {
    return ScheduleListTile(
      scheduleController: _schedulesController,
      editMode: _isEditing && !_hasEndDate,
    );
  }

  Widget _buildExpectedDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre d\'heures prévues'),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: TextFormField(
            controller: _expectedDurationController,
            decoration: const InputDecoration(
              labelText: '* Nombre total d\'heures de stage à faire',
              labelStyle: TextStyle(color: Colors.black),
            ),
            validator:
                (text) =>
                    text!.isEmpty ? 'Indiquer un nombre d\'heures.' : null,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.black),
            enabled: _isEditing,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Future<void> _promptEndDate() async {
    final date = await showCustomDatePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialDate: _hasEndDate ? _endDate! : DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(widget.internship.dates.start.year - 1),
      lastDate: DateTime(widget.internship.dates.start.year + 2),
    );
    if (date == null) return;
    _endDate = date;
    setState(() {});
  }

  Widget _buildEndDate() {
    return Row(
      children: [
        const Text('Date de fin effective :'),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            _hasEndDate
                ? DateFormat.yMMMEd('fr_CA').format(_endDate!)
                : 'Stage en cours',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        if (_isEditing)
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _endDate = DateTime(0)),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                ),
                onPressed: _promptEndDate,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAchievedDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre d\'heures réalisées'),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: TextFormField(
            controller: _achievedDurationController,
            decoration: const InputDecoration(
              labelText: 'Nombre total d\'heures de stage faites',
              labelStyle: TextStyle(color: Colors.black),
            ),
            style: const TextStyle(color: Colors.black),
            enabled: _isEditing,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherNotes() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _teacherNotesController,
            enabled: _isEditing,
            style: TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Notes de l\'enseignant·e·s',
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
