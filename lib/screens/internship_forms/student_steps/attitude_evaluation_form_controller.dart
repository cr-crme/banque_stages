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

  Map<Type, AttitudeCategoryEnum?> responses = {};

  final commentsController = TextEditingController();
}

abstract class AttitudeCategoryEnum {
  String get name;
  int get index;
}

class Inattendance implements AttitudeCategoryEnum {
  static String get title => 'Assiduité';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Aucune absence';
      case 1:
        return 'S\'absente rarement et avise';
      case 2:
        return 'Quelques absences injustifiées';
      case 3:
        return 'Absences fréquentes et injustifiées';
      default:
        throw 'Wrong choice of inattendance';
    }
  }

  const Inattendance._(this.index);
  static Inattendance get never => const Inattendance._(0);
  static Inattendance get rarely => const Inattendance._(1);
  static Inattendance get sometime => const Inattendance._(2);
  static Inattendance get frequently => const Inattendance._(3);

  static List<Inattendance> get values => [
        Inattendance.never,
        Inattendance.rarely,
        Inattendance.sometime,
        Inattendance.frequently,
      ];
}

class Ponctuality implements AttitudeCategoryEnum {
  static String get title => 'Ponctualité';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Toujours à l\'heure';
      case 1:
        return 'Quelques retards justifiés';
      case 2:
        return 'Quelques retards injustifiées';
      case 3:
        return 'Retards fréquentes et injustifiées';
      default:
        throw 'Wrong choice of ponctuality';
    }
  }

  const Ponctuality._(this.index);
  static Ponctuality get highly => const Ponctuality._(0);
  static Ponctuality get mostly => const Ponctuality._(1);
  static Ponctuality get sometimeLate => const Ponctuality._(2);
  static Ponctuality get frequentlyLate => const Ponctuality._(3);

  static List<Ponctuality> get values => [
        Ponctuality.highly,
        Ponctuality.mostly,
        Ponctuality.sometimeLate,
        Ponctuality.frequentlyLate,
      ];
}
