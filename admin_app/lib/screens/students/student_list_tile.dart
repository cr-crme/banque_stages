import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/screens/students/confirm_delete_student_dialog.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';
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
  final _radioKey = GlobalKey<FormFieldState>();
  bool validate() {
    // We do both like so, so all the fields get validated even if one is not valid
    bool isValid = _formKey.currentState?.validate() ?? false;
    isValid = (_radioKey.currentState?.validate() ?? false) && isValid;
    return isValid;
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  String? _seletecSchoolId;
  String get schoolId => _seletecSchoolId ?? widget.student.schoolId;

  TextEditingController? _firstNameController;
  String get firstName =>
      _firstNameController?.text ?? widget.student.firstName;

  TextEditingController? _lastNameController;
  String get lastName => _lastNameController?.text ?? widget.student.lastName;

  TextEditingController? _emailController;
  String? get email => _emailController?.text ?? widget.student.email;

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
      final newStudent = widget.student.copyWith(
        schoolId: _seletecSchoolId,
        firstName: _firstNameController?.text,
        lastName: _lastNameController?.text,
        email: _emailController?.text,
      );

      if (newStudent.getDifference(widget.student).isNotEmpty) {
        StudentsProvider.of(context, listen: false).replace(newStudent);
      }
    } else {
      // Start editing
      _firstNameController = TextEditingController(
        text: widget.student.firstName,
      );
      _lastNameController = TextEditingController(
        text: widget.student.lastName,
      );
      _emailController = TextEditingController(text: widget.student.email);
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
            _buildEmail(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolSelection() {
    return _isEditing
        ? FormBuilderRadioGroup(
          key: _radioKey,
          initialValue: widget.student.schoolId,
          name: 'School selection',
          orientation: OptionsOrientation.vertical,
          decoration: InputDecoration(labelText: 'Assigner à une école'),
          onChanged: (value) => setState(() => _seletecSchoolId = value),
          validator: (_) {
            return schoolId == '-1' ? 'Sélectionner une école' : null;
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
