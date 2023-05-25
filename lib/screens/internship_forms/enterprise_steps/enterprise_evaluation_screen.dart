import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'prerequisites_step.dart';
import 'supervision_step.dart';
import 'tasks_step.dart';

class EnterpriseEvaluationScreen extends StatefulWidget {
  const EnterpriseEvaluationScreen(
      {super.key, required this.id, required this.jobId});

  final String id;
  final String jobId;

  @override
  State<EnterpriseEvaluationScreen> createState() =>
      _EnterpriseEvaluationScreenState();
}

class _EnterpriseEvaluationScreenState
    extends State<EnterpriseEvaluationScreen> {
  final _scrollController = ScrollController();

  final _tasksKey = GlobalKey<TasksStepState>();
  final _supervisionKey = GlobalKey<SupervisionStepState>();
  final _prerequisitesKey = GlobalKey<PrerequisitesStepState>();
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
      setState(() {
        _currentStep += 1;
        _scrollController.jumpTo(0);
      });
    }
  }

  void _submit() {
    _tasksKey.currentState!.formKey.currentState!.save();
    _supervisionKey.currentState!.formKey.currentState!.save();
    _prerequisitesKey.currentState!.formKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();

    enterprises.replaceJob(
      widget.id,
      enterprises[widget.id].jobs[widget.jobId].copyWith(
            taskVariety: _tasksKey.currentState!.taskVariety,
            autonomyExpected: _tasksKey.currentState!.autonomyExpected,
            efficiencyWanted: _tasksKey.currentState!.efficiencyWanted,
            skillsRequired: _tasksKey.currentState!.skillsRequired.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList(),
            welcomingTsa: _supervisionKey.currentState!.welcomingTSA,
            welcomingCommunication:
                _supervisionKey.currentState!.welcomingCommunication,
            welcomingMentalDeficiency:
                _supervisionKey.currentState!.welcomingMentalDeficiency,
            welcomingMentalHealthIssue:
                _supervisionKey.currentState!.welcomingMentalHealthIssue,
            minimalAge: _prerequisitesKey.currentState!.minimalAge,
            uniform: _prerequisitesKey.currentState!.uniform,
            requirements: _prerequisitesKey.currentState!.requiredForJob.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList(),
          ),
    );

    Navigator.pop(context);
  }

  void _onPressedCancel(ControlsDetails details) async {
    final answer = await ConfirmPopDialog.show(context);
    if (!answer) return;

    details.onStepCancel!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Évaluation post-stage'),
        leading: Container(),
      ),
      body: Selector<EnterprisesProvider, Job>(
        builder: (context, job, _) => ScrollableStepper(
          type: StepperType.horizontal,
          scrollController: _scrollController,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() {
            _scrollController.jumpTo(0);
            _currentStep = tapped;
          }),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              isActive: _currentStep == 0,
              title: const Text('Encadrement'),
              content: TasksStep(
                key: _tasksKey,
                job: job,
              ),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text('Clientèle \nspécialisée'),
              content: SupervisionStep(
                key: _supervisionKey,
                job: job,
              ),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text('Prérequis'),
              content: PrerequisitesStep(
                key: _prerequisitesKey,
                job: job,
              ),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
        selector: (context, enterprises) =>
            enterprises[widget.id].jobs[widget.jobId],
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
              onPressed: () => _onPressedCancel(details),
              child: const Text('Annuler')),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 2
                ? const Text('Confirmer')
                : const Text('Suivant'),
          )
        ],
      ),
    );
  }
}
