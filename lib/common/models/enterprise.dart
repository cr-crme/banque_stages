import '/common/models/activity_types.dart';
import '/common/models/job.dart';

class Enterprise {
  Enterprise(
      {required this.name,
      this.neq = "",
      required this.activityTypes,
      this.recrutedBy = "",
      required this.shareToOthers,
      List<Job>? jobs,
      EnterpriseContactInformation? contactInformation})
      : jobs = jobs ?? [],
        contactInformation =
            contactInformation ?? EnterpriseContactInformation();

  String name;
  String neq;
  List<ActivityTypes> activityTypes;
  String recrutedBy;
  bool shareToOthers;

  List<Job> jobs;

  EnterpriseContactInformation contactInformation;
}

class EnterpriseContactInformation {
  EnterpriseContactInformation(
      {this.name = "",
      this.function = "",
      this.phone = "",
      this.email = "",
      this.address = ""});

  String name;
  String function;
  String phone;
  String email;
  String address;
}
