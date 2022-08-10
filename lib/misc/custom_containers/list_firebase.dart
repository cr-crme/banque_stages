import 'package:firebase_database/firebase_database.dart';

import '/misc/custom_containers/item_serializable.dart';
import '/misc/custom_containers/list_provided.dart';

abstract class ListFirebase<T> extends ListProvided<T> {
  ListFirebase({
    required String idListPath,
    required String dataPath,
  })  : _idListPath = idListPath,
        _dataPath = dataPath,
        super() {
    idListRef.onChildAdded.listen((DatabaseEvent event) {
      String id = event.snapshot.key!;
      dataRef.child(id).get().then(
            (data) => super.add(
              deserializeItem(data.value! as Map),
            ),
          );

      // Listen to data changes
      dataRef.child(id).onChildChanged.listen((DatabaseEvent event) {
        var map = (this[id] as ItemSerializable).serialize();
        map[event.snapshot.key!] = event.snapshot.value;

        super.replace(deserializeItem(map));
      });
    });

    idListRef.onChildRemoved.listen((DatabaseEvent event) {
      super.remove(event.snapshot.key!);
    });
  }

  @override
  void add(T item, {bool notify = true}) {
    dataRef.child((item as ItemSerializable).id).set(item.serialize());
    idListRef.child(item.id).set(true);
  }

  @override
  void replace(T item, {bool notify = true}) {
    dataRef.child((item as ItemSerializable).id).set(item.serialize());
  }

  @override
  operator []=(value, T item) {
    dataRef
        .child((super[value] as ItemSerializable).id)
        .set((item as ItemSerializable).serialize());
  }

  @override
  void remove(value, {bool notify = true}) {
    idListRef.child((super[value] as ItemSerializable).id).remove();
    dataRef.child((super[value] as ItemSerializable).id).remove();
  }

  final String _idListPath;
  final String _dataPath;

  DatabaseReference get idListRef => FirebaseDatabase.instance.ref(_idListPath);
  DatabaseReference get dataRef => FirebaseDatabase.instance.ref(_dataPath);
}
