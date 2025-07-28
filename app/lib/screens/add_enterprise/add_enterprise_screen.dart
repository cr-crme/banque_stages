import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:crcrme_banque_stages/common/widgets/add_job_button.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_exit_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'pages/contact_page.dart';
import 'pages/informations_page.dart';
import 'pages/jobs_page.dart';

final _logger = Logger('AddEnterpriseScreen');

class AddEnterpriseScreen extends StatefulWidget {
  const AddEnterpriseScreen({super.key});

  static const route = '/add';

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
    showSnackBar(context,
        message: message ?? 'Remplir tous les champs avec un *.');
  }

  void _previousStep() {
    _logger.finer('Previous step in AddEnterpriseScreen: $_currentStep');

    if (_currentStep == 0) return;

    _currentStep -= 1;
    _scrollController.jumpTo(0);
    setState(() {});
  }

  void _nextStep() async {
    _logger.finer('Next step in AddEnterpriseScreen: $_currentStep');

    bool valid = false;
    String? message;
    if (_currentStep >= 0) {
      message = await _informationsKey.currentState!.validate();
      valid = message == null;
      _stepStatus[0] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 1) {
      message = await _contactKey.currentState!.validate();
      valid = message == null;
      _stepStatus[1] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 2) {
      valid = _jobsKey.currentState!.validate();
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

      if ((await _contactKey.currentState!.validate()) != null) {
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
    _logger.info('Submitting enterprise form');
    final teachers = TeachersProvider.of(context, listen: false);
    final enterprises = EnterprisesProvider.of(context, listen: false);
    final myTeacher = teachers.myTeacher;
    if (myTeacher == null) {
      showSnackBar(context,
          message: 'Erreur, votre compte n\'est pas configuré.');
      return;
    }

    Enterprise enterprise = Enterprise(
      schoolBoardId: myTeacher.schoolBoardId,
      name: _informationsKey.currentState!.name!,
      neq: _informationsKey.currentState?.neq,
      activityTypes: _informationsKey.currentState!.activityTypes,
      recruiterId: myTeacher.id,
      jobs: _jobsKey.currentState!.jobs,
      contact: Person(
        firstName: _contactKey.currentState!.contactFirstName!,
        middleName: null,
        lastName: _contactKey.currentState!.contactLastName!,
        dateBirth: null,
        phone: PhoneNumber.fromString(_contactKey.currentState!.contactPhone!),
        address: Address.empty,
        email: _contactKey.currentState!.contactEmail!,
      ),
      contactFunction: _contactKey.currentState!.contactFunction!,
      address: _informationsKey.currentState!.addressController.address!,
    );

    enterprises.add(enterprise);

    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(
                  'L\'entreprise ${enterprise.name} a bien été ajoutée à la banque '
                  'de stages.\n\n'
                  'Vous pouvez maintenant y inscrire des stagiaires.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok'),
                )
              ],
            ));

    _logger.fine('Entreprise added: ${enterprise.name}');
    if (mounted) Navigator.pop(context);
  }

  void _cancel() async {
    _logger.info('Canceling enterprise form');
    final navigator = Navigator.of(context);
    final result = await ConfirmExitDialog.show(context,
        content: const Text('Toutes les modifications seront perdues.'));
    if (!mounted || !result) return;

    _logger.fine('AddEnterpriseScreen cancelled by user.');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building AddEnterpriseScreen');

    return PopScope(
      child: SizedBox(
        width: ResponsiveService.maxBodyWidth,
        child: Scaffold(
          appBar: AppBar(
              title: const Text('Ajouter une entreprise'),
              leading: IconButton(
                  onPressed: _cancel, icon: const Icon(Icons.arrow_back))),
          body: ScrollableStepper(
            type: StepperType.horizontal,
            scrollController: _scrollController,
            currentStep: _currentStep,
            onTapContinue: _nextStep,
            onStepTapped: (int tapped) => setState(() {
              _scrollController.jumpTo(0);
              _currentStep = tapped;
            }),
            onTapCancel: _cancel,
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
                title: const Text('Contact'),
                content: ContactPage(key: _contactKey),
              ),
              Step(
                state: _stepStatus[2],
                isActive: _currentStep == 2,
                title: const Text('Postes'),
                content: JobsPage(key: _jobsKey),
              ),
            ],
            controlsBuilder: _controlBuilder,
          ),
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
            visible: _currentStep == 2,
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
                    ? const Text('Terminer')
                    : const Text('Suivant'),
              )
            ],
          ),
        ],
      ),
    );
  }
}
