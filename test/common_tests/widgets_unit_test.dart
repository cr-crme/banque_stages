import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

Widget _declareWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
    theme: crcrmeMaterialTheme,
  );
}

void main() {
  group('ActivityTypeCards', () {
    testWidgets('renders a list of activity types', (tester) async {
      await tester.pumpWidget(_declareWidget(
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
  });
}
