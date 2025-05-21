import 'package:admin_app/screens/schools/school_list_tile.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class AddSchoolDialog extends StatefulWidget {
  const AddSchoolDialog({super.key, required this.schoolBoard});

  final SchoolBoard schoolBoard;

  @override
  State<AddSchoolDialog> createState() => _AddSchoolDialogState();
}

class _AddSchoolDialogState extends State<AddSchoolDialog> {
  final _editingKey = GlobalKey();

  Future<void> _onClickedConfirm(BuildContext context) async {
    final state = _editingKey.currentState as SchoolListTileState;

    // Validate the form
    if (!(await state.validate()) || !context.mounted) return;

    final newSchool = School.empty.copyWith(name: state.firstName);

    Navigator.of(context).pop(newSchool);
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
                'Nouveau·école',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 12),
            Text('Compléter les informations personnelles'),
            const SizedBox(height: 8),
            SchoolListTile(
              key: _editingKey,
              school: School.empty,
              schoolBoard: widget.schoolBoard,
              isExpandable: false,
              forceEditingMode: true,
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(onPressed: _onClickedCancel, child: Text('Annuler')),
        TextButton(
          onPressed: () => _onClickedConfirm(context),
          child: Text('Confirmer'),
        ),
      ],
    );
  }
}
