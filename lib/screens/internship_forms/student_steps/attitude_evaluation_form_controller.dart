import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_attitude.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:flutter/widgets.dart';

class AttitudeEvaluationFormController {
  static const _formVersion = '1.0.0';

  AttitudeEvaluationFormController({required this.internshipId});
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  factory AttitudeEvaluationFormController.fromInternshipId(
    context, {
    required String internshipId,
    required int evaluationIndex,
  }) {
    Internship internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    InternshipEvaluationAttitude evaluation =
        internship.attitudeEvaluations[evaluationIndex];

    final controller =
        AttitudeEvaluationFormController(internshipId: internshipId);

    controller.evaluationDate = evaluation.date;

    controller.wereAtMeeting.clear();
    controller.wereAtMeeting.addAll(evaluation.presentAtEvaluation);

    controller.responses[Inattendance] =
        Inattendance.values[evaluation.attitude.inattendance];
    controller.responses[Ponctuality] =
        Ponctuality.values[evaluation.attitude.ponctuality];
    controller.responses[Sociability] =
        Sociability.values[evaluation.attitude.sociability];
    controller.responses[Politeness] =
        Politeness.values[evaluation.attitude.politeness];
    controller.responses[Motivation] =
        Motivation.values[evaluation.attitude.motivation];
    controller.responses[DressCode] =
        DressCode.values[evaluation.attitude.dressCode];
    controller.responses[QualityOfWork] =
        QualityOfWork.values[evaluation.attitude.qualityOfWork];
    controller.responses[Productivity] =
        Productivity.values[evaluation.attitude.productivity];
    controller.responses[Autonomy] =
        Autonomy.values[evaluation.attitude.autonomy];
    controller.responses[Cautiousness] =
        Cautiousness.values[evaluation.attitude.cautiousness];
    controller.responses[GeneralAppreciation] =
        GeneralAppreciation.values[evaluation.attitude.generalAppreciation];

    controller.commentsController.text = evaluation.comments;

    return controller;
  }

  InternshipEvaluationAttitude toInternshipEvaluation() {
    return InternshipEvaluationAttitude(
      date: DateTime.now(),
      presentAtEvaluation: wereAtMeeting,
      attitude: AttitudeEvaluation(
          inattendance: responses[Inattendance]!.index,
          ponctuality: responses[Ponctuality]!.index,
          sociability: responses[Sociability]!.index,
          politeness: responses[Politeness]!.index,
          motivation: responses[Motivation]!.index,
          dressCode: responses[DressCode]!.index,
          qualityOfWork: responses[QualityOfWork]!.index,
          productivity: responses[Productivity]!.index,
          autonomy: responses[Autonomy]!.index,
          cautiousness: responses[Cautiousness]!.index,
          generalAppreciation: responses[GeneralAppreciation]!.index),
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

  Map<Type, AttitudeCategoryEnum?> responses = {};

  final commentsController = TextEditingController();

  bool get isAttitudeCompleted =>
      responses[Inattendance] != null &&
      responses[Ponctuality] != null &&
      responses[Sociability] != null &&
      responses[Politeness] != null &&
      responses[Motivation] != null &&
      responses[DressCode] != null;

  bool get isSkillCompleted =>
      responses[QualityOfWork] != null &&
      responses[Productivity] != null &&
      responses[Autonomy] != null &&
      responses[Cautiousness] != null;

  bool get isGeneralAppreciationCompleted =>
      responses[GeneralAppreciation] != null;

  bool get isCompleted =>
      isAttitudeCompleted && isSkillCompleted && isGeneralAppreciationCompleted;
}
