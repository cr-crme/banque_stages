import 'package:common/models/enterprises/job.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('PreInternshipRequest', () {
    test('"types" are the right label', () {
      expect(PreInternshipRequestTypes.values.length, 2);
      expect(PreInternshipRequestTypes.soloInterview.toString(),
          'Une entrevue de recrutement de l\'élève en solo');
      expect(PreInternshipRequestTypes.judiciaryBackgroundCheck.toString(),
          'Une vérification des antécédents judiciaires pour les élèves majeurs');
    });

    test('serialization and deserialization works', () {
      final preInternshipRequest = dummyPreInternshipRequests();
      final serialized = preInternshipRequest.serialize();
      final deserialized =
          PreInternshipRequests.fromSerialized(serialized, '1.0.0');

      expect(serialized, {
        'id': preInternshipRequest.id,
        'requests': preInternshipRequest.requests,
      });

      expect(deserialized.id, preInternshipRequest.id);
      expect(deserialized.requests, preInternshipRequest.requests);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          PreInternshipRequests.fromSerialized({'id': 'emptyId'}, '1.0.0');
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.requests, []);
    });
  });
}
