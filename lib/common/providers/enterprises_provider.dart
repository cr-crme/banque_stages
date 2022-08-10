import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_firebase.dart';

class EnterprisesProvider extends ListFirebase<Enterprise> {
  EnterprisesProvider()
      : super(idListPath: "enterprises-list", dataPath: "enterprises");

  @override
  Enterprise deserializeItem(map) {
    return Enterprise.fromSerialized(map);
  }
}
