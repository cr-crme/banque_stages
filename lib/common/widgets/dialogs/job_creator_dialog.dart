import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';

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
    if (FormService.validateForm(_formKey,
        save: true, showSnackbarError: false)) {
      Navigator.pop(context, _job);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: const Text('Ajouter un nouveau poste'),
        content: Form(
          key: _formKey,
          child: JobFormFieldListTile(
            onSaved: (Job? job) => setState(() => _job = job),
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
      ),
    );
  }
}
