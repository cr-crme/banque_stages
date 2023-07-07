import 'package:enhanced_containers/enhanced_containers.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';

class JobList extends ListSerializable<Job> {
  JobList();

  JobList.fromSerialized(map) : super.fromSerialized(map);

  @override
  Job deserializeItem(data) {
    return Job.fromSerialized(
        (data ?? {}).map((k, v) => MapEntry(k.toString(), v)));
  }
}
