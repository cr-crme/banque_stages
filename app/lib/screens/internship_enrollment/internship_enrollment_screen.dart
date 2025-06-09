import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/person.dart';
import 'package:common_flutter/helpers/form_service.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_exit_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'steps/general_informations_step.dart';
import 'steps/schedule_step.dart';

class InternshipEnrollmentScreen extends StatefulWidget {
  const InternshipEnrollmentScreen({
    super.key,
    required this.enterpriseId,
  });

  final String enterpriseId;

  @override
  State<InternshipEnrollmentScreen> createState() =>
      _InternshipEnrollmentScreenState();
}

class _InternshipEnrollmentScreenState
    extends State<InternshipEnrollmentScreen> {
  final _scrollController = ScrollController();

  final _generalInfoKey = GlobalKey<GeneralInformationsStepState>();
  final _scheduleKey = GlobalKey<ScheduleStepState>();

  int _currentStep = 0;
  final List<StepState> _stepStatus = [StepState.indexed, StepState.indexed];

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
    setState(() {});

    if (!isAllValid) return;

    if (_currentStep != 1) {
      _currentStep += 1;
      _scrollController.jumpTo(0);
      setState(() {});
      return;
    }

    // Submit
    _generalInfoKey.currentState!.formKey.currentState!.save();
    _scheduleKey.currentState!.formKey.currentState!.save();
    final enterprise = EnterprisesProvider.of(context, listen: false)
        .fromIdOrNull(_generalInfoKey.currentState!.enterprise!.id);
    if (enterprise == null) return;

    final signatoryTeacher =
        TeachersProvider.of(context, listen: false).myTeacher;
    if (signatoryTeacher == null) {
      showSnackBar(context,
          message:
              'Vous devez être connecté en tant qu\'enseignant pour inscrire un stagiaire.');
      return;
    }

    final schoolBoard =
        SchoolBoardsProvider.of(context, listen: false).mySchoolBoard;
    if (schoolBoard == null) return;

    final internship = Internship(
      schoolBoardId: schoolBoard.id,
      creationDate: DateTime.now(),
      studentId: _generalInfoKey.currentState!.student!.id,
      signatoryTeacherId: signatoryTeacher.id,
      extraSupervisingTeacherIds: [],
      enterpriseId: _generalInfoKey.currentState!.enterprise!.id,
      jobId: enterprise.jobs
          .firstWhere((job) =>
              job.specialization ==
              _generalInfoKey.currentState!.primaryJob!.specialization)
          .id,
      extraSpecializationIds: _generalInfoKey.currentState!.extraSpecializations
          .map<String>((e) => e!.id)
          .toList(),
      supervisor: Person(
          firstName: _generalInfoKey.currentState!.supervisorFirstName!,
          middleName: null,
          lastName: _generalInfoKey.currentState!.supervisorLastName!,
          dateBirth: null,
          email: _generalInfoKey.currentState!.supervisorEmail ?? '',
          address: Address.empty,
          phone: PhoneNumber.fromString(
              _generalInfoKey.currentState!.supervisorPhone)),
      dates: _scheduleKey.currentState!.weeklyScheduleController.dateRange!,
      expectedDuration: _scheduleKey.currentState!.internshipDuration,
      achievedDuration: -1,
      endDate: DateTime(0),
      weeklySchedules:
          _scheduleKey.currentState!.weeklyScheduleController.weeklySchedules,
      visitingPriority: VisitingPriority.low,
    );

    InternshipsProvider.of(context, listen: false).add(internship);

    final student = StudentsHelpers.studentsInMyGroups(context, listen: false)
        .firstWhere((e) => e.id == _generalInfoKey.currentState!.student!.id);
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
      pathParameters: Screens.params(internship.studentId),
      queryParameters: Screens.queryParams(pageIndex: '1'),
    );
  }

  void _cancel() async {
    final navigator = Navigator.of(context);
    final answer = await ConfirmExitDialog.show(context,
        content: const Text('Toutes les modifications seront perdues.'));
    if (!mounted || !answer) return;

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final enterprises = EnterprisesProvider.of(context);
    final enterprise = enterprises.fromIdOrNull(widget.enterpriseId);
    if (enterprise == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Inscrire un stagiaire chez\n${enterprise.name}'),
        leading:
            IconButton(onPressed: _cancel, icon: const Icon(Icons.arrow_back)),
      ),
      body: PopScope(
        child: ScrollableStepper(
          type: StepperType.horizontal,
          scrollController: _scrollController,
          currentStep: _currentStep,
          onTapContinue: _nextStep,
          onStepTapped: (int tapped) {
            setState(() {
              _currentStep = tapped;
              _scrollController.jumpTo(0);
            });
          },
          onTapCancel: _cancel,
          steps: [
            Step(
              state: _stepStatus[0],
              isActive: _currentStep == 0,
              title: const Text('Général'),
              content: GeneralInformationsStep(
                  key: _generalInfoKey, enterprise: enterprise),
            ),
            Step(
              state: _stepStatus[1],
              isActive: _currentStep == 1,
              title: const Text('Horaire'),
              content: ScheduleStep(key: _scheduleKey),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
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
            child: _currentStep == 1
                ? const Text('Confirmer')
                : const Text('Suivant'),
          )
        ],
      ),
    );
  }
}
