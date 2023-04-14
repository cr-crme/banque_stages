import 'package:flutter/material.dart';

import '/common/models/internship.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/sub_title.dart';
import '/misc/job_data_file_service.dart';
import 'student_form_controller.dart';

class StudentEvaluationFormScreen extends StatefulWidget {
  const StudentEvaluationFormScreen({super.key, required this.formController});

  final StudentFormController formController;

  @override
  State<StudentEvaluationFormScreen> createState() =>
      _StudentEvaluationFormScreenState();
}

class _StudentEvaluationFormScreenState
    extends State<StudentEvaluationFormScreen> {
  int _currentStep = 0;

  SkillList _extractSkills(BuildContext context,
      {required Internship internship}) {
    final job = EnterprisesProvider.of(context)[internship.enterpriseId]
        .jobs[internship.jobId];
    return job.specialization.skills;
  }

  void _nextStep() {
    _currentStep++;
    setState(() {});
  }

  void _previousStep() {
    _currentStep--;
    setState(() {});
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(child: SizedBox()),
              if (_currentStep != 0)
                OutlinedButton(
                    onPressed: _previousStep, child: const Text('Précédent')),
              const SizedBox(width: 20),
              TextButton(
                onPressed: details.onStepContinue,
                child: const Text('Suivant'),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final internship = widget.formController.internship(context);
    final allStudents = StudentsProvider.of(context);
    if (!allStudents.hasId(internship.studentId)) return Container();
    final student = allStudents[internship.studentId];
    final skills = _extractSkills(context, internship: internship);

    return Scaffold(
      appBar: AppBar(
        title: Text('Évaluation de ${student.fullName}'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
        onStepCancel: () => Navigator.pop(context),
        steps: skills
            .map((skill) => Step(
                  isActive: _currentStep == 0,
                  title: SubTitle(skill.id, top: 0, bottom: 0),
                  content: _EvaluateSkill(
                    formController: widget.formController,
                    skill: skill,
                  ),
                ))
            .toList(),
        controlsBuilder: _controlBuilder,
      ),
    );
  }
}

class _EvaluateSkill extends StatelessWidget {
  const _EvaluateSkill({required this.formController, required this.skill});

  final StudentFormController formController;
  final Skill skill;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: spacing),
          child: Text(
            skill.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: spacing),
          child: Text(
            'Niveau de complexité : ${skill.complexity}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Critères de performance:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...skill.criteria
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '\u00b7 ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Flexible(child: Text(e)),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        _TaskEvaluation(
            spacing: spacing, skill: skill, formController: formController),
        _AppreciationEvaluation(
            spacing: spacing, skill: skill, formController: formController),
      ],
    );
  }
}

class _TaskEvaluation extends StatefulWidget {
  const _TaskEvaluation({
    required this.spacing,
    required this.skill,
    required this.formController,
  });

  final double spacing;
  final Skill skill;
  final StudentFormController formController;

  @override
  State<_TaskEvaluation> createState() => _TaskEvaluationState();
}

class _TaskEvaluationState extends State<_TaskEvaluation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'La ou le stagiaire a été en mesure d\'effectuer les '
            'tâches suivantes :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...widget.skill.tasks
              .map((e) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    onChanged: (value) => setState(() => widget.formController
                        .taskCompleted[widget.skill]![e] = value!),
                    value:
                        widget.formController.taskCompleted[widget.skill]![e]!,
                    title: Text(e),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class _AppreciationEvaluation extends StatefulWidget {
  const _AppreciationEvaluation({
    required this.spacing,
    required this.skill,
    required this.formController,
  });

  final double spacing;
  final Skill skill;
  final StudentFormController formController;

  @override
  State<_AppreciationEvaluation> createState() =>
      _AppreciationEvaluationState();
}

class _AppreciationEvaluationState extends State<_AppreciationEvaluation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Appréciation générale de la compétence :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...SkillAppreciation.values
              .map((e) => RadioListTile<SkillAppreciation>(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) => setState(() => widget
                        .formController.appreciation[widget.skill] = value!),
                    groupValue:
                        widget.formController.appreciation[widget.skill],
                    value: e,
                    title: Text(e.name),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
