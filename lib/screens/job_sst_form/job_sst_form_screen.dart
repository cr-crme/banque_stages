import 'package:crcrme_banque_stages/screens/job_sst_form/steps/danger_step.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/misc/form_service.dart';
import 'steps/general_informations_step.dart';
import 'steps/questions_step.dart';

class JobSstFormScreen extends StatefulWidget {
  const JobSstFormScreen({
    super.key,
    required this.enterpriseId,
    required this.jobId,
  });

  final String enterpriseId;
  final String jobId;

  @override
  State<JobSstFormScreen> createState() => _JobSstFormScreenState();
}

class _JobSstFormScreenState extends State<JobSstFormScreen> {
  final _questionsKey = GlobalKey<QuestionsStepState>();
  final _dangerKey = GlobalKey<DangerStepState>();
  int _currentStep = 0;

  void _nextStep() {
    final formKeys = [
      _questionsKey.currentState!.formKey,
      _dangerKey.currentState!.formKey
    ];

    if (_currentStep != 0 &&
        !FormService.validateForm(formKeys[_currentStep - 1])) {
      return;
    }

    if (_currentStep == 2) {
      _submit();
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _submit() {
    _questionsKey.currentState!.formKey.currentState!.save();
    _dangerKey.currentState!.formKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();
    enterprises.replaceJob(
      widget.enterpriseId,
      enterprises[widget.enterpriseId].jobs[widget.jobId].copyWith(
            sstQuestions: _questionsKey.currentState!.awnser,
            dangerousSituations: _dangerKey.currentState!.dangerousSituations,
            equipmentRequired: _dangerKey.currentState!.equipmentRequired,
            pastIncidents: _dangerKey.currentState!.pastIncidents,
            incidentContact: _dangerKey.currentState!.incidentContact,
          ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SST dans l\'entreprise'),
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
              title: const Text('Général'),
              content: GeneralInformationsStep(
                enterprise: enterprise,
                job: enterprise.jobs[widget.jobId],
              ),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text('Tâches'),
              content: QuestionsStep(
                key: _questionsKey,
                job: enterprise.jobs[widget.jobId],
              ),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text('Dangers'),
              content: DangerStep(
                key: _dangerKey,
                job: enterprise.jobs[widget.jobId],
              ),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
        selector: (context, enterprises) => enterprises[widget.enterpriseId],
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
