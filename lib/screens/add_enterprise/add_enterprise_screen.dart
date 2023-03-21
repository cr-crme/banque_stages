import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/address.dart';
import '/common/models/enterprise.dart';
import '/common/providers/auth_provider.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
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

  void _showInvalidFieldsSnakBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Assurez vous que tous les champs soient valides")));
  }

  void _nextStep() {
    bool valid = false;
    switch (_currentStep) {
      case 0:
        valid = _informationsKey.currentState!.validate();
        break;
      case 1:
        valid = _jobsKey.currentState!.validate();
        break;
      case 2:
        valid = _contactKey.currentState!.validate();
        break;
    }

    if (!valid) {
      _showInvalidFieldsSnakBar();
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_currentStep == 2) {
      _submit();
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _submit() async {
    if (!_informationsKey.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      setState(() => _currentStep = 0);
      return;
    } else if (!_jobsKey.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      setState(() => _currentStep = 1);
      return;
    } else if (!_contactKey.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      setState(() => _currentStep = 2);
      return;
    }

    _informationsKey.currentState!.save();
    _jobsKey.currentState!.save();
    _contactKey.currentState!.save();
    EnterprisesProvider enterprises = context.read<EnterprisesProvider>();
    AuthProvider auth = context.read<AuthProvider>();

    Enterprise enterprise = Enterprise(
      name: _informationsKey.currentState!.name!,
      neq: _informationsKey.currentState!.neq!,
      activityTypes: _informationsKey.currentState!.activityTypes,
      recrutedBy: auth.currentUser?.displayName ?? "?",
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
          title: const Text("Nouvelle entreprise"),
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
              title: const Text("Informations"),
              content: InformationsPage(key: _informationsKey),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text("Métiers"),
              content: JobsPage(key: _jobsKey),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text("Contact"),
              content: ContactPage(key: _contactKey),
            )
          ],
          controlsBuilder: _controlBuilder,
        ),
      ),
    );
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
                onPressed: () => _jobsKey.currentState!.addMetier()),
          ),
          const Expanded(child: SizedBox()),
          OutlinedButton(
              onPressed: details.onStepCancel, child: const Text("Annuler")),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 2
                ? const Text("Ajouter")
                : const Text("Suivant"),
          )
        ],
      ),
    );
  }
}
