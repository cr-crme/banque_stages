import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common_flutter/helpers/form_service.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:flutter/material.dart';

class JobCreatorDialog extends StatefulWidget {
  const JobCreatorDialog({super.key, required this.enterprise});

  final Enterprise enterprise;

  @override
  State<JobCreatorDialog> createState() => _JobCreatorDialogState();
}

class _JobCreatorDialogState extends State<JobCreatorDialog> {
  final _formKey = GlobalKey<FormState>();

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    if (FormService.validateForm(_formKey,
        save: true, showSnackbarError: true)) {
      Navigator.pop(context, controller.job);
    }
  }

  late final controller = EnterpriseJobListController(
    job: Job.empty,
    specializationBlackList:
        widget.enterprise.jobs.map((e) => e.specialization).toList(),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PopScope(
        child: AlertDialog(
          title: const Text('Ajouter un nouveau poste'),
          content: Form(
            key: _formKey,
            child: EnterpriseJobListTile(
              controller: controller,
              schools: SchoolBoardsProvider.of(context, listen: false)
                      .mySchoolBoard
                      ?.schools ??
                  [],
              elevation: 0,
              canChangeExpandedState: false,
              initialExpandedState: true,
              editMode: true,
              showHeader: false,
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
