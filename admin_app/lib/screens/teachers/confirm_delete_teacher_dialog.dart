import 'package:common/models/persons/teacher.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteTeacherDialog extends StatelessWidget {
  const ConfirmDeleteTeacherDialog({super.key, required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      content: Text(
        'Êtes-vous sûr·e de vouloir\n'
        'supprimer ${teacher.firstName} ${teacher.lastName} ?',
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
