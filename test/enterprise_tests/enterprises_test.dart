import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/main.dart';
import 'package:crcrme_banque_stages/screens/enterprises_list/widgets/enterprise_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('Enterprise navigation tab', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('About page', (WidgetTester tester) async {
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));
      await loadDummyData(tester);

      await navigateToScreen(tester, ScreenTest.enterprises);

      // The first enterprise should be Auto Care
      final enterpriseCard = find.byType(EnterpriseCard).first;
      expect(
          find.descendant(
              of: enterpriseCard,
              matching: find.text(EnterpriseTest.autoCare.name)),
          findsOneWidget);
      await tester.tap(enterpriseCard);
      await tester.pumpAndSettle();
    });
  });
}
