import 'package:admin_app/screens/teachers/teacher_list_tile.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key, required this.schoolBoard});

  final SchoolBoard schoolBoard;

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final _editingKey = GlobalKey();

  Future<void> _onClickedConfirm() async {
    final state = _editingKey.currentState as TeacherListTileState;

    // Validate the form
    if (!(await state.validate()) || !mounted) return;
    Navigator.of(context).pop(state.editedTeacher);
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

            const SizedBox(height: 12),
            Text('Compléter les informations personnelles'),
            const SizedBox(height: 8),
            TeacherListTile(
              key: _editingKey,
              teacher: Teacher.empty,
              isExpandable: false,
              forceEditingMode: true,
              schoolBoard: widget.schoolBoard,
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
