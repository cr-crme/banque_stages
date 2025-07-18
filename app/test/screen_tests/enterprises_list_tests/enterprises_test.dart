import 'package:common/services/backend_helpers.dart';
import 'package:crcrme_banque_stages/main.dart';
import 'package:crcrme_banque_stages/program_helpers.dart';
import 'package:crcrme_banque_stages/screens/enterprises_list/widgets/enterprise_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';

void main() {
  group('Enterprise navigation tab', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(showDebugElements: true, mockMe: true);

    testWidgets('About page', (WidgetTester tester) async {
      await tester.pumpWidget(BanqueStagesApp(
          useMockers: true,
          backendUri:
              BackendHelpers.backendUri(isSecured: false, isDev: true)));
      await tester.loadDummyData();

      await tester.navigateToScreen(ScreenTest.enterprises);

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
