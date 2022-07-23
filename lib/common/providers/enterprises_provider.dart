import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_provided.dart';

class EnterprisesProvider extends ListProvided<Enterprise> {
  @override
  Enterprise deserializeItem(map) {
    return Enterprise.fromSerialized(map);
  }

  /// This function exists to notify listeners about changes made to the [Enterprise.jobs] attribute
  void notifyJobsChanges() {
    notifyListeners();
  }
}
