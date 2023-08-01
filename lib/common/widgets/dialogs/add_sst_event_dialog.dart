import 'package:crcrme_banque_stages/common/widgets/form_fields/text_with_form.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/misc/form_service.dart';

class AddSstEventDialog extends StatefulWidget {
  const AddSstEventDialog({super.key});

  @override
  State<AddSstEventDialog> createState() => _AddSstEventDialogState();
}

class _AddSstEventDialogState extends State<AddSstEventDialog> {
  final _formKey = GlobalKey<FormState>();

  SstEventType? _eventType;
  String? _description;

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    if (_eventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionner un type d\'incident.'),
        ),
      );
      return;
    }

    if (FormService.validateForm(_formKey,
        save: true, showSnackbarError: true)) {
      Navigator.pop(context, {
        'eventType': _eventType,
        'description': _description,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Signaler un incident'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              RadioListTile(
                title: Text(
                  'Blessure grave : l\'élève a dû aller à l\'hôpital pour recevoir des soins',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: SstEventType.severe,
                groupValue: _eventType,
                onChanged: (value) =>
                    setState(() => _eventType = SstEventType.severe),
              ),
              RadioListTile(
                title: Text(
                  'Agression verbale ou harcèlement par des collègues ou des clients',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: SstEventType.verbal,
                groupValue: _eventType,
                onChanged: (value) =>
                    setState(() => _eventType = SstEventType.verbal),
              ),
              RadioListTile(
                title: Text(
                  'Blessure mineure de l\'élève\n(p. ex. brûlure légère)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: SstEventType.minor,
                groupValue: _eventType,
                onChanged: (value) =>
                    setState(() => _eventType = SstEventType.minor),
              ),
              const SizedBox(height: 12),
              TextWithForm(
                title: 'Raconter ce qu\'il s\'est passé:',
                onSaved: (text) => setState(() => _description = text),
                validator: (text) =>
                    text?.isEmpty ?? true ? 'Que s\'est-il passé?' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _onCancel,
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _onConfirm,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

enum SstEventType { severe, verbal, minor }
