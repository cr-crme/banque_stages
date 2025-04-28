import 'package:common/models/enterprises/job.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Incidents', () {
    test('"isEmpty" behaves properly', () {
      expect(Incidents().isEmpty, isTrue);
      expect(Incidents().isNotEmpty, isFalse);
      expect(Incidents(severeInjuries: [Incident('Not important')]).isEmpty,
          isFalse);
      expect(Incidents(verbalAbuses: [Incident('Not important')]).isEmpty,
          isFalse);
      expect(Incidents(minorInjuries: [Incident('Not important')]).isEmpty,
          isFalse);
    });

    test('can get all', () {
      final incidents = dummyIncidents();
      expect(incidents.all.length, 3);
    });

    test('serialization and deserialization works', () {
      final incidents = dummyIncidents();
      final serialized = incidents.serialize();
      final deserialized = Incidents.fromSerialized(serialized);

      expect(serialized, {
        'id': incidents.id,
        'severeInjuries': incidents.severeInjuries.map((e) => e.serialize()),
        'verbalAbuses': incidents.verbalAbuses.map((e) => e.serialize()),
        'minorInjuries': incidents.minorInjuries.map((e) => e.serialize()),
      });

      expect(deserialized.id, incidents.id);
      expect(deserialized.severeInjuries, incidents.severeInjuries);
      expect(deserialized.verbalAbuses.toString(),
          incidents.verbalAbuses.toString());
      expect(deserialized.minorInjuries.toString(),
          incidents.minorInjuries.toString());

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Incidents.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.severeInjuries, []);
      expect(emptyDeserialized.verbalAbuses, []);
      expect(emptyDeserialized.minorInjuries, []);
    });

    test('serialization and deserialization of Incident works', () {
      final incident =
          Incident('Je ne désire pas décrire...', date: DateTime(2000));
      final serialized = incident.serialize();
      final deserialized = Incident.fromSerialized(serialized);

      expect(serialized, {
        'id': incident.id,
        'incident': incident.incident,
        'date': incident.date.millisecondsSinceEpoch,
      });

      expect(deserialized.id, incident.id);
      expect(deserialized.incident, incident.incident);
      expect(deserialized.date, incident.date);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Incident.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.incident, '');
      expect(emptyDeserialized.date, DateTime(0));
    });
  });
}
