import 'package:cloud_firestore/cloud_firestore.dart';

import '/common/models/enterprise.dart';
import '/misc/custom_containers/list_provided.dart';

class EnterprisesProvider extends ListProvided<Enterprise> {
  EnterprisesProvider() : super() {
    firestoreCollectionRef.snapshots().listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        var enterprise = Enterprise.fromSerialized(docChange.doc.data()!);

        switch (docChange.type) {
          case DocumentChangeType.added:
            add(enterprise);
            break;
          case DocumentChangeType.modified:
            replace(enterprise);
            break;
          case DocumentChangeType.removed:
            remove(enterprise);
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
    firestoreCollectionRef.doc(item.id).set(item.serialize());
  }

  @override
  void replace(Enterprise item, {bool notify = true}) {
    firestoreCollectionRef.doc(item.id).set(item.serialize());
  }

  @override
  operator []=(value, Enterprise item) {
    firestoreCollectionRef.doc(super[value].id).set(item.serialize());
  }

  @override
  void remove(value, {bool notify = true}) {
    firestoreCollectionRef.doc(super[value].id).delete();
  }

  /// This function exists to notify listeners about changes made to the [Enterprise.jobs] attribute
  void notifyJobsChanges() {
    notifyListeners();
  }

  CollectionReference<Map<String, dynamic>> get firestoreCollectionRef =>
      FirebaseFirestore.instance.collection("enterprises");
}
