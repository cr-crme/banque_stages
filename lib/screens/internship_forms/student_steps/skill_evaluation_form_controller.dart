import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_skill.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/widgets.dart';

class SkillEvaluationFormController {
  static const _formVersion = '1.0.0';

  SkillEvaluationFormController({required this.internshipId});
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  factory SkillEvaluationFormController.fromInternshipId(
    context, {
    required String internshipId,
    required int evaluationIndex,
  }) {
    Internship internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    InternshipEvaluationSkill evaluation =
        internship.skillEvaluations[evaluationIndex];

    final controller =
        SkillEvaluationFormController(internshipId: internshipId);

    controller.evaluationDate = evaluation.date;

    controller.wereAtMeetingInitialValues.clear();
    controller.wereAtMeetingInitialValues
        .addAll(evaluation.presentAtEvaluation);

    // Fill skill to evaluated as if it was none
    final enterprise =
        EnterprisesProvider.of(context, listen: false)[internship.enterpriseId];
    final specialization = enterprise.jobs[internship.jobId].specialization;
    for (final skill in specialization.skills) {
      controller.skillsToEvaluate[skill] = false;
    }
    for (final extraSpecializationId in internship.extraSpecializationsId) {
      for (final skill
          in ActivitySectorsService.specialization(extraSpecializationId)
              .skills) {
        controller.skillsToEvaluate[skill] = false;
        controller.skillsAreFromSpecializationId[skill] = extraSpecializationId;
      }
    }

    // Now fill the structures
    for (final skillEvaluation in evaluation.skills) {
      final skill = controller.skillsToEvaluate.keys.firstWhere(
          (element) => element.idWithName == skillEvaluation.skillName);
      controller.skillsToEvaluate[skill] = true;

      controller.taskCompleted[skill] = {};
      for (final task in skill.tasks) {
        controller.taskCompleted[skill]![task] =
            skillEvaluation.tasks.contains(task);
      }

      controller.appreciations[skill] = skillEvaluation.appreciation;
      controller.skillCommentsControllers[skill] =
          TextEditingController(text: skillEvaluation.comment);
    }

    controller.commentsController.text = evaluation.comments;

    return controller;
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
  final List<String> wereAtMeetingInitialValues = [];
  List<String> get wereAtMeeting => wereAtMeetingKey.currentState!.values;

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

  ///
  /// This properly initialize the controller
  void initializeController() {
    _initializeTaskCompleted();
    _initializeAppreciation();
    _initializeSkillCommentControllers();
  }

  TextEditingController commentsController = TextEditingController();
}
