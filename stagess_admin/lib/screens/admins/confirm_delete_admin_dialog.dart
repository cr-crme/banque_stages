import 'package:flutter/material.dart';
import 'package:stagess_common/models/persons/admin.dart';

class ConfirmDeleteAdminDialog extends StatelessWidget {
  const ConfirmDeleteAdminDialog({super.key, required this.admin});

  final Admin admin;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      content: Text(
        'Êtes-vous sûr·e de vouloir\n'
        'supprimer ${admin.firstName} ${admin.lastName} ?',
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
