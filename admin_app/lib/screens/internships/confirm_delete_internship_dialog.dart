import 'package:common/models/internships/internship.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteInternshipDialog extends StatelessWidget {
  const ConfirmDeleteInternshipDialog({super.key, required this.internship});

  final Internship internship;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      // TODO : Get the name of the student from the internship
      content: Text(
        'Êtes-vous sûr·e de vouloir supprimer\n'
        'le stage de ${internship.studentId} ?',
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
