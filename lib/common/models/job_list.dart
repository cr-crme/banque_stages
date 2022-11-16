import 'package:enhanced_containers/enhanced_containers.dart';

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
