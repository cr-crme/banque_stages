import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'specialized_students_step.dart';
import 'supervision_step.dart';
import 'prerequisites_step.dart';

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

  final _prerequisitesKey = GlobalKey<PrerequisitesStepState>();
  final _supervisionKey = GlobalKey<SupervisionStepState>();
  final _specializedStudentsKey = GlobalKey<SpecializedStudentsStepState>();
  final double _tabHeight = 0.0;
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
      message = await _prerequisitesKey.currentState!.validate();
      valid = message == null;
      _stepStatus[0] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 1) {
      message = await _supervisionKey.currentState!.validate();
      valid = message == null;
      _stepStatus[1] = valid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 2) {
      message = await _specializedStudentsKey.currentState!.validate();
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
      if ((await _prerequisitesKey.currentState!.validate()) != null) {
        setState(() {
          _currentStep = 0;
          _scrollToCurrentTab();
        });
        _showInvalidFieldsSnakBar(message);
        return;
      }

      if (await _supervisionKey.currentState!.validate() != null) {
        setState(() {
          _currentStep = 1;
          _scrollToCurrentTab();
        });
        _showInvalidFieldsSnakBar(message);
        return;
      }
      _submit();
    } else {
      setState(() {
        _currentStep += 1;
        _scrollToCurrentTab();
      });
    }
  }

  void _previousStep() {
    _currentStep--;
    _scrollToCurrentTab();
    setState(() {});
  }

  void _scrollToCurrentTab() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Wait until the stepper has closed and reopened before moving
      _scrollController.jumpTo(_currentStep * _tabHeight);
    });
  }

  void _submit() {
    final List<String> enterpriseRequests = _prerequisitesKey
        .currentState!.requiredForJob.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (_prerequisitesKey.currentState!.otherRequirementsText != null) {
      enterpriseRequests
          .add(_prerequisitesKey.currentState!.otherRequirementsText!);
    }

    final List<String> skills = _prerequisitesKey
        .currentState!.skillsRequired.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (_prerequisitesKey.currentState!.otherSkillsText != null) {
      skills.add(_prerequisitesKey.currentState!.otherSkillsText!);
    }

    // Add the evaluation to a copy of the internship
    final internships = InternshipsProvider.of(context, listen: false);
    final internship = internships.firstWhere((e) => e.jobId == widget.jobId);
    internship.enterpriseEvaluation = PostIntershipEnterpriseEvaluation(
      internshipId: internship.id,
      minimumAge: _prerequisitesKey.currentState!.minimalAge,
      enterpriseRequests: enterpriseRequests,
      skillsRequired: skills,
      taskVariety: _supervisionKey.currentState!.taskVariety!,
      trainingPlanRespect: _supervisionKey.currentState!.trainingPlan!,
      autonomyExpected: _supervisionKey.currentState!.autonomyExpected!,
      efficiencyExpected: _supervisionKey.currentState!.efficiencyExpected!,
      supervisionStyle: _supervisionKey.currentState!.supervisionStyle!,
      easeOfCommunication: _supervisionKey.currentState!.easeOfCommunication!,
      absenceAcceptance: _supervisionKey.currentState!.absenceAcceptance!,
      supervisionComments: _supervisionKey.currentState!.supervisionComments,
      acceptanceTsa: _specializedStudentsKey.currentState!.acceptanceTsa,
      acceptanceLanguageDeficiency:
          _specializedStudentsKey.currentState!.acceptanceLanguageDeficiency,
      acceptanceMentalDeficiency:
          _specializedStudentsKey.currentState!.acceptanceMentalDeficiency,
      acceptancePhysicalDeficiency:
          _specializedStudentsKey.currentState!.acceptancePhysicalDeficiency,
      acceptanceMentalHealthIssue:
          _specializedStudentsKey.currentState!.acceptanceMentalHealthIssue,
      acceptanceBehaviorIssue:
          _specializedStudentsKey.currentState!.acceptanceBehaviorIssue,
    );

    // Pass the evaluation data to the rest of the app
    internships.replace(internship);

    Navigator.pop(context);
  }

  void _cancel() async {
    final result = await showDialog(
        context: context, builder: (context) => const ConfirmPopDialog());
    if (!mounted || result == null || !result) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Évaluation post-stage'),
          leading: IconButton(
              onPressed: _cancel, icon: const Icon(Icons.arrow_back))),
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
              title: const Text('Prérequis'),
              content: PrerequisitesStep(
                key: _prerequisitesKey,
                job: job,
              ),
            ),
            Step(
              state: _stepStatus[1],
              isActive: _currentStep == 1,
              title: const Text('Encadrement'),
              content: SupervisionStep(
                key: _supervisionKey,
                job: job,
              ),
            ),
            Step(
              state: _stepStatus[2],
              isActive: _currentStep == 2,
              title: const Text('Clientèle\nspécialisée'),
              content: SpecializedStudentsStep(key: _specializedStudentsKey),
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
          if (_currentStep != 0)
            OutlinedButton(
                onPressed: _previousStep, child: const Text('Précédent')),
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
