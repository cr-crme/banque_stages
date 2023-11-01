import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:crcrme_banque_stages/common/widgets/add_job_button.dart';
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

    testWidgets('The delete icon does not appear when no callback',
        (tester) async {
      await tester.pumpWidget(_declareWidget(
          const ActivityTypeCards(activityTypes: {'running', 'cycling'})));

      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('The delete icon appears when a callback is provided',
        (tester) async {
      bool wasClicked = false;
      await tester.pumpWidget(_declareWidget(ActivityTypeCards(
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

  group('AddJobButton', () {
    testWidgets('renders a button with an icon and a text', (tester) async {
      await tester.pumpWidget(_declareWidget(AddJobButton(onPressed: () {})));

      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget);
      expect(find.text('Ajouter un métier'), findsOneWidget);
    });

    testWidgets('renders a button with a custom style', (tester) async {
      await tester.pumpWidget(_declareWidget(AddJobButton(
        onPressed: () {},
        style: TextButton.styleFrom(backgroundColor: Colors.red),
      )));

      final button = tester.widget<TextButton>(find.bySubtype<TextButton>());
      expect(button.style!.backgroundColor!.resolve({}), Colors.red);
    });

    testWidgets('renders a button with a custom onPressed callback',
        (tester) async {
      bool wasClicked = false;
      await tester.pumpWidget(_declareWidget(AddJobButton(
        onPressed: () {
          wasClicked = true;
        },
      )));

      await tester.tap(find.bySubtype<TextButton>());
      await tester.pumpAndSettle();
      expect(wasClicked, isTrue);
    });
  });
}
