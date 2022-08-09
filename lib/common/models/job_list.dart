import '/common/models/job.dart';
import '/misc/custom_containers/list_serializable.dart';

class JobList extends ListSerializable<Job> {
  JobList() : super();
  JobList.fromSerialized(Map map) : super.fromSerialized(map);

  @override
  Job deserializeItem(map) {
    return Job.fromSerialized(map);
  }
}
