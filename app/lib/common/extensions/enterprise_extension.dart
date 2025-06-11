import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/job_extension.dart';

extension EnterpriseExtension on Enterprise {
  List<Internship> internships(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)
          .mapRemoveNull<Internship>(
              (Internship e) => e.enterpriseId == id ? e : null)
          .toList();

  Iterable<Job> availableJobs(context, {required String schoolId}) {
    return jobs.where((job) =>
        (job.positionsOffered[schoolId] ?? 0) - job.positionsOccupied(context) >
        0);
  }
}
