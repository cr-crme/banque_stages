import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';

void main() {
  group('SchoolsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('deserializeItem works', () {
      final schools = SchoolsProvider(mockMe: true);
      final school = schools.deserializeItem({'name': 'Test School'});
      expect(school.name, 'Test School');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withSchools: true);
      final schools = SchoolsProvider.of(context, listen: false);
      expect(schools, isNotNull);
    });
  });
}
