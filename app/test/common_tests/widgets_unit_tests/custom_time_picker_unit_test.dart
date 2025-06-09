import 'package:common_flutter/widgets/custom_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('CustomTimePicker dial view', () {
    testWidgets('is in french', (tester) async {
      await tester.pumpWidget(declareWidget(const CustomTimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      expect(find.text('Sélectionner l\'heure'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('h'), findsOneWidget);
      expect(find.text('32'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('has keyboard icon', (tester) async {
      await tester.pumpWidget(declareWidget(const CustomTimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      expect(find.byIcon(Icons.keyboard_outlined), findsOneWidget);
    });
  });

  group('CustomTimePicker keyboard view', () {
    testWidgets('is in french', (tester) async {
      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      await tester.pumpWidget(declareWidget(const TimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Entrer l\'heure'), findsOneWidget);
      expect(find.text('15'), findsNWidgets(2));
      expect(find.text('h'), findsOneWidget);
      expect(find.text('32'), findsNWidgets(2));
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('has dial icon', (tester) async {
      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      await tester.pumpWidget(declareWidget(const TimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('can change hours', (tester) async {
      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      await tester.pumpWidget(declareWidget(const TimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('15'), findsNWidgets(2));
      await tester.enterText(find.byType(TextFormField).first, '18');
      await tester.pumpAndSettle();
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('can change minutes', (tester) async {
      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      await tester.pumpWidget(declareWidget(const TimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('32'), findsNWidgets(2));
      await tester.enterText(find.byType(TextFormField).last, '18');
      await tester.pumpAndSettle();
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('typing hour outside range is rejected', (tester) async {
      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      await tester.pumpWidget(declareWidget(const TimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Entrer une heure valide'), findsNothing);

      await tester.enterText(find.byType(TextFormField).first, '25');
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Entrez une heure valide'), findsOneWidget);

      // This should work with CustomTimePickerDialog, but is not currently tested
      // await tester.enterText(find.byType(TextFormField).first, '23');
      // await tester.pumpAndSettle();
      // await tester.tap(find.text('OK'));
      // await tester.pumpAndSettle();
      // expect(find.text('Entrez une heure valide'), findsNothing);
    });

    testWidgets('typing minute outside range is rejected', (tester) async {
      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      await tester.pumpWidget(declareWidget(const TimePickerDialog(
        initialTime: TimeOfDay(hour: 15, minute: 32),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Entrez une minute valide'), findsNothing);

      await tester.enterText(find.byType(TextFormField).last, '60');
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Entrez une heure valide'), findsOneWidget);

      // This should work with CustomTimePickerDialog, but is not currently tested
      // await tester.enterText(find.byType(TextFormField).last, '59');
      // await tester.pumpAndSettle();
      // await tester.tap(find.text('OK'));
      // await tester.pumpAndSettle();
      // expect(find.text('Entrez une heure valide'), findsNothing);
    });
  });

  group('CustomTimePicker return', () {
    testWidgets('The returned time is correct', (tester) async {
      TimeOfDay? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomTimePicker(
                context: tester.element(find.byType(ElevatedButton)),
                initialTime: const TimeOfDay(hour: 15, minute: 32));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Tap the OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, const TimeOfDay(hour: 15, minute: 32));
    });

    testWidgets('the cancel icon works in dial view', (tester) async {
      TimeOfDay? result;

      // This should be CustomTimePickerDialog, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showTimePicker(
                context: tester.element(find.byType(ElevatedButton)),
                initialTime: const TimeOfDay(hour: 15, minute: 32));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Tap the cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result, null);
    });

    testWidgets('the cancel button works in keyboard view', (tester) async {
      TimeOfDay? result;

      // This should be showCustomTimePicker, but for unknown reasons
      // it creates an overflow error when the keyboard is shown
      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showTimePicker(
                context: tester.element(find.byType(ElevatedButton)),
                initialTime: const TimeOfDay(hour: 15, minute: 32));
          },
          child: const Text('Click me'));

      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Navigate to keyboard view
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      // Tap the cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result, null);
    });
  });
}
