import 'package:common/models/persons/student.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteStudentDialog extends StatelessWidget {
  const ConfirmDeleteStudentDialog({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      content: Text(
        'Êtes-vous sûr·e de vouloir\n'
        'supprimer ${student.firstName} ${student.lastName} ?',
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
