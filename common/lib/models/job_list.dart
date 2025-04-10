import 'package:common/models/job.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class JobList extends ListSerializable<Job> {
  JobList();

  JobList.fromSerialized(super.map) : super.fromSerialized();

  @override
  Job deserializeItem(data) {
    return Job.fromSerialized(
        (data ?? {}).map((k, v) => MapEntry(k.toString(), v)));
  }
}
