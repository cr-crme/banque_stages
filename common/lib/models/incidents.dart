import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class Incident extends ItemSerializable {
  String incident;
  DateTime date;

  Incident(this.incident, {DateTime? date}) : date = date ?? DateTime.now();

  Incident.fromSerialized(super.map)
      : incident = map['incident'] ?? '',
        date = map['date'] == null
            ? DateTime(0)
            : DateTime.fromMillisecondsSinceEpoch(map['date']),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'incident': incident,
        'date': date.millisecondsSinceEpoch,
      };

  // TODO Implement this App side with an extension on
  // @override
  // String toString() => '${DateFormat('yyyy-MM-dd').format(date)} - $incident';
}

class Incidents extends ItemSerializable {
  List<Incident> severeInjuries;
  List<Incident> verbalAbuses;
  List<Incident> minorInjuries;

  bool get isEmpty => !hasMajorIncident && minorInjuries.isEmpty;
  bool get isNotEmpty => !isEmpty;
  bool get hasMajorIncident =>
      severeInjuries.isNotEmpty || verbalAbuses.isNotEmpty;

  List<Incident> get all =>
      [...severeInjuries, ...verbalAbuses, ...minorInjuries];

  Incidents({
    super.id,
    List<Incident>? severeInjuries,
    List<Incident>? verbalAbuses,
    List<Incident>? minorInjuries,
  })  : severeInjuries = severeInjuries ?? [],
        verbalAbuses = verbalAbuses ?? [],
        minorInjuries = minorInjuries ?? [];

  static Incidents get empty => Incidents();

  Incidents.fromSerialized(super.map)
      : severeInjuries = (map['severeInjuries'] as List?)
                ?.map((e) => Incident.fromSerialized(e))
                .toList() ??
            [],
        verbalAbuses = (map['verbalAbuses'] as List?)
                ?.map((e) => Incident.fromSerialized(e))
                .toList() ??
            [],
        minorInjuries = (map['minorInjuries'] as List?)
                ?.map((e) => Incident.fromSerialized(e))
                .toList() ??
            [],
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'severeInjuries': severeInjuries.map((e) => e.serialize()).toList(),
        'verbalAbuses': verbalAbuses.map((e) => e.serialize()).toList(),
        'minorInjuries': minorInjuries.map((e) => e.serialize()).toList(),
      };
}
