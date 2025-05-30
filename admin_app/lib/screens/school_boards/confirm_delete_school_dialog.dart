import 'package:common/models/school_boards/school.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteSchoolDialog extends StatelessWidget {
  const ConfirmDeleteSchoolDialog({super.key, required this.school});

  final School school;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      content: Text(
        'Êtes-vous sûr·e de vouloir\n'
        'supprimer ${school.name} ?',
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
