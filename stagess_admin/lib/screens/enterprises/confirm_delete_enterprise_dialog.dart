import 'package:flutter/material.dart';
import 'package:stagess_common/models/enterprises/enterprise.dart';

class ConfirmDeleteEnterpriseDialog extends StatelessWidget {
  const ConfirmDeleteEnterpriseDialog({super.key, required this.enterprise});

  final Enterprise enterprise;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Supprimer'),
      content: Text(
        'Êtes-vous sûr·e de vouloir\n'
        'supprimer ${enterprise.name} ?',
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
