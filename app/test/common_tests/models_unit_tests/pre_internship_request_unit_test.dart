import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('PreInternshipRequest', () {
    test('"types" are the right label', () {
      expect(PreInternshipRequestType.values.length, 2);
      expect(PreInternshipRequestType.soloInterview.toString(),
          'Une entrevue de recrutement de l\'élève en solo');
      expect(PreInternshipRequestType.judiciaryBackgroundCheck.toString(),
          'Une vérification des antécédents judiciaires pour les élèves majeurs');
    });

    test('serialization and deserialization works', () {
      final preInternshipRequest = dummyPreInternshipRequest();
      final serialized = preInternshipRequest.serialize();
      final deserialized = PreInternshipRequest.fromSerialized(serialized);

      expect(serialized, {
        'id': preInternshipRequest.id,
        'requests': preInternshipRequest.requests,
      });

      expect(deserialized.id, preInternshipRequest.id);
      expect(deserialized.requests, preInternshipRequest.requests);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          PreInternshipRequest.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.requests, []);
    });
  });
}
