import '/misc/custom_containers/list_provided.dart';
import '/common/models/enterprise.dart';

class EnterprisesProvider extends ListProvided<Enterprise> {
  @override
  Enterprise deserializeItem(map) {
    return Enterprise.fromSerialized(map);
  }
}
