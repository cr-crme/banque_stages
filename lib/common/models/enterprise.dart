import '/common/models/activity_types.dart';
import '/common/models/job.dart';

class Enterprise {
  Enterprise(
      {required this.name,
      this.neq = "",
      required this.activityTypes,
      this.recrutedBy = "",
      required this.shareToOthers,
      required this.jobs,
      required this.contactName,
      this.contactFunction = "",
      required this.contactPhone,
      this.contactEmail = "",
      this.address = ""});

  Enterprise copyWith(
      {String? name,
      String? neq,
      List<ActivityTypes>? activityTypes,
      String? recrutedBy,
      bool? shareToOthers,
      List<Job>? jobs,
      String? contactName,
      String? contactFunction,
      String? contactPhone,
      String? contactEmail,
      String? address}) {
    return Enterprise(
        name: name ?? this.name,
        neq: neq ?? this.neq,
        activityTypes: activityTypes ?? this.activityTypes,
        recrutedBy: recrutedBy ?? this.recrutedBy,
        shareToOthers: shareToOthers ?? this.shareToOthers,
        jobs: jobs ?? this.jobs,
        contactName: contactName ?? this.contactName,
        contactFunction: contactFunction ?? this.contactFunction,
        contactPhone: contactPhone ?? this.contactPhone,
        contactEmail: contactEmail ?? this.contactEmail,
        address: address ?? this.address);
  }

  final String name;
  final String neq;
  final List<ActivityTypes> activityTypes;
  final String recrutedBy;
  final bool shareToOthers;

  final List<Job> jobs;

  final String contactName;
  final String contactFunction;
  final String contactPhone;
  final String contactEmail;

  final String address;
}
