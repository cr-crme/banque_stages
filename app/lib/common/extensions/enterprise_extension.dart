import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/job_extension.dart';
import 'package:flutter/widgets.dart';

extension EnterpriseExtension on Enterprise {
  List<Internship> internships(BuildContext context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)
          .mapRemoveNull<Internship>(
              (Internship e) => e.enterpriseId == id ? e : null)
          .toList();

  Iterable<Job> availablejobs(BuildContext context) {
    // Remove the jobs which are visible to certain users only
    final authProvider = AuthProvider.of(context, listen: false);
    final mySchoolId = authProvider.schoolId!;
    final myTeacherId = authProvider.teacherId!;
    return [...jobs]..removeWhere((job) =>
        job.reservedForId != null &&
        job.reservedForId != mySchoolId &&
        job.reservedForId != myTeacherId);
  }

  Iterable<Job> withRemainingPositions(context, {required String schoolId}) {
    return jobs.where((job) =>
        (job.positionsOffered[schoolId] ?? 0) - job.positionsOccupied(context) >
        0);
  }
}
