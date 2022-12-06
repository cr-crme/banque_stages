import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/misc/form_service.dart';
import 'steps/general_informations_step.dart';
import 'steps/requirements_step.dart';
import 'steps/schedule_step.dart';

class InternshipEnrollmentScreen extends StatefulWidget {
  const InternshipEnrollmentScreen({super.key});

  @override
  State<InternshipEnrollmentScreen> createState() =>
      _InternshipEnrollmentScreenState();
}

class _InternshipEnrollmentScreenState
    extends State<InternshipEnrollmentScreen> {
  late final _enterpriseId =
      ModalRoute.of(context)!.settings.arguments as String? ?? "";

  final _tasksKey = GlobalKey<GeneralInformationsStepState>();
  final _supervisionKey = GlobalKey<ScheduleStepState>();
  final _prerequisitesKey = GlobalKey<RequirementsStepState>();
  int _currentStep = 0;

  void _nextStep() {
    final formKeys = [
      _tasksKey.currentState!.formKey,
      _supervisionKey.currentState!.formKey,
      _prerequisitesKey.currentState!.formKey
    ];

    FormService.validateForm(formKeys[_currentStep]);

    if (_currentStep == 2) {
      _submit();
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _submit() {
    _tasksKey.currentState!.formKey.currentState!.save();
    _supervisionKey.currentState!.formKey.currentState!.save();
    _prerequisitesKey.currentState!.formKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Évaluation post-stage"),
      ),
      body: Selector<EnterprisesProvider, Enterprise>(
        builder: (context, enterprise, _) => Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              isActive: _currentStep == 0,
              title: const Text("Général"),
              content: GeneralInformationsStep(
                key: _tasksKey,
                enterprise: enterprise,
              ),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text("Horaire"),
              content: ScheduleStep(
                key: _supervisionKey,
              ),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text("Exigences"),
              content: RequirementsStep(
                key: _prerequisitesKey,
              ),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
        selector: (context, enterprises) => enterprises[_enterpriseId],
      ),
    );
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
              onPressed: details.onStepCancel, child: const Text("Annuler")),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 2
                ? const Text("Confirmer")
                : const Text("Suivant"),
          )
        ],
      ),
    );
  }
}
