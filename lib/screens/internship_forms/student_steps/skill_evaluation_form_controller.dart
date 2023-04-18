import 'package:flutter/widgets.dart';

import '/common/models/internship.dart';
import '/common/models/internship_evaluation_skill.dart';
import '/common/providers/internships_provider.dart';
import '/misc/job_data_file_service.dart';

class SkillEvaluationFormController {
  SkillEvaluationFormController(context, {required this.internshipId});
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  DateTime evaluationDate = DateTime.now();

  Map<String, bool> wereAtMeeting = {
    'L\'enseignant\u2022e superviseur\u2022e': true,
    'La ou le stagiaire': false,
    'La ou le responsable dans le milieu de stage': false,
  };
  bool _withOtherAtMeeting = false;
  bool get withOtherAtMeeting => _withOtherAtMeeting;
  TextEditingController othersAtMeetingController = TextEditingController();
  set withOtherAtMeeting(bool value) {
    _withOtherAtMeeting = value;
    if (!value) othersAtMeetingController.text = '';
  }

  final Map<Skill, bool> skillsToEvaluate = {};
  final Map<Skill, String> skillsAreFromSpecializationId = {};
  Map<Skill, Map<String, bool>> taskCompleted = {};
  void prepareTaskCompleted() {
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

  Map<Skill, SkillAppreciation> appreciation = {};
  bool get allAppreciationsAreDone {
    for (final skill in appreciation.keys) {
      if (appreciation[skill] == SkillAppreciation.notEvaluated) return false;
    }
    return true;
  }

  void prepareAppreciation() {
    appreciation.clear();
    for (final skill in skillsToEvaluate.keys) {
      if (!skillsToEvaluate[skill]!) continue;
      appreciation[skill] = SkillAppreciation.notEvaluated;
    }
  }

  final commentsController = TextEditingController();
}
