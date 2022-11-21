import 'package:flutter/material.dart';

import '/common/models/job.dart';
import '/common/widgets/form_fields/job_form_field.dart';
import '/misc/form_service.dart';

class JobCreatorDialog extends StatefulWidget {
  const JobCreatorDialog({super.key});

  @override
  State<JobCreatorDialog> createState() => _JobCreatorDialogState();
}

class _JobCreatorDialogState extends State<JobCreatorDialog> {
  final _formKey = GlobalKey<FormState>();

  Job? _job;

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    if (FormService.validateForm(_formKey, save: true)) {
      Navigator.pop(context, _job);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un nouveau métier"),
      content: Form(
        key: _formKey,
        child: JobFormField(
          initialValue: Job(),
          onSaved: (Job? job) => setState(() {
            _job = job;
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancel,
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          child: const Text("Confirmer"),
        ),
      ],
    );
  }
}
