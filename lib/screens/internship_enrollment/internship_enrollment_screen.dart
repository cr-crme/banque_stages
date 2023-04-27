import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/phone_number.dart';
import '/common/models/protections.dart';
import '/common/models/uniform.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/widgets/scrollable_stepper.dart';
import '/misc/form_service.dart';
import '/router.dart';
import 'steps/general_informations_step.dart';
import 'steps/requirements_step.dart';
import 'steps/schedule_step.dart';

class InternshipEnrollmentScreen extends StatefulWidget {
  const InternshipEnrollmentScreen({
    super.key,
    this.enterpriseId,
    this.studentId,
  });

  final String? enterpriseId;
  final String? studentId;

  @override
  State<InternshipEnrollmentScreen> createState() =>
      _InternshipEnrollmentScreenState();
}

class _InternshipEnrollmentScreenState
    extends State<InternshipEnrollmentScreen> {
  final _scrollController = ScrollController();

  final _generalInfoKey = GlobalKey<GeneralInformationsStepState>();
  final _scheduleKey = GlobalKey<ScheduleStepState>();
  final _requirementsKey = GlobalKey<RequirementsStepState>();

  int _currentStep = 0;
  final List<StepState> _stepStatus = [
    StepState.indexed,
    StepState.indexed,
    StepState.indexed
  ];

  void _previousStep() {
    if (_currentStep == 0) return;
    _currentStep -= 1;
    _scrollController.jumpTo(0);
    setState(() {});
  }

  void _nextStep() async {
    final formKeys = [
      _generalInfoKey.currentState!.formKey,
      _scheduleKey.currentState!.formKey,
      _requirementsKey.currentState!.formKey
    ];

    bool isAllValid = true;
    if (_currentStep >= 0) {
      final isValid = FormService.validateForm(formKeys[0]);
      isAllValid = isAllValid && isValid;
      _stepStatus[0] = isValid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 1) {
      final isValid = FormService.validateForm(formKeys[1]);
      isAllValid = isAllValid && isValid;
      _stepStatus[1] = isValid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 2) {
      final isValid = FormService.validateForm(formKeys[2]) &&
          _requirementsKey.currentState!.validateProtectionsCheckboxes();
      isAllValid = isAllValid && isValid;
      _stepStatus[2] = isValid ? StepState.complete : StepState.error;
    }
    setState(() {});

    if (!isAllValid) return;

    if (_currentStep != 2) {
      _currentStep += 1;
      _scrollController.jumpTo(0);
      setState(() {});
      return;
    }

    // Submit
    _generalInfoKey.currentState!.formKey.currentState!.save();
    _scheduleKey.currentState!.formKey.currentState!.save();
    _requirementsKey.currentState!.formKey.currentState!.save();
    final enterprise = EnterprisesProvider.of(context, listen: false)
        .fromId(_generalInfoKey.currentState!.enterprise!.id);

    final internship = Internship(
      versionDate: DateTime.now(),
      studentId: _generalInfoKey.currentState!.student!.id,
      teacherId: TeachersProvider.of(context, listen: false).currentTeacherId,
      enterpriseId: _generalInfoKey.currentState!.enterprise!.id,
      jobId: enterprise.jobs
          .firstWhere((job) =>
              job.specialization ==
              _generalInfoKey.currentState!.primaryJob!.specialization)
          .id,
      extraSpecializationsId: _generalInfoKey.currentState!.extraSpecializations
          .map<String>((e) => e!.id)
          .toList(),
      supervisor: Person(
          firstName: _generalInfoKey.currentState!.supervisorFirstName!,
          lastName: _generalInfoKey.currentState!.supervisorLastName!,
          email: _generalInfoKey.currentState!.supervisorEmail ?? '',
          phone: PhoneNumber.fromString(
              _generalInfoKey.currentState!.supervisorPhone)),
      protections: Protections(
          protections: _requirementsKey.currentState!.protections,
          status: _requirementsKey.currentState!.protectionsStatus),
      uniform: Uniform(
          status: _requirementsKey.currentState!.uniformStatus,
          uniform: _requirementsKey.currentState!.uniform),
      date: _scheduleKey.currentState!.scheduleController.dateRange,
      expectedLength: _scheduleKey.currentState!.intershipLength,
      achievedLength: 0,
      weeklySchedules:
          _scheduleKey.currentState!.scheduleController.weeklySchedules,
      visitingPriority: VisitingPriority.low,
    );

    InternshipsProvider.of(context, listen: false).add(internship);

    final student = StudentsProvider.of(context,
        listen: false)[_generalInfoKey.currentState!.student!.id];
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(
                  '${student.fullName} a bien été inscrit comme stagiaire chez ${enterprise.name}.'
                  '\n\nVous pouvez maintenant accéder aux documents administratifs du stage.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok'),
                )
              ],
            ));

    if (!mounted) return;
    Navigator.pop(context);
    GoRouter.of(context).pushNamed(
      Screens.student,
      params: Screens.params(internship.studentId),
      queryParams: Screens.queryParams(pageIndex: '1'),
    );
  }

  void _cancel() async {
    final result = await showDialog(
        context: context, builder: (context) => const ConfirmPopDialog());
    if (!mounted || result == null || !result) return;

    Navigator.of(context).pop();
  }

  void _onPressBack() async {
    final answer = await ConfirmPopDialog.show(context);
    if (!answer || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final enterprises = EnterprisesProvider.of(context);
    final students = StudentsProvider.of(context);
    if ((widget.enterpriseId != null &&
            !enterprises.hasId(widget.enterpriseId!)) ||
        (widget.studentId != null && !students.hasId(widget.studentId!))) {
      return Container();
    }

    final enterprise = widget.enterpriseId == null
        ? null
        : enterprises.fromId(widget.enterpriseId!);
    final student =
        widget.studentId == null ? null : students.fromId(widget.studentId!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscrire un stagiaire'),
        leading: IconButton(
            onPressed: _onPressBack, icon: const Icon(Icons.arrow_back)),
      ),
      body: ScrollableStepper(
        type: StepperType.horizontal,
        scrollController: _scrollController,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepTapped: (int tapped) {
          setState(() {
            _currentStep = tapped;
            _scrollController.jumpTo(0);
          });
        },
        onStepCancel: _cancel,
        steps: [
          Step(
            state: _stepStatus[0],
            isActive: _currentStep == 0,
            title: const Text('Général'),
            content: GeneralInformationsStep(
                key: _generalInfoKey, enterprise: enterprise, student: student),
          ),
          Step(
            state: _stepStatus[1],
            isActive: _currentStep == 1,
            title: const Text('Horaire'),
            content: ScheduleStep(key: _scheduleKey),
          ),
          Step(
            state: _stepStatus[2],
            isActive: _currentStep == 2,
            title: const Text('Exigences'),
            content: RequirementsStep(key: _requirementsKey),
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
          if (_currentStep != 0)
            OutlinedButton(
                onPressed: _previousStep, child: const Text('Précédent')),
          const SizedBox(width: 20),
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
