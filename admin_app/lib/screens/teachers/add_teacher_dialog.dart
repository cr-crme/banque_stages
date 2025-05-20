import 'package:admin_app/screens/teachers/teacher_list_tile.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key, required this.schoolBoard});

  final SchoolBoard schoolBoard;

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _radioKey = GlobalKey<FormFieldState>();
  final _editingKey = GlobalKey();
  String? _seletecSchoolId;

  void _onClickedConfirm() {
    final state = _editingKey.currentState as TeacherListTileState;

    // Validate the form
    bool isValid = state.formKey.currentState!.validate();
    isValid = _radioKey.currentState!.validate() && isValid;
    if (!isValid) {
      return;
    }

    final newTeacher = Teacher.empty.copyWith(
      schoolBoardId: widget.schoolBoard.id,
      schoolId: _seletecSchoolId,
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      groups: state.groups.map((e) => e.toString()).toList(),
    );

    Navigator.of(context).pop(newTeacher);
  }

  void _onClickedCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Nouveau·elle enseignant·e',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),
            FormBuilderRadioGroup(
              // TODO Move this to the updater instead of Add
              key: _radioKey,
              name: 'coucou',
              decoration: InputDecoration(labelText: 'Assigner à une école'),
              onChanged: (value) => setState(() => _seletecSchoolId = value),
              validator: (_) {
                return _seletecSchoolId == null
                    ? 'Sélectionner une école'
                    : null;
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
            ),
            const SizedBox(height: 12),
            Text('Compléter les informations personnelles'),
            const SizedBox(height: 8),
            TeacherListTile(
              key: _editingKey,
              teacher: Teacher.empty,
              isExpandable: false,
              forceEditingMode: true,
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(onPressed: _onClickedCancel, child: Text('Annuler')),
        TextButton(onPressed: _onClickedConfirm, child: Text('Confirmer')),
      ],
    );
  }
}
