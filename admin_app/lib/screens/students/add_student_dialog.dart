import 'package:admin_app/screens/students/student_list_tile.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key, required this.schoolBoard});

  final SchoolBoard schoolBoard;

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _editingKey = GlobalKey();

  void _onClickedConfirm() {
    final state = _editingKey.currentState as StudentListTileState;

    // Validate the form
    if (!state.validate()) return;
    Navigator.of(context).pop(state.editedStudent);
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
                'Nouveau·elle élève',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 12),
            Text('Compléter les informations personnelles'),
            const SizedBox(height: 8),
            StudentListTile(
              key: _editingKey,
              student: Student.empty,
              schoolBoard: widget.schoolBoard,
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
