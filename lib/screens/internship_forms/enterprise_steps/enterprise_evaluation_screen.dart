import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  final List<StepState> _stepStatus = [
    StepState.indexed,
    StepState.indexed,
    StepState.indexed
  ];

  final _tasksKey = GlobalKey<TasksStepState>();
  final _supervisionKey = GlobalKey<SupervisionStepState>();
  final _prerequisitesKey = GlobalKey<PrerequisitesStepState>();
  int _currentStep = 0;

  void _showInvalidFieldsSnakBar([String? message]) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message ?? 'Remplir tous les champs avec un *.')));
  }

  void _nextStep() async {
    bool valid = false;
    String? message;
    if (_currentStep >= 0) {
      message = await _tasksKey.currentState!.validate();
      valid = message == null;
      _stepStatus[0] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 1) {
      message = await _supervisionKey.currentState!.validate();
      valid = message == null;
      _stepStatus[1] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 2) {
      message = await _prerequisitesKey.currentState!.validate();
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
      if ((await _tasksKey.currentState!.validate()) != null) {
        setState(() {
          _currentStep = 0;
          _scrollController.jumpTo(0);
        });
        _showInvalidFieldsSnakBar(message);
        return;
      }

      if (await _supervisionKey.currentState!.validate() != null) {
        setState(() {
          _currentStep = 1;
          _scrollController.jumpTo(0);
        });
        _showInvalidFieldsSnakBar(message);
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

  void _submit() {
    final List<String> requirements = _prerequisitesKey
        .currentState!.requiredForJob.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (_prerequisitesKey.currentState!.otherRequirementsText != null) {
      requirements.add(_prerequisitesKey.currentState!.otherRequirementsText!);
    }

    final List<String> skills = _tasksKey.currentState!.skillsRequired.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (_tasksKey.currentState!.otherSkillsText != null) {
      skills.add(_tasksKey.currentState!.otherSkillsText!);
    }

    // Add the evaluation to a copy of the internship
    final internships = InternshipsProvider.of(context, listen: false);
    final internship = internships.firstWhere((e) => e.jobId == widget.jobId);
    internship.enterpriseEvaluation = PostIntershipEnterpriseEvaluation(
      internshipId: internship.id,
      taskVariety: _tasksKey.currentState!.taskVariety!,
      autonomyExpected: _tasksKey.currentState!.autonomyExpected!,
      efficiencyWanted: _tasksKey.currentState!.efficiencyWanted!,
      skillsRequired: skills,
      welcomingTsa: _supervisionKey.currentState!.welcomingTSA,
      welcomingCommunication:
          _supervisionKey.currentState!.welcomingCommunication,
      welcomingMentalDeficiency:
          _supervisionKey.currentState!.welcomingMentalDeficiency,
      welcomingMentalHealthIssue:
          _supervisionKey.currentState!.welcomingMentalHealthIssue,
      minimalAge: _prerequisitesKey.currentState!.minimalAge!,
      requirements: requirements,
    );

    // Pass the evaluation data to the rest of the app
    internships.replace(internship);

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
              state: _stepStatus[0],
              isActive: _currentStep == 0,
              title: const Text('Encadrement'),
              content: TasksStep(
                key: _tasksKey,
                job: job,
              ),
            ),
            Step(
              state: _stepStatus[1],
              isActive: _currentStep == 1,
              title: const Text('Clientèle \nspécialisée'),
              content: SupervisionStep(
                key: _supervisionKey,
                job: job,
              ),
            ),
            Step(
              state: _stepStatus[2],
              isActive: _currentStep == 2,
              title: const Text('Prérequis'),
              content: PrerequisitesStep(key: _prerequisitesKey),
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
