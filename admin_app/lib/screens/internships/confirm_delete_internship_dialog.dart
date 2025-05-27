import 'package:admin_app/providers/students_provider.dart';
import 'package:common/models/internships/internship.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteInternshipDialog extends StatelessWidget {
  const ConfirmDeleteInternshipDialog({super.key, required this.internship});

  final Internship internship;

  @override
  Widget build(BuildContext context) {
    final student =
        StudentsProvider.of(context, listen: false)[internship.studentId];

    return AlertDialog(
      title: const Text('Supprimer'),

      content: Text(
        'Êtes-vous sûr·e de vouloir supprimer\n'
        'le stage de ${student.fullName} ?',
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
