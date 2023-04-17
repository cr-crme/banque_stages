import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/sub_title.dart';
import '/misc/job_data_file_service.dart';
import '/router.dart';
import 'student_form_controller.dart';

class StudentEvaluationMainScreen extends StatefulWidget {
  const StudentEvaluationMainScreen({super.key, required this.internshipId});

  final String internshipId;

  @override
  State<StudentEvaluationMainScreen> createState() =>
      _StudentEvaluationMainScreenState();
}

class _StudentEvaluationMainScreenState
    extends State<StudentEvaluationMainScreen> {
  late final _formController =
      StudentFormController(context, internshipId: widget.internshipId);

  @override
  Widget build(BuildContext context) {
    final internship = InternshipsProvider.of(context)[widget.internshipId];
    final allStudents = StudentsProvider.of(context);
    if (!allStudents.hasId(internship.studentId)) return Container();
    final student = allStudents[internship.studentId];

    return Scaffold(
      appBar: AppBar(
        title: Text('Évaluation de ${student.fullName}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EvaluationDate(formController: _formController),
            _PersonAtMeeting(formController: _formController),
            _JobToEvaluate(formController: _formController),
            _StartEvaluation(formController: _formController),
          ],
        ),
      ),
    );
  }
}

class _EvaluationDate extends StatefulWidget {
  const _EvaluationDate({required this.formController});

  final StudentFormController formController;
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
      initialEntryMode: DatePickerEntryMode.input,
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

class _PersonAtMeeting extends StatefulWidget {
  const _PersonAtMeeting({required this.formController});

  final StudentFormController formController;
  @override
  State<_PersonAtMeeting> createState() => _PersonAtMeetingState();
}

class _PersonAtMeetingState extends State<_PersonAtMeeting> {
  Widget _buildCheckTile(
      {required String title,
      required bool value,
      required Function(bool?) onChanged}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 4,
      child: CheckboxListTile(
        visualDensity: VisualDensity.compact,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Personnes présentes lors de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.formController.wereAtMeeting.keys
                  .map((person) => _buildCheckTile(
                      title: person,
                      value: widget.formController.wereAtMeeting[person]!,
                      onChanged: (newValue) => setState(() => widget
                          .formController.wereAtMeeting[person] = newValue!)))
                  .toList(),
              _buildCheckTile(
                  title: 'Autre',
                  value: widget.formController.withOtherAtMeeting,
                  onChanged: (newValue) => setState(() =>
                      widget.formController.withOtherAtMeeting = newValue!)),
              Visibility(
                visible: widget.formController.withOtherAtMeeting,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Précisez : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextFormField(
                        controller:
                            widget.formController.othersAtMeetingController,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobToEvaluate extends StatefulWidget {
  const _JobToEvaluate({required this.formController});

  final StudentFormController formController;

  @override
  State<_JobToEvaluate> createState() => _JobToEvaluateState();
}

class _JobToEvaluateState extends State<_JobToEvaluate> {
  late Specialization _specialization;
  late List<Specialization> _extraSpecialization;

  @override
  void initState() {
    super.initState();

    final internship = widget.formController.internship(context, listen: false);
    final enterprise =
        EnterprisesProvider.of(context, listen: false)[internship.enterpriseId];
    _specialization = enterprise.jobs[internship.jobId].specialization;
    _extraSpecialization = internship.extraSpecializationsId
        .map((specializationId) =>
            ActivitySectorsService.specialization(specializationId))
        .toList();

    for (final skill in _specialization.skills) {
      widget.formController.skillsToEvaluate[skill] = true;
    }
    for (final specialization in _extraSpecialization) {
      for (final skill in specialization.skills) {
        widget.formController.skillsToEvaluate[skill] = true;
      }
    }
  }

  Widget _buildJobTile({required String title, required SkillList skills}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_specialization.idWithName),
              const SizedBox(height: 4),
              const Text(
                '* Compétences à évaluer :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...skills.map((skill) => CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) => setState(() =>
                        widget.formController.skillsToEvaluate[skill] = value!),
                    value: widget.formController.skillsToEvaluate[skill],
                    title: Text(skill.idWithName),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // If there is only one job, evaluate all skills
    if (_extraSpecialization.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubTitle('Métier évalué'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_specialization.idWithName),
          ),
        ],
      );
    }

    // If there is more than one job, the user must select which skills are evaluated
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJobTile(
            title: 'Métier principal', skills: _specialization.skills),
        ..._extraSpecialization.asMap().keys.map((i) => _buildJobTile(
            title:
                'Métier secondaire${_extraSpecialization.length > 1 ? ' (${i + 1})' : ''}',
            skills: _extraSpecialization[i].skills)),
      ],
    );
  }
}

class _StartEvaluation extends StatelessWidget {
  const _StartEvaluation({required this.formController});

  final StudentFormController formController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, right: 24.0),
        child: TextButton(
            onPressed: () {
              formController.prepareTaskCompleted();
              formController.prepareAppreciation();
              GoRouter.of(context).pushReplacementNamed(
                  Screens.studentEvaluationFormScreen,
                  extra: formController);
            },
            child: const Text('Commencer l\'évaluation')),
      ),
    );
  }
}
