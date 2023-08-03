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
  late final _formController =
      SkillEvaluationFormController(internshipId: widget.internshipId);

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
            initialValues: formController.wereAtMeetingInitialValues,
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
  late Specialization _specialization;
  late List<Specialization> _extraSpecialization;

  // Duplicate skills deals with common skills in different jobs. Only allows for
  // modification of the first occurence (and tie them)
  final Map<Skill, bool> _usedDuplicateSkills = {};

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
      widget.formController.skillsAreFromSpecializationId[skill] =
          _specialization.id;
      widget.formController.skillsToEvaluate[skill] = true;
    }
    for (final specialization in _extraSpecialization) {
      for (final skill in specialization.skills) {
        if (!widget.formController.skillsAreFromSpecializationId
            .containsKey(skill)) {
          widget.formController.skillsAreFromSpecializationId[skill] =
              specialization.id;
        }
        if (widget.formController.skillsToEvaluate.containsKey(skill)) {
          _usedDuplicateSkills[skill] = false;
        } else {
          widget.formController.skillsToEvaluate[skill] = false;
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
                  onChanged: (value) => setState(() =>
                      widget.formController.skillsToEvaluate[skill] = value!),
                  value: widget.formController.skillsToEvaluate[skill],
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

    // If there is more than one job, the user must select which skills are evaluated
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJobTile(
          title: 'Métier principal',
          specialization: _specialization,
        ),
        ..._extraSpecialization.asMap().keys.map(
              (i) => _buildJobTile(
                title:
                    'Métier supplémentaire${_extraSpecialization.length > 1 ? ' (${i + 1})' : ''}',
                specialization: _extraSpecialization[i],
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
              formController.initializeController();
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
