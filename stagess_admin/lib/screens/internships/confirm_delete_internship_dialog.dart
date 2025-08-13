import 'package:flutter/material.dart';
import 'package:stagess_common/models/internships/internship.dart';
import 'package:stagess_common_flutter/providers/students_provider.dart';

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
