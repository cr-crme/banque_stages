import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Uniform', () {
    test('"statuses" are the right label', () {
      expect(UniformStatus.values.length, 3);
      expect(UniformStatus.suppliedByEnterprise.toString(),
          'Oui et l\'entreprise la fournit');
      expect(UniformStatus.suppliedByStudent.toString(),
          'Oui mais l\'entreprise ne la fournit pas');
      expect(UniformStatus.none.toString(), 'Non');
    });

    test('serialization and deserialization works', () {
      final uniform = dummyUniform();
      final serialized = uniform.serialize();
      final deserialized = Uniform.fromSerialized(serialized);

      expect(serialized, {
        'id': uniform.id,
        'status': uniform.status.index,
        'uniform': uniform.uniforms.join('\n'),
      });

      expect(deserialized.id, uniform.id);
      expect(deserialized.status, uniform.status);
      expect(deserialized.uniforms, uniform.uniforms);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Uniform.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.status, UniformStatus.none);
      expect(emptyDeserialized.uniforms, []);
    });
  });
}
