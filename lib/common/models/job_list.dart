import '/common/models/job.dart';
import '/misc/custom_containers/list_serializable.dart';

class JobList extends ListSerializable<Job> {
  @override
  Job deserializeItem(map) {
    return Job.fromSerialized(map);
  }
}
