import 'package:firebase_database/firebase_database.dart';

import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_provided.dart';

class EnterprisesProvider extends ListProvided<Enterprise> {
  EnterprisesProvider() : super() {
    listRef.get().then((snapshot) async {
      bool notify = false;

      for (var child in snapshot.children) {
        var data = await dataRef.child(child.key!).get();

        var enterprise = Enterprise.fromSerialized((data.value! as Map)
            .map((key, value) => MapEntry(key.toString(), value)));

        super.add(enterprise, notify: false);
        notify = true;
      }

      if (notify) notifyListeners();
    });

    listRef.onChildAdded.listen((DatabaseEvent event) async {
      if (any((enterprise) => enterprise.id == event.snapshot.key!)) return;
      var data = await dataRef.child(event.snapshot.key!).get();

      // TODO: Remove this check
      if (any((enterprise) => enterprise.id == event.snapshot.key!)) return;

      var enterprise = Enterprise.fromSerialized((data.value! as Map)
          .map((key, value) => MapEntry(key.toString(), value)));

      super.add(enterprise);
    });

    listRef.onChildRemoved.listen((DatabaseEvent event) {
      super.remove(event.snapshot.key!);
    });
  }

  @override
  Enterprise deserializeItem(map) {
    return Enterprise.fromSerialized(map);
  }

  @override
  void add(Enterprise item, {bool notify = true}) {
    dataRef.child(item.id).set(item.serialize());
    listRef.child(item.id).set(true);
  }

  @override
  void replace(Enterprise item, {bool notify = true}) {
    dataRef.child(item.id).set(item.serialize());
  }

  @override
  operator []=(value, Enterprise item) {
    dataRef.child(super[value].id).set(item.serialize());
  }

  @override
  void remove(value, {bool notify = true}) {
    listRef.child(super[value].id).remove();
    dataRef.child(super[value].id).remove();
  }

  DatabaseReference get listRef =>
      FirebaseDatabase.instance.ref("enterprises-list");
  DatabaseReference get dataRef => FirebaseDatabase.instance.ref("enterprises");
}
