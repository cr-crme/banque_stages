import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';

class EnterprisesProvider extends ChangeNotifier {
  EnterprisesProvider({List<Enterprise>? enterprises})
      : _enterprises = enterprises ?? [];

  final List<Enterprise> _enterprises;

  operator [](int id) {
    return _enterprises[_enterprises.indexWhere((e) => e.id == id)];
  }

  operator []=(int id, Enterprise enterprise) {
    _enterprises[_enterprises.indexWhere((e) => e.id == id)] = enterprise;
    notifyListeners();
  }

  int getNextId() {
    return 1 +
        _enterprises.fold<int>(
            0,
            (previousId, enterprise) =>
                enterprise.id > previousId ? enterprise.id : previousId);
  }

  void add(Enterprise enterprise) {
    _enterprises.add(enterprise);
    notifyListeners();
  }

  void addAll(Iterable<Enterprise> enterprises) {
    _enterprises.addAll(enterprises);
    notifyListeners();
  }

  void insert(int index, Enterprise enterprise) {
    _enterprises.insert(index, enterprise);
    notifyListeners();
  }

  void insertAll(int index, Iterable<Enterprise> enterprises) {
    _enterprises.insertAll(index, enterprises);
    notifyListeners();
  }

  bool remove(Enterprise enterprise) {
    bool result = _enterprises.remove(enterprise);
    notifyListeners();
    return result;
  }

  Enterprise removeAt(int index) {
    Enterprise result = _enterprises.removeAt(index);
    notifyListeners();
    return result;
  }

  Iterable<T> map<T>(T Function(Enterprise) toElement) {
    Iterable<T> it = _enterprises.map(toElement);
    notifyListeners();
    return it;
  }
}
