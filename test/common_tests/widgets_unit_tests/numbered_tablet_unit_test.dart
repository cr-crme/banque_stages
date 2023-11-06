import 'package:crcrme_banque_stages/common/widgets/numbered_tablet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import 'utils.dart';

void main() {
  group('NumberedTablet', () {
    testWidgets('can render properly', (tester) async {
      await tester.pumpWidget(declareWidget(const NumberedTablet(number: 0)));

      final iconFider = find.byIcon(Icons.circle).last;
      final icon = tester.widget<Icon>(iconFider);
      expect(iconFider, findsOneWidget);
      expect(icon.color, Theme.of(tester.context(iconFider)).primaryColor);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('can render positive numbers', (tester) async {
      await tester.pumpWidget(declareWidget(const NumberedTablet(number: 1)));
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('can render negative numbers', (tester) async {
      await tester.pumpWidget(declareWidget(const NumberedTablet(number: -1)));
      expect(find.text('-1'), findsOneWidget);
    });

    testWidgets('can change color', (tester) async {
      await tester.pumpWidget(
          declareWidget(const NumberedTablet(number: 1, color: Colors.red)));

      final iconFider = find.byIcon(Icons.circle).last;
      final icon = tester.widget<Icon>(iconFider);
      expect(icon.color, Colors.red);
    });

    testWidgets('"hideIfEmpty" behaves properly when empty', (tester) async {
      await tester.pumpWidget(
          declareWidget(const NumberedTablet(number: 0, hideIfEmpty: true)));
      expect(find.byIcon(Icons.circle), findsNothing);
    });

    testWidgets('"hideIfEmpty" behaves properly when not empty',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(const NumberedTablet(number: 1, hideIfEmpty: true)));
      expect(find.byIcon(Icons.circle), findsNWidgets(3));
    });

    testWidgets('"hideIfEmpty" behaves properly when is  false',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(const NumberedTablet(number: 0, hideIfEmpty: false)));
      expect(find.byIcon(Icons.circle), findsNWidgets(3));
    });
  });
}
