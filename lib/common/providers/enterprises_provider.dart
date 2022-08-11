import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_firebase.dart';

class EnterprisesProvider extends ListFirebase<Enterprise> {
  EnterprisesProvider()
      : super(availableIdsPath: "enterprises-list", dataPath: "enterprises");

  @override
  Enterprise deserializeItem(data) {
    return Enterprise.fromSerialized(
        (data as Map).map((key, value) => MapEntry(key.toString(), value)));
  }
}
