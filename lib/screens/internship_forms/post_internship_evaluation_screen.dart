import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';
import 'steps/requirements_step.dart';
import 'steps/supervision_step.dart';
import 'steps/tasks_step.dart';

class PostInternshipEvaluationScreen extends StatefulWidget {
  const PostInternshipEvaluationScreen({super.key});

  static const route = "/post-internship-evaluation";

  @override
  State<PostInternshipEvaluationScreen> createState() =>
      _PostInternshipEvaluationScreenState();
}

class _PostInternshipEvaluationScreenState
    extends State<PostInternshipEvaluationScreen> {
  // late final _jobId =
  //     (ModalRoute.of(context)!.settings.arguments as Map)["jobId"] as String;

  final _tasksKey = GlobalKey<TasksStepState>();
  final _supervisionKey = GlobalKey<SupervisionStepState>();
  final _prerequisitesKey = GlobalKey<PrerequisitesStepState>();
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
        valid = _tasksKey.currentState!.validate();
        break;
      case 1:
        valid = _supervisionKey.currentState!.validate();
        break;
      case 2:
        valid = _prerequisitesKey.currentState!.validate();
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

  void _submit() {
    _tasksKey.currentState!.save();
    _supervisionKey.currentState!.save();
    _prerequisitesKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();

    enterprises.replace(enterprises.first.copyWith());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Évaluation post-stage"),
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
            title: const Text("Tâches"),
            content: TasksStep(
              key: _tasksKey,
              job: Job(),
            ),
          ),
          Step(
            isActive: _currentStep == 1,
            title: const Text("Encadrement"),
            content: SupervisionStep(
              key: _supervisionKey,
              job: Job(),
            ),
          ),
          Step(
            isActive: _currentStep == 2,
            title: const Text("Pré-requis"),
            content: PrerequisitesStep(
              key: _prerequisitesKey,
              job: Job(),
            ),
          ),
        ],
        controlsBuilder: _controlBuilder,
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
