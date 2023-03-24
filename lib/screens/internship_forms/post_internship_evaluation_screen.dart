import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';
import '/misc/form_service.dart';
import 'steps/prerequisites_step.dart';
import 'steps/supervision_step.dart';
import 'steps/tasks_step.dart';

class PostInternshipEvaluationScreen extends StatefulWidget {
  const PostInternshipEvaluationScreen(
      {super.key, required this.enterpriseId, required this.jobId});

  final String enterpriseId;
  final String jobId;

  @override
  State<PostInternshipEvaluationScreen> createState() =>
      _PostInternshipEvaluationScreenState();
}

class _PostInternshipEvaluationScreenState
    extends State<PostInternshipEvaluationScreen> {
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
      setState(() => _currentStep += 1);
    }
  }

  void _submit() {
    _tasksKey.currentState!.formKey.currentState!.save();
    _supervisionKey.currentState!.formKey.currentState!.save();
    _prerequisitesKey.currentState!.formKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();

    enterprises.replaceJob(
      widget.enterpriseId,
      enterprises[widget.enterpriseId].jobs[widget.jobId].copyWith(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Évaluation post-stage'),
      ),
      body: Selector<EnterprisesProvider, Job>(
        builder: (context, job, _) => Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              isActive: _currentStep == 0,
              title: const Text('Tâches'),
              content: TasksStep(
                key: _tasksKey,
                job: job,
              ),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text('Encadrement'),
              content: SupervisionStep(
                key: _supervisionKey,
                job: job,
              ),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text('Pré-requis'),
              content: PrerequisitesStep(
                key: _prerequisitesKey,
                job: job,
              ),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
        selector: (context, enterprises) =>
            enterprises[widget.enterpriseId].jobs[widget.jobId],
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
              onPressed: details.onStepCancel, child: const Text('Annuler')),
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
