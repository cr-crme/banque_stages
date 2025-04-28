import 'package:common/models/enterprises/job.dart';
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
      final uniform = dummyUniforms();
      final serialized = uniform.serialize();
      final deserialized = Uniforms.fromSerialized(serialized, '1.0.0');

      expect(serialized, {
        'id': uniform.id,
        'status': uniform.status.index,
        'uniform': uniform.uniforms.join('\n'),
      });

      expect(deserialized.id, uniform.id);
      expect(deserialized.status, uniform.status);
      expect(deserialized.uniforms, uniform.uniforms);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          Uniforms.fromSerialized({'id': 'emptyId'}, '1.0.0');
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.status, UniformStatus.none);
      expect(emptyDeserialized.uniforms, []);
    });
  });
}
