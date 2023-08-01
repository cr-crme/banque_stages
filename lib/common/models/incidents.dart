import 'package:enhanced_containers/enhanced_containers.dart';

List<String> _stringListFromSerialized(List? list) =>
    (list ?? []).map<String>((e) => e).toList();

class Incidents extends ItemSerializable {
  List<String> severeInjuries;
  List<String> verbalAbuses;
  List<String> minorInjuries;

  bool get isEmpty =>
      severeInjuries.isEmpty && verbalAbuses.isEmpty && minorInjuries.isEmpty;
  bool get isNotEmpty => !isEmpty;

  List<String> get all =>
      [...severeInjuries, ...verbalAbuses, ...minorInjuries];

  Incidents({
    List<String>? severeInjuries,
    List<String>? verbalAbuses,
    List<String>? minorInjuries,
  })  : severeInjuries = severeInjuries ?? [],
        verbalAbuses = verbalAbuses ?? [],
        minorInjuries = minorInjuries ?? [];

  static Incidents get empty => Incidents();

  Incidents.fromSerialized(map)
      : severeInjuries = _stringListFromSerialized(map['severeInjuries']),
        verbalAbuses = _stringListFromSerialized(map['verbalAbuses']),
        minorInjuries = _stringListFromSerialized(map['minorInjuries']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'severeInjuries': severeInjuries,
        'verbalAbuses': verbalAbuses,
        'minorInjuries': minorInjuries,
      };
}
