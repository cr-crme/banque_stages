import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/firebase_list_provided.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';

class EnterprisesProvider extends FirebaseListProvided<Enterprise> {
  EnterprisesProvider() : super(pathToData: "enterprises");

  @override
  Enterprise deserializeItem(data) {
    return Enterprise.fromSerialized(data);
  }

  void replaceJob(enterprise, Job job) {
    this[enterprise].jobs.replace(job);
    replace(this[enterprise]);
  }
}
