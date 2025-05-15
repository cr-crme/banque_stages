import 'package:common/models/enterprises/job.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class JobList extends ListSerializable<Job> {
  JobList();

  static JobList? from(map) {
    if (map == null) return null;
    return JobList.fromSerialized(map);
  }

  JobList.fromSerialized(super.map) : super.fromSerialized();

  @override
  Job deserializeItem(data) {
    return Job.fromSerialized(
        (data ?? {}).map((k, v) => MapEntry(k.toString(), v)));
  }
}
