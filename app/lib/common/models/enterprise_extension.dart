import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:crcrme_banque_stages/common/models/job_extension.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';

extension EnterpriseExtension on Enterprise {
  List<Internship> internships(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)
          .mapRemoveNull<Internship>(
              (Internship e) => e.enterpriseId == id ? e : null)
          .toList();

  Iterable<Job> availableJobs(context) {
    return jobs.where(
        (job) => job.positionsOffered - job.positionsOccupied(context) > 0);
  }
}
