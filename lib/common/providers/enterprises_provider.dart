import 'package:firebase_database/firebase_database.dart';

import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_provided.dart';

class EnterprisesProvider extends ListProvided<Enterprise> {
  EnterprisesProvider() : super() {
    listRef.onChildAdded.listen((DatabaseEvent event) {
      String id = event.snapshot.key!;
      dataRef.child(id).get().then(
            (data) => super.add(
              Enterprise.fromSerialized(data.value! as Map),
            ),
          );

      // Listen to data changes
      dataRef.child(id).onChildChanged.listen((DatabaseEvent event) {
        var map = this[id].serialize();
        map[event.snapshot.key!] = event.snapshot.value;

        replace(Enterprise.fromSerialized(map));
      });
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
