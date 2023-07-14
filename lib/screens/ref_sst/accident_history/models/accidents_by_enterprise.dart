import 'package:crcrme_banque_stages/common/models/enterprise.dart';

class AccidentsByEnterprise {
  final Map<Enterprise, List<String>> _all = {};

  void add(Enterprise enterprise, List<String> accidents) {
    if (!_all.containsKey(enterprise)) {
      _all[enterprise] = [];
    }
    _all[enterprise]!.addAll(accidents);
  }

  int get length =>
      _all.keys.fold(0, (running, e) => running + _all[e]!.length);
  Iterable<T> map<T>(Enterprise enterprise, toElement) =>
      _all[enterprise]!.map(toElement);

  Iterable<Enterprise> get enterprises => _all.keys;
  List<String>? description(Enterprise enterprise) => _all[enterprise];
}
