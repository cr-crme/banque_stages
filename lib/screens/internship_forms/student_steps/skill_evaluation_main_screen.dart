import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'skill_evaluation_form_controller.dart';

class SkillEvaluationMainScreen extends StatefulWidget {
  const SkillEvaluationMainScreen(
      {super.key, required this.internshipId, required this.editMode});

  final String internshipId;
  final bool editMode;

  @override
  State<SkillEvaluationMainScreen> createState() =>
      _SkillEvaluationMainScreenState();
}

class _SkillEvaluationMainScreenState extends State<SkillEvaluationMainScreen> {
  late final _formController = SkillEvaluationFormController(context,
      internshipId: widget.internshipId, canModify: true);
  late int _currentEvaluationIndex = _formController
          .internship(context, listen: false)
          .skillEvaluations
          .length -
      1;

  @override
  void initState() {
    super.initState();

    if (_currentEvaluationIndex >= 0) {
      _formController.fillFromPreviousEvaluation(
          context, _currentEvaluationIndex);
    }
  }

  void _cancel() async {
    final answer = await ConfirmExitDialog.show(context,
        message: 'Toutes les modifications seront perdues.',
        isEditing: widget.editMode);
    if (!mounted || !answer) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final internship = InternshipsProvider.of(context)[widget.internshipId];

    return FutureBuilder<Student?>(
        future: StudentsProvider.fromLimitedId(context,
            studentId: internship.studentId),
        builder: (context, snapshot) {
          final student = snapshot.hasData ? snapshot.data : null;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                  '${student == null ? 'En attente des informations' : 'Évaluation de ${student.fullName}'}\nC1. Compétences spécifiques'),
              leading: IconButton(
                  onPressed: _cancel, icon: const Icon(Icons.arrow_back)),
            ),
            body: student == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Builder(builder: (context) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EvaluationDate(
                            formController: _formController,
                            editMode: widget.editMode,
                          ),
                          _PersonAtMeeting(
                            formController: _formController,
                            editMode: widget.editMode,
                          ),
                          _buildAutofillChooser(),
                          _JobToEvaluate(
                            formController: _formController,
                            editMode: widget.editMode,
                          ),
                          _StartEvaluation(
                            formController: _formController,
                            editMode: widget.editMode,
                          ),
                        ],
                      );
                    }),
                  ),
          );
        });
  }

  Widget _buildAutofillChooser() {
    final evaluations =
        _formController.internship(context, listen: false).skillEvaluations;

    return evaluations.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubTitle('Options de remplissage'),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Row(
                  children: [
                    const Text(
                      'Préremplir avec les résultats de\u00a0: ',
                    ),
                    DropdownButton<int?>(
                      value: _currentEvaluationIndex,
                      onChanged: (value) {
                        _currentEvaluationIndex = value!;
                        _currentEvaluationIndex >= evaluations.length
                            ? _formController.clearForm(context)
                            : _formController.fillFromPreviousEvaluation(
                                context, _currentEvaluationIndex);
                        setState(() {});
                      },
                      items: evaluations
                          .asMap()
                          .keys
                          .map((index) => DropdownMenuItem(
                              value: index,
                              child: Text(DateFormat('dd MMMM yyyy', 'fr_CA')
                                  .format(evaluations[index].date))))
                          .toList()
                        ..add(DropdownMenuItem(
                            value: evaluations.length,
                            child: const Text('Vide'))),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class _EvaluationDate extends StatefulWidget {
  const _EvaluationDate({required this.formController, required this.editMode});

  final SkillEvaluationFormController formController;
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

  final SkillEvaluationFormController formController;
  final bool editMode;

  @override
  Widget build(context) {
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

class _JobToEvaluate extends StatefulWidget {
  const _JobToEvaluate({required this.formController, required this.editMode});

  final SkillEvaluationFormController formController;
  final bool editMode;

  @override
  State<_JobToEvaluate> createState() => _JobToEvaluateState();
}

class _JobToEvaluateState extends State<_JobToEvaluate> {
  // Duplicate skills deals with common skills in different jobs. Only allows for
  // modification of the first occurence (and tie them)
  final Map<Skill, bool> _usedDuplicateSkills = {};

  Specialization get specialization {
    final internship = widget.formController.internship(context, listen: false);
    final enterprise =
        EnterprisesProvider.of(context, listen: false)[internship.enterpriseId];
    return enterprise.jobs[internship.jobId].specialization;
  }

  List<Specialization> get extraSpecializations {
    final internship = widget.formController.internship(context, listen: false);
    return internship.extraSpecializationsId
        .map((specializationId) =>
            ActivitySectorsService.specialization(specializationId))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    for (final extra in extraSpecializations) {
      for (final skill in extra.skills) {
        if (widget.formController.isSkillToEvaluate(skill)) {
          _usedDuplicateSkills[skill] = false;
        }
      }
    }
  }

  Widget _buildJobTile({
    required String title,
    required Specialization specialization,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(title),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                specialization.idWithName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '* Compétences à évaluer :',
              ),
              ...specialization.skills.map((skill) {
                final out = CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) {
                    if (value!) {
                      widget.formController.addSkill(skill);
                    } else {
                      widget.formController.removeSkill(skill);
                    }
                    setState(() {});
                  },
                  value: widget.formController.isSkillToEvaluate(skill),
                  title: Text(
                    skill.idWithName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  enabled: widget.editMode &&
                      (!_usedDuplicateSkills.containsKey(skill) ||
                          !_usedDuplicateSkills[skill]!),
                );
                if (_usedDuplicateSkills.containsKey(skill)) {
                  _usedDuplicateSkills[skill] = true;
                }
                return out;
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reset the duplacte skill flag
    for (final skill in _usedDuplicateSkills.keys) {
      _usedDuplicateSkills[skill] = false;
    }
    final extra = extraSpecializations;

    // If there is more than one job, the user must select which skills are evaluated
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJobTile(
          title: 'Métier principal',
          specialization: specialization,
        ),
        ...extra.asMap().keys.map(
              (i) => _buildJobTile(
                title:
                    'Métier supplémentaire${extra.length > 1 ? ' (${i + 1})' : ''}',
                specialization: extra[i],
              ),
            ),
      ],
    );
  }
}

class _StartEvaluation extends StatelessWidget {
  const _StartEvaluation(
      {required this.formController, required this.editMode});

  final SkillEvaluationFormController formController;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, right: 24.0),
        child: TextButton(
            onPressed: () {
              formController.setWereAtMeeting();
              GoRouter.of(context).pushReplacementNamed(
                Screens.skillEvaluationFormScreen,
                queryParams:
                    Screens.queryParams(editMode: editMode ? '1' : '0'),
                extra: formController,
              );
            },
            child: const Text('Commencer l\'évaluation')),
      ),
    );
  }
}
