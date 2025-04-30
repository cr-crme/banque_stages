import 'package:crcrme_banque_stages/common/providers/school_boards_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';

void main() {
  group('SchoolsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('deserializeItem works', () {
      final schoolBoards =
          SchoolBoardsProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      final schoolBoard = schoolBoards.deserializeItem({'name': 'Test School'});
      expect(schoolBoard.name, 'Test School');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withSchools: true);
      final schoolBoards = SchoolBoardsProvider.of(context, listen: false);
      expect(schoolBoards, isNotNull);
    });

    testWidgets('can get "mySchoolBoardOf" context with listen',
        (tester) async {
      final context = await tester.contextWithNotifiers(withSchools: true);
      final schoolBoards =
          SchoolBoardsProvider.mySchoolBoardOf(context, listen: true);
      expect(schoolBoards, isNotNull);
    });

    testWidgets('can get "mySchoolOf" context without listen', (tester) async {
      final context = await tester.contextWithNotifiers(withSchools: true);
      final school = SchoolBoardsProvider.mySchoolOf(context, listen: false);
      expect(school, isNotNull);
    });
  });
}
