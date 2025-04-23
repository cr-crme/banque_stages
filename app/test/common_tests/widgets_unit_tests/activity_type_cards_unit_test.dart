import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import 'utils.dart';

void main() {
  group('ActivityTypeCards', () {
    testWidgets('renders a list of activity types', (tester) async {
      await tester.pumpWidget(declareWidget(
          const ActivityTypeCards(activityTypes: {'running', 'cycling'})));

      expect(find.text('running'), findsOneWidget);
      expect(find.text('cycling'), findsOneWidget);

      // Make sure the appareance is correct
      final textFinder = find.text('running');
      final text = tester.widget<Text>(textFinder);
      final chip = tester.ancestorByType<Chip>(of: textFinder);

      expect(text.style!.fontWeight, FontWeight.normal);
      expect(text.style!.color, const Color(0xff000000));
      expect(chip.backgroundColor, const Color(0xFFB8D8E6));
    });

    testWidgets('The delete icon does not appear when no callback',
        (tester) async {
      await tester.pumpWidget(declareWidget(
          const ActivityTypeCards(activityTypes: {'running', 'cycling'})));

      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('The delete icon appears when a callback is provided',
        (tester) async {
      bool wasClicked = false;
      await tester.pumpWidget(declareWidget(ActivityTypeCards(
          activityTypes: const {'running', 'cycling'},
          onDeleted: (activityType) {
            wasClicked = true;
          })));

      final iconFinder = find.byIcon(Icons.delete);
      expect(iconFinder, findsNWidgets(2));

      // Make sure the appareance is correct
      final icon = tester.widget<Icon>(iconFinder.first);
      expect(icon.color, const Color(0xff000000));

      // Tap on it and get the
      await tester.tap(iconFinder.first);
      await tester.pumpAndSettle();
      expect(wasClicked, isTrue);
    });
  });
}
