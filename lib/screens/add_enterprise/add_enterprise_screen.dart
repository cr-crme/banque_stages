import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/add_job_button.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'pages/contact_page.dart';
import 'pages/informations_page.dart';
import 'pages/jobs_page.dart';

class AddEnterpriseScreen extends StatefulWidget {
  const AddEnterpriseScreen({super.key});

  @override
  State<AddEnterpriseScreen> createState() => _AddEnterpriseScreenState();
}

class _AddEnterpriseScreenState extends State<AddEnterpriseScreen> {
  final _scrollController = ScrollController();

  final _informationsKey = GlobalKey<InformationsPageState>();
  final _jobsKey = GlobalKey<JobsPageState>();
  final _contactKey = GlobalKey<ContactPageState>();

  int _currentStep = 0;
  final List<StepState> _stepStatus = [
    StepState.indexed,
    StepState.indexed,
    StepState.indexed
  ];

  void _showInvalidFieldsSnakBar([String? message]) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message ?? 'Remplir tous les champs avec un *.')));
  }

  void _previousStep() {
    if (_currentStep == 0) return;

    _currentStep -= 1;
    _scrollController.jumpTo(0);
    setState(() {});
  }

  void _nextStep() async {
    bool valid = false;
    String? message;
    if (_currentStep >= 0) {
      message = await _informationsKey.currentState!.validate();
      valid = message == null;
      _stepStatus[0] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 1) {
      valid = _jobsKey.currentState!.validate();
      _stepStatus[1] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 2) {
      message = await _contactKey.currentState!.validate();
      valid = message == null;
      _stepStatus[2] = valid ? StepState.complete : StepState.error;
    }
    setState(() {});

    if (!valid) {
      _showInvalidFieldsSnakBar(message);
      return;
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_currentStep == 2) {
      if ((await _informationsKey.currentState!.validate()) != null) {
        setState(() {
          _currentStep = 0;
          _scrollController.jumpTo(0);
          _scrollController.jumpTo(0);
        });
        return;
      }

      if (!_jobsKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
          _scrollController.jumpTo(0);
        });
        return;
      }
      _submit();
    } else {
      setState(() {
        _currentStep += 1;
        _scrollController.jumpTo(0);
      });
    }
  }

  void _submit() async {
    final teachers = TeachersProvider.of(context, listen: false);
    final enterprises = EnterprisesProvider.of(context, listen: false);

    Enterprise enterprise = Enterprise(
      name: _informationsKey.currentState!.name!,
      neq: _informationsKey.currentState?.neq,
      activityTypes: _informationsKey.currentState!.activityTypes,
      recrutedBy: teachers.currentTeacherId,
      shareWith: _informationsKey.currentState!.shareWith!,
      jobs: _jobsKey.currentState!.jobs,
      contact: Person(
        firstName: _contactKey.currentState!.contactFirstName!,
        lastName: _contactKey.currentState!.contactLastName!,
        phone: PhoneNumber.fromString(_contactKey.currentState!.contactPhone!),
        email: _contactKey.currentState!.contactEmail!,
      ),
      contactFunction: _contactKey.currentState!.contactFunction!,
      address: _informationsKey.currentState!.addressController.address!,
    );

    enterprises.add(enterprise);
    if (mounted) Navigator.pop(context);
  }

  void _cancel() async {
    final result = await showDialog(
        context: context, builder: (context) => const ConfirmPopDialog());
    if (!mounted || result == null || !result) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter une entreprise'),
        ),
        body: ScrollableStepper(
          type: StepperType.horizontal,
          scrollController: _scrollController,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() {
            _scrollController.jumpTo(0);
            _currentStep = tapped;
          }),
          onStepCancel: _cancel,
          steps: [
            Step(
              state: _stepStatus[0],
              isActive: _currentStep == 0,
              title: const Text('Informations'),
              content: InformationsPage(key: _informationsKey),
            ),
            Step(
              state: _stepStatus[1],
              isActive: _currentStep == 1,
              title: const Text('Métiers'),
              content: JobsPage(key: _jobsKey),
            ),
            Step(
              state: _stepStatus[2],
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

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Visibility(
            visible: _currentStep == 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: AddJobButton(
                onPressed: () => _jobsKey.currentState!.addJobToForm(),
                style: Theme.of(context).textButtonTheme.style!.copyWith(
                    backgroundColor: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .backgroundColor),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(child: SizedBox()),
              if (_currentStep != 0)
                OutlinedButton(
                    onPressed: _previousStep, child: const Text('Précédent')),
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
        ],
      ),
    );
  }
}
