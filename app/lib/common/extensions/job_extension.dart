import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common_flutter/providers/internships_provider.dart';

extension JobExtension on Job {
  int positionsOccupied(context, {bool listen = false}) =>
      InternshipsProvider.of(context, listen: listen)
          .where((e) => e.jobId == id && e.isActive)
          .length;

  int positionsRemaining(context,
          {required String schoolId, bool listen = false}) =>
      (positionsOffered[schoolId] ?? 0) -
      positionsOccupied(context, listen: listen);

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
