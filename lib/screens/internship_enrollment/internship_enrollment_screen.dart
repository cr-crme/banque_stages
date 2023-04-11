import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/phone_number.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/misc/form_service.dart';
import '/router.dart';
import 'steps/general_informations_step.dart';
import 'steps/requirements_step.dart';
import 'steps/schedule_step.dart';

class InternshipEnrollmentScreen extends StatefulWidget {
  const InternshipEnrollmentScreen({super.key, required this.enterpriseId});

  final String enterpriseId;

  @override
  State<InternshipEnrollmentScreen> createState() =>
      _InternshipEnrollmentScreenState();
}

class _InternshipEnrollmentScreenState
    extends State<InternshipEnrollmentScreen> {
  final _generalInfoKey = GlobalKey<GeneralInformationsStepState>();
  final _scheduleKey = GlobalKey<ScheduleStepState>();
  final _requirementsKey = GlobalKey<RequirementsStepState>();
  int _currentStep = 0;

  void _previousStep() {
    if (_currentStep == 0) return;
    _currentStep -= 1;
    setState(() {});
  }

  void _nextStep() {
    final formKeys = [
      _generalInfoKey.currentState!.formKey,
      _scheduleKey.currentState!.formKey,
      _requirementsKey.currentState!.formKey
    ];

    final isValid = FormService.validateForm(formKeys[_currentStep]);
    if (!isValid) return;

    if (_currentStep != 2) {
      _currentStep += 1;
      setState(() {});
      return;
    }

    // Submit
    _generalInfoKey.currentState!.formKey.currentState!.save();
    _scheduleKey.currentState!.formKey.currentState!.save();
    _requirementsKey.currentState!.formKey.currentState!.save();
    final enterprise = EnterprisesProvider.of(context, listen: false)
        .fromId(widget.enterpriseId);

    final internship = Internship(
      studentId: _generalInfoKey.currentState!.student!.id,
      teacherId: TeachersProvider.of(context, listen: false).currentTeacherId,
      enterpriseId: widget.enterpriseId,
      jobId: enterprise
          .availableJobs(context)
          .firstWhere((job) =>
              job.specialization ==
              _generalInfoKey.currentState!.primaryJob!.specialization)
          .id,
      extraSpecializationId: _generalInfoKey.currentState!.extraSpecializations
          .map<String>((e) => e!.id)
          .toList(),
      supervisor: Person(
          firstName: _generalInfoKey.currentState!.supervisorFirstName!,
          lastName: _generalInfoKey.currentState!.supervisorLastName!,
          email: _generalInfoKey.currentState!.supervisorEmail ?? '',
          phone: PhoneNumber.fromString(
              _generalInfoKey.currentState!.supervisorPhone)),
      protections: _requirementsKey.currentState!.protections,
      uniform: _requirementsKey.currentState!.uniform,
      date: _scheduleKey.currentState!.dateRange,
      expectedLength: _scheduleKey.currentState!.intershipLength,
      achievedLength: 0,
      weeklySchedules: _scheduleKey.currentState!.weeklySchedules,
      visitingPriority: VisitingPriority.low,
      isClosed: false,
    );

    InternshipsProvider.of(context, listen: false).add(internship);

    Navigator.pop(context);
    GoRouter.of(context).pushNamed(Screens.student,
        params: {'id': internship.studentId, 'initialPage': '1'});
  }

  void _onPressedCancel(ControlsDetails details) async {
    final answer = await ConfirmPopDialog.show(context);
    if (!answer) return;

    details.onStepCancel!();
  }

  void _onPressBack() async {
    final answer = await ConfirmPopDialog.show(context);
    if (!answer || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscrire un stagiaire'),
        leading: IconButton(
            onPressed: _onPressBack, icon: const Icon(Icons.arrow_back)),
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
                  key: _generalInfoKey, enterprise: enterprise),
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text('Horaire'),
              content: ScheduleStep(key: _scheduleKey),
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text('Exigences'),
              content: RequirementsStep(key: _requirementsKey),
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
