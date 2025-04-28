import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';

extension JobExtension on Job {
  int positionsOccupied(context) =>
      InternshipsProvider.of(context, listen: false)
          .where((e) => e.jobId == id && e.isActive)
          .length;

  int positionsRemaining(context) =>
      positionsOffered - positionsOccupied(context);

  // Post-internship evaluations
  List<PostInternshipEnterpriseEvaluation> postInternshipEnterpriseEvaluations(
      context) {
    final internships = [
      for (final internship in InternshipsProvider.of(context, listen: false))
        if (internship.jobId == id) internship
    ];
    return [
      for (final evaluation in internships.map((e) => e.enterpriseEvaluation))
        if (evaluation != null) evaluation
    ];
  }
}
