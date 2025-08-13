import 'package:stagess_common/models/internships/internship.dart';
import 'package:stagess_common/models/internships/internship_evaluation_visa.dart';
import 'package:stagess_common_flutter/providers/internships_provider.dart';

class VisaEvaluationFormController {
  static const _formVersion = '1.0.0';

  VisaEvaluationFormController({required this.internshipId});
  final String internshipId;
  Internship internship(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)[internshipId];

  factory VisaEvaluationFormController.fromInternshipId(
    context, {
    required String internshipId,
    required int evaluationIndex,
  }) {
    Internship internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    InternshipEvaluationVisa evaluation =
        internship.visaEvaluations[evaluationIndex];

    final controller = VisaEvaluationFormController(internshipId: internshipId);

    controller.evaluationDate = evaluation.date;

    controller.responses[Inattendance] = evaluation.attitude.inattendance;
    controller.responses[Ponctuality] = evaluation.attitude.ponctuality;
    controller.responses[Sociability] = evaluation.attitude.sociability;
    controller.responses[Politeness] = evaluation.attitude.politeness;
    controller.responses[Motivation] = evaluation.attitude.motivation;
    controller.responses[DressCode] = evaluation.attitude.dressCode;
    controller.responses[QualityOfWork] = evaluation.attitude.qualityOfWork;
    controller.responses[Productivity] = evaluation.attitude.productivity;
    controller.responses[Autonomy] = evaluation.attitude.autonomy;
    controller.responses[Cautiousness] = evaluation.attitude.cautiousness;
    controller.responses[GeneralAppreciation] =
        evaluation.attitude.generalAppreciation;

    return controller;
  }

  InternshipEvaluationVisa toInternshipEvaluation() {
    return InternshipEvaluationVisa(
      date: evaluationDate,
      attitude: VisaEvaluation(
          inattendance: responses[Inattendance]! as Inattendance,
          ponctuality: responses[Ponctuality]! as Ponctuality,
          sociability: responses[Sociability]! as Sociability,
          politeness: responses[Politeness]! as Politeness,
          motivation: responses[Motivation]! as Motivation,
          dressCode: responses[DressCode]! as DressCode,
          qualityOfWork: responses[QualityOfWork]! as QualityOfWork,
          productivity: responses[Productivity]! as Productivity,
          autonomy: responses[Autonomy]! as Autonomy,
          cautiousness: responses[Cautiousness]! as Cautiousness,
          generalAppreciation:
              responses[GeneralAppreciation]! as GeneralAppreciation),
      formVersion: _formVersion,
    );
  }

  DateTime evaluationDate = DateTime.now();
  Map<Type, VisaCategoryEnum?> responses = {};

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
