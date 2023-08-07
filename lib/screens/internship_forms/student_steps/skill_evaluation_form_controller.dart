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
  int? _previousEvaluationIndex; // -1 is the last, null is not from evaluation
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

  void dispose() {
    for (final skill in skillCommentsControllers.keys) {
      skillCommentsControllers[skill]!.dispose();
    }
    commentsController.dispose();
  }

  void addSkill(Skill skill) {
    _evaluatedSkills[skill] = 1;

    appreciations[skill] = SkillAppreciation.notEvaluated;
    skillCommentsControllers[skill] = TextEditingController();

    taskCompleted[skill] = {};
    for (final task in skill.tasks) {
      taskCompleted[skill]![task] = false;
    }
  }

  void removeSkill(context, Skill skill) {
    _evaluatedSkills[skill] = 0;
    if (_previousEvaluationIndex != null) {
      final evaluation = _previousEvaluation(context);
      if (evaluation!.skills.any((e) => e.skillName == skill.idWithName)) {
        _evaluatedSkills[skill] = -1;
      }
    }

    if (_evaluatedSkills[skill] == 0) {
      appreciations.remove(skill);
      skillCommentsControllers[skill]!.dispose();
      skillCommentsControllers.remove(skill);
      taskCompleted.remove(skill);
    }
  }

  void clearForm(context) {
    _resetForm(context);

    final internshipTp = internship(context, listen: false);
    final enterprise = EnterprisesProvider.of(context,
        listen: false)[internshipTp.enterpriseId];
    final specialization = enterprise.jobs[internshipTp.jobId].specialization;

    for (final skill in specialization.skills) {
      addSkill(skill);
    }
  }

  InternshipEvaluationSkill? _previousEvaluation(context) {
    if (_previousEvaluationIndex == null) return null;

    final internshipTp = internship(context, listen: false);
    if (internshipTp.skillEvaluations.isEmpty) return null;

    return _previousEvaluationIndex! < 0
        ? internshipTp.skillEvaluations.last
        : internshipTp.skillEvaluations[_previousEvaluationIndex!];
  }

  void fillFromPreviousEvaluation(context, int previousEvaluationIndex) {
    // Reset the form to fresh
    _resetForm(context);
    _previousEvaluationIndex = previousEvaluationIndex;

    final evaluation = _previousEvaluation(context);
    if (evaluation == null) return;

    if (!canModify) evaluationDate = evaluation.date;

    // Fill skill to evaluated as if it was all false
    wereAtMeeting.addAll(evaluation.presentAtEvaluation);

    // Now fill the structures from the evaluation
    for (final skillEvaluation in evaluation.skills) {
      final skill = _evaluatedSkills.keys.firstWhere(
          (element) => element.idWithName == skillEvaluation.skillName);

      addSkill(skill);
      // Set the actual values to add (but empty) skill
      appreciations[skill] = skillEvaluation.appreciation;
      skillCommentsControllers[skill]!.text = skillEvaluation.comment;

      for (final task in skill.tasks) {
        taskCompleted[skill]![task] = skillEvaluation.tasks.contains(task);
      }
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
        specializationId: _skillsAreFromSpecializationId[skill]!,
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

  ///
  /// _evaluatedSkill is set to 1 if it is evaluated, 0 or -1 if it is not
  /// evaluated. The negative value indicateds that it is not evaluated, but it
  /// should still be added to the results as it is a previous result from a
  /// previous evaluation
  final Map<Skill, int> _evaluatedSkills = {};
  bool isSkillToEvaluate(Skill skill) => (_evaluatedSkills[skill] ?? 0) > 0;
  bool isNotEvaluatedButWasPreviously(Skill skill) =>
      (_evaluatedSkills[skill] ?? 0) < 0;

  ///
  /// This returns the values for all results, if [activeOnly] is set to false
  /// then it also include the one from previous evaluation which are not
  /// currently evaluated
  List<Skill> skillResults({bool activeOnly = false}) {
    List<Skill> out = [];
    for (final skill in _evaluatedSkills.keys) {
      if (_evaluatedSkills[skill]! > 0) {
        out.add(skill);
      }
      // If the skill was not evaluated, but the evaluation continues a previous
      // one, we must keep the previous values
      if (!activeOnly && _evaluatedSkills[skill]! < 0) {
        out.add(skill);
      }
    }
    return out;
  }

  final Map<Skill, String> _skillsAreFromSpecializationId = {};

  void _initializeSkills(context) {
    final internshipTp = internship(context, listen: false);
    final enterprise = EnterprisesProvider.of(context,
        listen: false)[internshipTp.enterpriseId];

    final specialization = enterprise.jobs[internshipTp.jobId].specialization;
    for (final skill in specialization.skills) {
      _evaluatedSkills[skill] = 0;
      _skillsAreFromSpecializationId[skill] = specialization.id;
    }

    for (final extraSpecializationId in internshipTp.extraSpecializationsId) {
      for (final skill
          in ActivitySectorsService.specialization(extraSpecializationId)
              .skills) {
        _evaluatedSkills[skill] = 0;
        _skillsAreFromSpecializationId[skill] = extraSpecializationId;
      }
    }
  }

  Map<Skill, Map<String, bool>> taskCompleted = {};
  void _initializeTaskCompleted() {
    taskCompleted.clear();
    for (final skill in _evaluatedSkills.keys) {
      if (_evaluatedSkills[skill] == 0) continue;
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
      if (isSkillToEvaluate(skill) &&
          appreciations[skill] == SkillAppreciation.notEvaluated) return false;
    }
    return true;
  }

  void _initializeAppreciation() {
    appreciations.clear();
    for (final skill in _evaluatedSkills.keys) {
      if (_evaluatedSkills[skill] == 0) continue;
      appreciations[skill] = SkillAppreciation.notEvaluated;
    }
  }

  Map<Skill, TextEditingController> skillCommentsControllers = {};
  void _initializeSkillCommentControllers() {
    skillCommentsControllers.clear();
    for (final skill in _evaluatedSkills.keys) {
      if (_evaluatedSkills[skill] == 0) continue;
      skillCommentsControllers[skill] = TextEditingController();
    }
  }

  void _resetForm(context) {
    evaluationDate = DateTime.now();
    _previousEvaluationIndex = null;

    wereAtMeeting.clear();

    _initializeSkills(context);
    _initializeTaskCompleted();
    _initializeAppreciation();

    commentsController.text = '';
    _initializeSkillCommentControllers();
  }

  TextEditingController commentsController = TextEditingController();
}
