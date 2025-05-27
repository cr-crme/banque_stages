import 'package:admin_app/providers/enterprises_provider.dart';
import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/internships/confirm_delete_internship_dialog.dart';
import 'package:admin_app/screens/internships/schedule_list_tile.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:admin_app/widgets/teacher_picker_tile.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';

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
    super.dispose();
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  late final _teacherPickerController = TeacherPickerController(
    initial: TeachersProvider.of(context, listen: true).firstWhereOrNull(
      (teacher) => teacher.id == widget.internship.signatoryTeacherId,
    ),
  );
  late final _schedulesController = SchedulesController(
    dateRange: widget.internship.dates,
    weeklySchedules: widget.internship.weeklySchedules,
    internshipDuration: widget.internship.expectedDuration,
  );
  late final _teacherNotesController = TextEditingController(
    text: widget.internship.teacherNotes,
  );

  Internship get editedInternship {
    final schedulesHasChanged =
        !InternshipHelpers.areSchedulesEqual(
          widget.internship.weeklySchedules,
          _schedulesController.weeklySchedules,
        ) ||
        widget.internship.dates != _schedulesController.dateRange;

    var internship = widget.internship.copyWith(
      signatoryTeacherId: _teacherPickerController.teacher.id,
      teacherNotes: _teacherNotesController.text,
      expectedDuration: _schedulesController.internshipDuration,
    );

    if (schedulesHasChanged) {
      // If a mutable has changed, we cannot edit it from here. We have to
      // create a deep copy of the internship and modify this new instance.
      // The easiest way to do this is to serialize, modify and then deserialize.
      final serialized = internship.serialize();
      final newVersion = InternshipMutableElements(
        creationDate: DateTime.now(),
        supervisor: widget.internship.supervisor,
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
            _buildWeeklySchedule(),
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

  Widget _buildWeeklySchedule() {
    return ScheduleListTile(
      scheduleController: _schedulesController,
      editMode: _isEditing,
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
