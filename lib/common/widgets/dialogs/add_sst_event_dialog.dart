import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_text.dart';
import 'package:flutter/material.dart';

import '/misc/form_service.dart';

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
    if (FormService.validateForm(_formKey,
        save: true, showSnackbarError: false)) {
      Navigator.pop(context, {
        'eventType': _eventType,
        'description': _description,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Signaler un évènement'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            RadioListTile(
              title: const Text(
                  'Un accident ou un incident en stage (ex. blessure mineure, agression verbale d’un client, harcèlement des collègues)'),
              value: SstEventType.pastIncidents,
              groupValue: _eventType,
              onChanged: (value) =>
                  setState(() => _eventType = SstEventType.pastIncidents),
            ),
            RadioListTile(
              title: const Text('Une situation dangereuse'),
              value: SstEventType.dangerousSituations,
              groupValue: _eventType,
              onChanged: (value) =>
                  setState(() => _eventType = SstEventType.dangerousSituations),
            ),
            QuestionWithText(
              question: 'Description de l\'évènement',
              onSaved: (text) => setState(() => _description = text),
              validator: (text) => text?.isEmpty ?? true
                  ? 'Décrivez ce qu\'il s\'est passé'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _onCancel,
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: _eventType != null ? _onConfirm : null,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

enum SstEventType { pastIncidents, dangerousSituations }
