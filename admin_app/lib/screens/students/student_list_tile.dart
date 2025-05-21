import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/screens/students/confirm_delete_student_dialog.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class StudentListTile extends StatefulWidget {
  const StudentListTile({
    super.key,
    required this.student,
    required this.schoolBoard,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final Student student;
  final bool isExpandable;
  final bool forceEditingMode;
  final SchoolBoard schoolBoard;

  @override
  State<StudentListTile> createState() => StudentListTileState();
}

class StudentListTileState extends State<StudentListTile> {
  final _formKey = GlobalKey<FormState>();
  final _schoolRadioKey = GlobalKey<FormFieldState>();
  final _programRadioKey = GlobalKey<FormFieldState>();
  bool validate() {
    // We do both like so, so all the fields get validated even if one is not valid
    bool isValid = _formKey.currentState?.validate() ?? false;
    isValid = (_schoolRadioKey.currentState?.validate() ?? false) && isValid;
    isValid = (_programRadioKey.currentState?.validate() ?? false) && isValid;
    return isValid;
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  late String _selectedSchoolId = widget.student.schoolId;
  late final _firstNameController = TextEditingController(
    text: widget.student.firstName,
  );
  late final _lastNameController = TextEditingController(
    text: widget.student.lastName,
  );
  late final _groupController = TextEditingController(
    text: widget.student.group == '-1' ? '' : widget.student.group,
  );
  late Program _selectedProgram = widget.student.program;
  late final _emailController = TextEditingController(
    text: widget.student.email,
  );
  late Person? _contact = widget.student.contact;
  Student get editedStudent => widget.student.copyWith(
    schoolBoardId: widget.schoolBoard.id,
    schoolId: _selectedSchoolId,
    firstName: _firstNameController.text,
    lastName: _lastNameController.text,
    group: _groupController.text,
    program: _selectedProgram,
    email: _emailController.text,
  );

  @override
  void initState() {
    super.initState();
    if (widget.forceEditingMode) _onClickedEditing();
  }

  Future<void> _onClickedDeleting(BuildContext context) async {
    // Show confirmation dialog
    final answer = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteStudentDialog(student: widget.student),
    );
    if (answer == null || !answer || !context.mounted) return;

    final students = StudentsProvider.of(context, listen: false);
    students.remove(widget.student);
  }

  void _onClickedEditing() {
    if (_isEditing) {
      // Validate the form
      if (!validate() || !context.mounted) return;

      // Finish editing
      final newStudent = editedStudent;
      if (newStudent.getDifference(widget.student).isNotEmpty) {
        StudentsProvider.of(context, listen: false).replace(newStudent);
      }
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
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
                  '${widget.student.firstName} ${widget.student.lastName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_isExpanded)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _onClickedDeleting(context),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.black,
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
            _buildSchoolSelection(),
            const SizedBox(height: 8),
            _buildName(),
            const SizedBox(height: 4),
            _buildGroup(),
            const SizedBox(height: 4),
            _buildProgramSelection(),
            const SizedBox(height: 4),
            _buildEmail(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolSelection() {
    return _isEditing
        ? FormBuilderRadioGroup(
          key: _schoolRadioKey,
          initialValue: widget.student.schoolId,
          name: 'School selection',
          orientation: OptionsOrientation.vertical,
          decoration: InputDecoration(labelText: 'Assigner à une école'),
          onChanged:
              (value) => setState(() => _selectedSchoolId = value ?? '-1'),
          validator: (_) {
            return _selectedSchoolId == '-1' ? 'Sélectionner une école' : null;
          },
          options:
              widget.schoolBoard.schools
                  .map(
                    (e) => FormBuilderFieldOption(
                      value: e.id,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
        )
        : Container();
  }

  Widget _buildName() {
    return _isEditing
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              validator:
                  (value) =>
                      value?.isEmpty == true ? 'Le prénom est requis' : null,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextFormField(
              controller: _lastNameController,
              validator:
                  (value) =>
                      value?.isEmpty == true ? 'Le nom est requis' : null,
              decoration: const InputDecoration(labelText: 'Nom de famille'),
            ),
          ],
        )
        : Container();
  }

  Widget _buildGroup() {
    return _isEditing
        ? TextFormField(
          controller: _groupController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
          ],
          keyboardType: TextInputType.number,
          validator:
              (value) => value?.isEmpty == true ? 'Le groupe est requis' : null,
          decoration: const InputDecoration(labelText: 'Groupe'),
        )
        : Text('Groupe : ${widget.student.group}');
  }

  Widget _buildProgramSelection() {
    return _isEditing
        ? FormBuilderRadioGroup(
          key: _programRadioKey,
          initialValue: widget.student.program,
          name: 'Program selection',
          enabled: _isEditing,
          orientation: OptionsOrientation.vertical,
          decoration: InputDecoration(labelText: 'Assigner à un programme'),
          onChanged:
              (value) =>
                  setState(() => _selectedProgram = value ?? Program.undefined),
          validator: (_) {
            return _selectedProgram == Program.undefined
                ? 'Sélectionner un programme'
                : null;
          },
          options:
              (widget.forceEditingMode ? Program.values : Program.allowedValues)
                  .map(
                    (e) => FormBuilderFieldOption(
                      value: e,
                      child: Text(e.toString()),
                    ),
                  )
                  .toList(),
        )
        : Text('Programme : ${widget.student.program.toString()}');
  }

  Widget _buildEmail() {
    return _isEditing
        ? TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Le courriel est requis';
            }

            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
              return 'Le courriel est invalide';
            }
            return null;
          },
          decoration: const InputDecoration(labelText: 'Courriel'),
        )
        : Text('Courriel : ${widget.student.email ?? 'Courriel introuvable'}');
  }
}
