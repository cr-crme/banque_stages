import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteSchoolBoardDialog extends StatelessWidget {
  const ConfirmDeleteSchoolBoardDialog({super.key, required this.schoolBoard});

  final SchoolBoard schoolBoard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      content: Text(
        'Êtes-vous sûr·e de vouloir\n'
        'supprimer ${schoolBoard.name} ?',
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
