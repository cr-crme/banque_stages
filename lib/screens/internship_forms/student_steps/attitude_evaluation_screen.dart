import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_attitude.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'attitude_evaluation_form_controller.dart';

class AttitudeEvaluationScreen extends StatefulWidget {
  const AttitudeEvaluationScreen(
      {super.key, required this.formController, required this.editMode});

  final AttitudeEvaluationFormController formController;
  final bool editMode;

  @override
  State<AttitudeEvaluationScreen> createState() =>
      _AttitudeEvaluationScreenState();
}

class _AttitudeEvaluationScreenState extends State<AttitudeEvaluationScreen> {
  final _scrollController = ScrollController();

  int _currentStep = 0;
  final List<StepState> _stepStatus = [
    StepState.indexed,
    StepState.indexed,
    StepState.indexed,
    StepState.indexed,
  ];

  void _previousStep() {
    if (_currentStep == 0) return;

    _currentStep -= 1;
    _scrollController.jumpTo(0);
    setState(() {});
  }

  void _nextStep() {
    if (_currentStep == 3) {
      _submit();
      return;
    }
    _stepStatus[_currentStep] = StepState.complete;

    _currentStep += 1;
    _scrollController.jumpTo(0);
    setState(() {});
  }

  void _cancel() async {
    final answer = await ConfirmExitDialog.show(context,
        message: 'Toutes les modifications seront perdues.',
        isEditing: widget.editMode);
    if (!mounted || !answer) return;

    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (!widget.formController.isCompleted) {
      await showDialog(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
                title: Text('Formulaire incomplet'),
                content:
                    Text('Veuillez répondre à toutes les questions avec un *.'),
              ));
      return;
    }

    widget.formController.setWereAtMeeting();

    final internships = InternshipsProvider.of(context, listen: false);
    final internship = internships.fromId(widget.formController.internshipId);

    internship.attitudeEvaluations
        .add(widget.formController.toInternshipEvaluation());
    internships.replace(internship);
    Navigator.of(context).pop();
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Expanded(child: SizedBox()),
          if (_currentStep != 0)
            OutlinedButton(
                onPressed: _previousStep, child: const Text('Précédent')),
          const SizedBox(
            width: 20,
          ),
          if (_currentStep != 3)
            TextButton(
              onPressed: details.onStepContinue,
              child: const Text('Suivant'),
            ),
          if (_currentStep == 3 && widget.editMode)
            TextButton(
                onPressed: details.onStepContinue,
                child: const Text('Soumettre')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final internship =
        InternshipsProvider.of(context)[widget.formController.internshipId];
    final student = StudentsProvider.studentsInMyGroup(context)
        .firstWhereOrNull((e) => e.id == internship.studentId);

    return Scaffold(
        appBar: AppBar(
          title: Text(
              '${student == null ? 'En attente des informations' : 'Évaluation de ${student.fullName}'}\nC2. Attitudes - Comportements'),
          leading: IconButton(
              onPressed: _cancel, icon: const Icon(Icons.arrow_back)),
        ),
        body: student == null
            ? const Center(child: CircularProgressIndicator())
            : ScrollableStepper(
                scrollController: _scrollController,
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: _nextStep,
                onStepTapped: (int tapped) => setState(() {
                  _currentStep = tapped;
                  _scrollController.jumpTo(0);
                }),
                onStepCancel: _cancel,
                steps: [
                  Step(
                    label: const Text('Détails'),
                    title: Container(),
                    state: _stepStatus[0],
                    isActive: _currentStep == 0,
                    content: _AttitudeGeneralDetailsStep(
                        formController: widget.formController,
                        editMode: widget.editMode),
                  ),
                  Step(
                    label: const Text('Attitudes'),
                    title: Container(),
                    state: _stepStatus[1],
                    isActive: _currentStep == 1,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AttitudeRadioChoices(
                          title: '1. *${Inattendance.title}',
                          formController: widget.formController,
                          elements: Inattendance.values,
                          editMode: widget.editMode,
                        ),
                        _AttitudeRadioChoices(
                          title: '2. *${Ponctuality.title}',
                          formController: widget.formController,
                          elements: Ponctuality.values,
                          editMode: widget.editMode,
                        ),
                        _AttitudeRadioChoices(
                          title: '3. *${Sociability.title}',
                          formController: widget.formController,
                          elements: Sociability.values,
                          editMode: widget.editMode,
                        ),
                        _AttitudeRadioChoices(
                          title: '4. *${Politeness.title}',
                          formController: widget.formController,
                          elements: Politeness.values,
                          editMode: widget.editMode,
                        ),
                        _AttitudeRadioChoices(
                          title: '5. *${Motivation.title}',
                          formController: widget.formController,
                          elements: Motivation.values,
                          editMode: widget.editMode,
                        ),
                        _AttitudeRadioChoices(
                          title: '6. *${DressCode.title}',
                          formController: widget.formController,
                          elements: DressCode.values,
                          editMode: widget.editMode,
                        ),
                      ],
                    ),
                  ),
                  Step(
                      label: const Text('Aptitudes'),
                      title: Container(),
                      state: _stepStatus[2],
                      isActive: _currentStep == 2,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AttitudeRadioChoices(
                            title: '7. *${QualityOfWork.title}',
                            formController: widget.formController,
                            elements: QualityOfWork.values,
                            editMode: widget.editMode,
                          ),
                          _AttitudeRadioChoices(
                            title: '8. *${Productivity.title}',
                            formController: widget.formController,
                            elements: Productivity.values,
                            editMode: widget.editMode,
                          ),
                          _AttitudeRadioChoices(
                            title: '9. *${Autonomy.title}',
                            formController: widget.formController,
                            elements: Autonomy.values,
                            editMode: widget.editMode,
                          ),
                          _AttitudeRadioChoices(
                            title: '10. *${Cautiousness.title}',
                            formController: widget.formController,
                            elements: Cautiousness.values,
                            editMode: widget.editMode,
                          ),
                        ],
                      )),
                  Step(
                    label: const Text('Commentaires'),
                    title: Container(),
                    state: _stepStatus[3],
                    isActive: _currentStep == 3,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AttitudeRadioChoices(
                          title: '11. *${GeneralAppreciation.title}',
                          formController: widget.formController,
                          elements: GeneralAppreciation.values,
                          editMode: widget.editMode,
                        ),
                        _Comments(formController: widget.formController),
                      ],
                    ),
                  )
                ],
                controlsBuilder: _controlBuilder,
              ));
  }
}

class _AttitudeGeneralDetailsStep extends StatelessWidget {
  const _AttitudeGeneralDetailsStep({
    required this.formController,
    required this.editMode,
  });

  final AttitudeEvaluationFormController formController;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EvaluationDate(formController: formController, editMode: editMode),
        _PersonAtMeeting(formController: formController, editMode: editMode),
      ],
    );
  }
}

class _EvaluationDate extends StatefulWidget {
  const _EvaluationDate({required this.formController, required this.editMode});

  final AttitudeEvaluationFormController formController;
  final bool editMode;

  @override
  State<_EvaluationDate> createState() => _EvaluationDateState();
}

class _EvaluationDateState extends State<_EvaluationDate> {
  void _promptDate(context) async {
    final newDate = await showDatePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialDate: widget.formController.evaluationDate,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (newDate == null) return;

    widget.formController.evaluationDate = newDate;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Date de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(DateFormat('dd MMMM yyyy', 'fr_CA')
                  .format(widget.formController.evaluationDate)),
              if (widget.editMode)
                IconButton(
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () => _promptDate(context),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonAtMeeting extends StatelessWidget {
  const _PersonAtMeeting(
      {required this.formController, required this.editMode});

  final AttitudeEvaluationFormController formController;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Personnes présentes lors de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: CheckboxWithOther(
            key: formController.wereAtMeetingKey,
            elements: formController.wereAtMeetingOptions,
            initialValues: formController.wereAtMeeting,
            enabled: editMode,
          ),
        ),
      ],
    );
  }
}

class _AttitudeRadioChoices extends StatefulWidget {
  const _AttitudeRadioChoices(
      {required this.title,
      required this.formController,
      required this.elements,
      required this.editMode});

  final String title;
  final AttitudeEvaluationFormController formController;
  final List<AttitudeCategoryEnum> elements;
  final bool editMode;

  @override
  State<_AttitudeRadioChoices> createState() => _AttitudeRadioChoicesState();
}

class _AttitudeRadioChoicesState extends State<_AttitudeRadioChoices> {
  @override
  void initState() {
    super.initState();
    if (widget.editMode) {
      widget.formController.responses[widget.elements[0].runtimeType] = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(widget.title),
        ...widget.elements.map(
          (e) => RadioListTile<AttitudeCategoryEnum>(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(e.name,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                    )),
            value: e,
            groupValue: widget.formController.responses[e.runtimeType],
            onChanged: widget.editMode
                ? (newValue) => setState(() =>
                    widget.formController.responses[e.runtimeType] = newValue!)
                : null,
          ),
        ),
      ],
    );
  }
}

class _Comments extends StatelessWidget {
  const _Comments({required this.formController});

  final AttitudeEvaluationFormController formController;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: SubTitle('12. Autres commentaires'),
        ),
        TextFormField(
          controller: formController.commentsController,
          maxLines: null,
        ),
      ],
    );
  }
}
