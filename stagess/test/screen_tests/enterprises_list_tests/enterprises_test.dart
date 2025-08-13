import 'package:flutter_test/flutter_test.dart';
import 'package:stagess/main.dart';
import 'package:stagess/program_helpers.dart';
import 'package:stagess/screens/enterprises_list/widgets/enterprise_card.dart';
import 'package:stagess_common/services/backend_helpers.dart';

import '../../utils.dart';

void main() {
  group('Enterprise navigation tab', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(showDebugElements: true, mockMe: true);

    testWidgets('About page', (WidgetTester tester) async {
      await tester.pumpWidget(StageSsApp(
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
