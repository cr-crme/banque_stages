import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_skill.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/widgets.dart';

class SkillEvaluationFormController {
  static const _formVersion = '1.0.0';

  SkillEvaluationFormController(BuildContext context,
      {required this.internshipId, required this.canModify}) {
    clearForm(context);
  }
  final bool canModify;
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  factory SkillEvaluationFormController.fromInternshipId(context,
      {required String internshipId,
      required int evaluationIndex,
      required bool canModify}) {
    final controller = SkillEvaluationFormController(context,
        internshipId: internshipId, canModify: canModify);
    controller.fillFromPreviousEvaluation(context, evaluationIndex);
    return controller;
  }

  void clearForm(context) {
    wereAtMeeting.clear();
    _reinitialize(context);
    commentsController.text = '';
  }

  void fillFromPreviousEvaluation(context, int? previousEvaluationIndex) {
    final internshipTp = internship(context, listen: false);
    if (internshipTp.skillEvaluations.isEmpty) return;

    final evaluation = previousEvaluationIndex == null
        ? internshipTp.skillEvaluations.last
        : internshipTp.skillEvaluations[previousEvaluationIndex];

    if (!canModify) evaluationDate = evaluation.date;

    wereAtMeeting.clear();
    wereAtMeeting.addAll(evaluation.presentAtEvaluation);

    // Fill skill to evaluated as if it was all false
    _reinitialize(context, forceFalse: true);

    // Now fill the structures from the evaluation
    for (final skillEvaluation in evaluation.skills) {
      final skill = skillsToEvaluate.keys.firstWhere(
          (element) => element.idWithName == skillEvaluation.skillName);
      skillsToEvaluate[skill] = true;

      taskCompleted[skill] = {};
      for (final task in skill.tasks) {
        taskCompleted[skill]![task] = skillEvaluation.tasks.contains(task);
      }

      appreciations[skill] = skillEvaluation.appreciation;
      skillCommentsControllers[skill] =
          TextEditingController(text: skillEvaluation.comment);
    }

    commentsController.text = evaluation.comments;
  }

  InternshipEvaluationSkill toInternshipEvaluation() {
    final List<SkillEvaluation> skillEvaluation = [];
    for (final skill in taskCompleted.keys) {
      final List<String> tasks = [];
      for (final task in taskCompleted[skill]!.keys) {
        if (taskCompleted[skill]![task]!) {
          tasks.add(task);
        }
      }

      skillEvaluation.add(SkillEvaluation(
        specializationId: skillsAreFromSpecializationId[skill]!,
        skillName: skill.idWithName,
        tasks: tasks,
        appreciation: appreciations[skill]!,
        comment: skillCommentsControllers[skill]!.text,
      ));
    }
    return InternshipEvaluationSkill(
      date: evaluationDate,
      presentAtEvaluation: wereAtMeeting,
      skills: skillEvaluation,
      comments: commentsController.text,
      formVersion: _formVersion,
    );
  }

  DateTime evaluationDate = DateTime.now();

  final wereAtMeetingKey = GlobalKey<CheckboxWithOtherState<String>>();
  final List<String> wereAtMeetingOptions = [
    'Stagiaire',
    'Responsable en milieu de stage',
  ];
  final List<String> wereAtMeeting = [];
  void setWereAtMeeting() {
    wereAtMeeting.clear();
    wereAtMeeting.addAll(wereAtMeetingKey.currentState!.values);
  }

  Map<Skill, bool> skillsToEvaluate = {};
  final Map<Skill, String> skillsAreFromSpecializationId = {};

  Map<Skill, Map<String, bool>> taskCompleted = {};
  void _initializeTaskCompleted() {
    taskCompleted.clear();
    for (final skill in skillsToEvaluate.keys) {
      if (!skillsToEvaluate[skill]!) continue;
      Map<String, bool> tp = {};
      for (final task in skill.tasks) {
        tp[task] = false;
      }
      taskCompleted[skill] = tp;
    }
  }

  Map<Skill, SkillAppreciation> appreciations = {};
  bool get allAppreciationsAreDone {
    for (final skill in appreciations.keys) {
      if (appreciations[skill] == SkillAppreciation.notEvaluated) return false;
    }
    return true;
  }

  void _initializeAppreciation() {
    appreciations.clear();
    for (final skill in skillsToEvaluate.keys) {
      if (!skillsToEvaluate[skill]!) continue;
      appreciations[skill] = SkillAppreciation.notEvaluated;
    }
  }

  Map<Skill, TextEditingController> skillCommentsControllers = {};
  void _initializeSkillCommentControllers() {
    skillCommentsControllers.clear();
    for (final skill in skillsToEvaluate.keys) {
      if (!skillsToEvaluate[skill]!) continue;
      skillCommentsControllers[skill] = TextEditingController();
    }
  }

  void _reinitialize(context, {bool forceFalse = false}) {
    final internshipTp = internship(context, listen: false);
    final enterprise = EnterprisesProvider.of(context,
        listen: false)[internshipTp.enterpriseId];

    // Do the extra first as they should be overriden by the principal when they duplicate
    for (final extraSpecializationId in internshipTp.extraSpecializationsId) {
      for (final skill
          in ActivitySectorsService.specialization(extraSpecializationId)
              .skills) {
        skillsToEvaluate[skill] = false;
        skillsAreFromSpecializationId[skill] = extraSpecializationId;
      }
    }

    final specialization = enterprise.jobs[internshipTp.jobId].specialization;
    for (final skill in specialization.skills) {
      skillsToEvaluate[skill] = !forceFalse;
      skillsAreFromSpecializationId[skill] = specialization.id;
    }

    _initializeTaskCompleted();
    _initializeAppreciation();
    _initializeSkillCommentControllers();
  }

  TextEditingController commentsController = TextEditingController();
}
