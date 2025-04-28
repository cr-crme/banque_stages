import 'package:common/models/enterprises/enterprise.dart';

class IncidentsByEnterprise {
  final Map<Enterprise, List<String>> _all = {};

  void add(Enterprise enterprise, List<String> incidents) {
    if (!_all.containsKey(enterprise)) {
      _all[enterprise] = [];
    }
    _all[enterprise]!.addAll(incidents);
  }

  int get length =>
      _all.keys.fold(0, (running, e) => running + _all[e]!.length);
  Iterable<T> map<T>(Enterprise enterprise, toElement) =>
      _all[enterprise]!.map(toElement);

  Iterable<Enterprise> get enterprises => _all.keys;
  List<String>? description(Enterprise enterprise) => _all[enterprise];
}
