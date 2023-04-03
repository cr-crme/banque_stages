import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/providers/teachers_provider.dart';
import 'pages/contact_page.dart';
import 'pages/informations_page.dart';
import 'pages/jobs_page.dart';

class AddEnterpriseScreen extends StatefulWidget {
  const AddEnterpriseScreen({super.key});

  @override
  State<AddEnterpriseScreen> createState() => _AddEnterpriseScreenState();
}

class _AddEnterpriseScreenState extends State<AddEnterpriseScreen> {
  final _informationsKey = GlobalKey<InformationsPageState>();
  final _jobsKey = GlobalKey<JobsPageState>();
  final _contactKey = GlobalKey<ContactPageState>();
  int _currentStep = 0;

  void _showInvalidFieldsSnakBar([String? message]) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            message ?? 'Assurez vous que tous les champs soient valides')));
  }

  void _nextStep() async {
    bool valid = false;
    String? message;
    switch (_currentStep) {
      case 0:
        valid = _informationsKey.currentState!.validate();
        break;
      case 1:
        valid = _jobsKey.currentState!.validate();
        break;
      case 2:
        message = await _contactKey.currentState!.validate();
        valid = message == null;
        break;
    }

    if (!valid) {
      _showInvalidFieldsSnakBar(message);
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_currentStep == 2) {
      if (!_informationsKey.currentState!.validate()) {
        setState(() {
          _currentStep = 0;
        });
        return;
      }

      if (!_jobsKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
      _submit();
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _submit() async {
    final teachers = TeachersProvider.of(context, listen: false);
    final enterprises = EnterprisesProvider.of(context, listen: false);

    Enterprise enterprise = Enterprise(
      name: _informationsKey.currentState!.name!,
      neq: _informationsKey.currentState?.neq!,
      activityTypes: _informationsKey.currentState!.activityTypes,
      recrutedBy: teachers.currentTeacherId,
      shareWith: _informationsKey.currentState!.shareWith!,
      jobs: _jobsKey.currentState!.jobs,
      contactName: _contactKey.currentState!.contactName!,
      contactFunction: _contactKey.currentState!.contactFunction!,
      contactPhone: _contactKey.currentState!.contactPhone!,
      contactEmail: _contactKey.currentState!.contactEmail!,
      address: await Address.fromAddress(_contactKey.currentState!.address!),
      headquartersAddress:
          await Address.fromAddress(_contactKey.currentState!.address!),
    );

    enterprises.add(enterprise);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle entreprise'),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              isActive: _currentStep == 0,
              title: const Text('Informations'),
              content: InformationsPage(key: _informationsKey),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text('Métiers'),
              content: JobsPage(key: _jobsKey),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text('Contact'),
              content: ContactPage(key: _contactKey),
            )
          ],
          controlsBuilder: _controlBuilder,
        ),
      ),
    );
  }

  void _onPressedCancel(ControlsDetails details) async {
    final answer = await ConfirmPopDialog.show(context);
    if (!answer) return;

    details.onStepCancel!();
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible: _currentStep == 1,
            child: AddJobButton(
                onPressed: () => _jobsKey.currentState!.addJobToForm()),
          ),
          const Expanded(child: SizedBox()),
          OutlinedButton(
              onPressed: () => _onPressedCancel(details),
              child: const Text('Annuler')),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 2
                ? const Text('Ajouter')
                : const Text('Suivant'),
          )
        ],
      ),
    );
  }
}
