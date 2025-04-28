import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:flutter/material.dart';

class JobCreatorDialog extends StatefulWidget {
  const JobCreatorDialog({super.key, required this.enterprise});

  final Enterprise enterprise;

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
        save: true, showSnackbarError: true)) {
      Navigator.pop(context, _job);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PopScope(
        child: AlertDialog(
          title: const Text('Ajouter un nouveau poste'),
          content: Form(
            key: _formKey,
            child: JobFormFieldListTile(
              onSaved: (Job? job) => setState(() => _job = job),
              specializationBlackList:
                  widget.enterprise.jobs.map((e) => e.specialization).toList(),
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
      ),
    );
  }
}
