import 'package:flutter/widgets.dart';

import '/common/models/internship.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/misc/job_data_file_service.dart';

enum SkillAppreciation {
  acquired,
  toPursuit,
  failed,
  notEvaluated,
}

extension SkillAppreciationNamed on SkillAppreciation {
  String get name {
    switch (this) {
      case SkillAppreciation.acquired:
        return 'Acquise';
      case SkillAppreciation.toPursuit:
        return 'À poursuivre';
      case SkillAppreciation.failed:
        return 'Échouée';
      case SkillAppreciation.notEvaluated:
        return 'Non évaluée';
    }
  }
}

class StudentFormController {
  StudentFormController(context, {required this.internshipId})
      : taskCompleted = _prepareTaskCompleted(context, internshipId),
        appreciation = _prepareAppreciation(context, internshipId);
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  DateTime evaluationDate = DateTime.now();

  Map<String, bool> wereAtMeeting = {
    'La ou le stagiaire': true,
    'L\'enseignant\u2022e responsable': true,
    'La ou le responsable dans le milieu de stage': false,
  };
  bool _withOtherAtMeeting = false;
  bool get withOtherAtMeeting => _withOtherAtMeeting;
  TextEditingController othersAtMeetingController = TextEditingController();
  set withOtherAtMeeting(bool value) {
    _withOtherAtMeeting = value;
    if (!value) othersAtMeetingController.text = '';
  }

  Map<Skill, Map<String, bool>> taskCompleted;
  static Map<Skill, Map<String, bool>> _prepareTaskCompleted(
      context, String internshipId) {
    final internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    final skills =
        EnterprisesProvider.of(context, listen: false)[internship.enterpriseId]
            .jobs[internship.jobId]
            .specialization
            .skills;

    Map<Skill, Map<String, bool>> out = {};
    for (final skill in skills) {
      Map<String, bool> tp = {};
      for (final task in skill.tasks) {
        tp[task] = false;
      }
      out[skill] = tp;
    }
    return out;
  }

  Map<Skill, SkillAppreciation> appreciation;
  bool get allAppreciationsAreDone {
    for (final skill in appreciation.keys) {
      if (appreciation[skill] == SkillAppreciation.notEvaluated) return false;
    }
    return true;
  }

  static Map<Skill, SkillAppreciation> _prepareAppreciation(
      context, String internshipId) {
    final internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    final skills =
        EnterprisesProvider.of(context, listen: false)[internship.enterpriseId]
            .jobs[internship.jobId]
            .specialization
            .skills;

    Map<Skill, SkillAppreciation> out = {};
    for (final skill in skills) {
      out[skill] = SkillAppreciation.notEvaluated;
    }
    return out;
  }

  final commentsController = TextEditingController();
}
