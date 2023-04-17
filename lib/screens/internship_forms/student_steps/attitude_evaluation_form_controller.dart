import 'package:flutter/widgets.dart';

import '/common/models/internship.dart';
import '/common/providers/internships_provider.dart';

class AttitudeEvaluationFormController {
  AttitudeEvaluationFormController(context, {required this.internshipId});
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

  final commentsController = TextEditingController();
}
