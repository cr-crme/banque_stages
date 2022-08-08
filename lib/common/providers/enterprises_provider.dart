import 'package:firebase_database/firebase_database.dart';

import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_provided.dart';

class EnterprisesProvider extends ListProvided<Enterprise> {
  EnterprisesProvider() : super() {
    databaseRef.onValue.listen((DatabaseEvent event) {
      for (var child in event.snapshot.children) {
        var enterprise = Enterprise.fromSerialized((child.value! as Map)
            .map((key, value) => MapEntry(key.toString(), value)));

        switch (event.type) {
          case DatabaseEventType.value:
          case DatabaseEventType.childAdded:
            super.add(enterprise);
            break;
          case DatabaseEventType.childChanged:
            super.replace(enterprise);
            break;
          case DatabaseEventType.childRemoved:
            super.remove(enterprise);
            break;
          case DatabaseEventType.childMoved:
            // TODO: Handle this case.
            break;
        }
      }

      notifyListeners();
    });
  }

  @override
  Enterprise deserializeItem(map) {
    return Enterprise.fromSerialized(map);
  }

  @override
  void add(Enterprise item, {bool notify = true}) {
    databaseRef.child(item.id).set(item.serialize());
  }

  @override
  void replace(Enterprise item, {bool notify = true}) {
    databaseRef.child(item.id).set(item.serialize());
  }

  @override
  operator []=(value, Enterprise item) {
    databaseRef.child(super[value].id).set(item.serialize());
  }

  @override
  void remove(value, {bool notify = true}) {
    databaseRef.child(super[value].id).remove();
  }

  DatabaseReference get databaseRef =>
      FirebaseDatabase.instance.ref("enterprises");
}
