import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/firebase_list_provided.dart';

import '/common/models/enterprise.dart';

class EnterprisesProvider extends FirebaseListProvided<Enterprise> {
  EnterprisesProvider() : super(pathToData: "enterprises");

  @override
  Enterprise deserializeItem(data) {
    return Enterprise.fromSerialized(
        (data as Map).map((key, value) => MapEntry(key.toString(), value)));
  }
}
