import 'package:common/models/enterprises/job.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Protections', () {
    test('"statuses" are the right label', () {
      expect(ProtectionsStatus.values.length, 3);
      expect(ProtectionsStatus.suppliedByEnterprise.toString(),
          'Oui et l\'entreprise les fournit');
      expect(ProtectionsStatus.suppliedBySchool.toString(),
          'Oui mais l\'entreprise ne les fournit pas');
      expect(ProtectionsStatus.none.toString(), 'Non');
    });

    test('"types" are the right lable', () {
      expect(ProtectionsType.values.length, 7);
      expect(ProtectionsType.steelToeShoes.toString(),
          'Chaussures à cap d\'acier');
      expect(ProtectionsType.nonSlipSoleShoes.toString(),
          'Chaussures à semelles antidérapantes');
      expect(ProtectionsType.safetyGlasses.toString(), 'Lunettes de sécurité');
      expect(ProtectionsType.earProtection.toString(), 'Protections auditives');
      expect(ProtectionsType.mask.toString(), 'Masque');
      expect(ProtectionsType.helmet.toString(), 'Casque');
      expect(ProtectionsType.gloves.toString(), 'Gants');
    });

    test('serialization and deserialization works', () {
      final protections = dummyProtections();
      final serialized = protections.serialize();
      final deserialized = Protections.fromSerialized(serialized);

      expect(serialized, {
        'id': protections.id,
        'protections': protections.protections,
        'status': protections.status.index,
      });

      expect(deserialized.id, protections.id);
      expect(deserialized.protections, protections.protections);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Protections.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.protections, []);
      expect(emptyDeserialized.status, ProtectionsStatus.none);
    });
  });
}
