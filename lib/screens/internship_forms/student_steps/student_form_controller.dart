import 'package:flutter/widgets.dart';

class StudentFormController {
  DateTime evaluationDate = DateTime.now();

  Map<String, bool> wereAtMeeting = {
    'La ou le stagiaire': true,
    'L\'enseignant\u2022e responsable': true,
    'La ou le responsable dans le milieu de stage': false,
  };
  bool _withOtherAtMeeting = false;
  bool get withOtherAtMeeting => _withOtherAtMeeting;
  set withOtherAtMeeting(bool value) {
    _withOtherAtMeeting = value;
    if (!value) othersAtMeetingController.text = '';
  }

  TextEditingController othersAtMeetingController = TextEditingController();
}
