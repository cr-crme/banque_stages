import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/list_serializable.dart';

import '/common/models/job.dart';

class JobList extends ListSerializable<Job> {
  JobList();

  JobList.fromSerialized(Map<String, dynamic> map) : super.fromSerialized(map);

  @override
  Job deserializeItem(data) {
    return Job.fromSerialized(
        (data as Map).map((key, value) => MapEntry(key.toString(), value)));
  }
}
