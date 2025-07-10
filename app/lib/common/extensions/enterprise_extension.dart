import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/job_extension.dart';
import 'package:flutter/widgets.dart';

extension EnterprisesProviderExtension on EnterprisesProvider {
  static List<Enterprise> availableEnterprisesOf(BuildContext context,
      {bool listen = true}) {
    final authProvider = AuthProvider.of(context, listen: false);
    final mySchoolId = authProvider.schoolId;
    final myTeacherId = authProvider.teacherId;
    if (mySchoolId == null || myTeacherId == null) {
      return [];
    }

    return [...EnterprisesProvider.of(context, listen: listen)]..removeWhere(
        (enterprise) =>
            enterprise.reservedForId.isNotEmpty &&
            enterprise.reservedForId != mySchoolId &&
            enterprise.reservedForId != myTeacherId);
  }
}

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
        job.reservedForId.isNotEmpty &&
        job.reservedForId != mySchoolId &&
        job.reservedForId != myTeacherId);
  }

  Iterable<Job> withRemainingPositions(context,
      {required String schoolId, bool listen = false}) {
    return jobs.where((job) =>
        (job.positionsOffered[schoolId] ?? 0) -
            job.positionsOccupied(context, listen: listen) >
        0);
  }
}
