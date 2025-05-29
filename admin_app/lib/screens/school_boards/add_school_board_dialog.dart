import 'package:admin_app/screens/school_boards/school_board_list_tile.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class AddSchoolBoardDialog extends StatefulWidget {
  const AddSchoolBoardDialog({super.key, required this.schoolBoard});

  final SchoolBoard schoolBoard;

  @override
  State<AddSchoolBoardDialog> createState() => _AddSchoolDialogState();
}

class _AddSchoolDialogState extends State<AddSchoolBoardDialog> {
  final _editingKey = GlobalKey();

  Future<void> _onClickedConfirm() async {
    final state = _editingKey.currentState as SchoolBoardListTileState;

    // Validate the form
    if (!(await state.validate()) || !mounted) return;
    Navigator.of(context).pop(state.editedSchoolBoard);
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
                'Nouvelle commission scolaire',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 12),
            Text('Compléter les informations'),
            const SizedBox(height: 8),
            SchoolBoardListTile(
              key: _editingKey,
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
