import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common_flutter/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('DatePickerDialog calendar view', () {
    testWidgets('is in french', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));

      expect(find.text('Sélectionner la date'), findsOneWidget);
      expect(find.text('ven. 1 janv.'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('has keyboard icon', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));

      expect(find.byIcon(Icons.keyboard_outlined), findsOneWidget);
    });

    testWidgets('selecting a date is reflected in the header', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));

      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();
      expect(find.text('ven. 15 janv.'), findsOneWidget);
    });
  });

  group('DatePickerDialog keyboard view', () {
    testWidgets('is in french', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Sélectionner la date'), findsOneWidget);
      expect(find.text('ven. 1 janv.'), findsOneWidget);
      expect(find.text('Entrer une date'), findsOneWidget);
      expect(find.text('jj-mm-aaaa'), findsOneWidget);

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('has calendar icon', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('typing a date is reflected in the header', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '15-01-2021');
      await tester.pumpAndSettle();

      expect(find.text('ven. 15 janv.'), findsOneWidget);
    });

    testWidgets('typing the wrong date is rejected', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2021-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsNothing);
    });

    testWidgets('yyyy-mm-dd is accepted', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '2021-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsNothing);
    });

    testWidgets('dd-mm-yyyy is accepted', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '15-01-2021');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsNothing);
    });

    testWidgets('typing outside date range is rejected', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDatePickerDialog(
        initialDate: DateTime(2021),
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
      )));
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '2020-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Hors de portée.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2023-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Hors de portée.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '2021-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Hors de portée.'), findsNothing);
    });
  });

  group('DatePickerDialog return', () {
    testWidgets('The returned date is correct', (tester) async {
      DateTime? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomDatePicker(
                context: tester.element(find.byType(ElevatedButton)),
                initialDate: DateTime(2021),
                firstDate: DateTime(2021),
                lastDate: DateTime(2022));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Select a date
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      // Tap the OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(result, DateTime(2021, 1, 15));
    });

    testWidgets('the cancel button works in calendar view', (tester) async {
      DateTime? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomDatePicker(
                context: tester.element(find.byType(ElevatedButton)),
                initialDate: DateTime(2021),
                firstDate: DateTime(2021),
                lastDate: DateTime(2022));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Select a date
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      // Tap the cancel button
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result, null);
    });

    testWidgets('the cancel button works in keyboard view', (tester) async {
      DateTime? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomDatePicker(
                context: tester.element(find.byType(ElevatedButton)),
                initialDate: DateTime(2021),
                firstDate: DateTime(2021),
                lastDate: DateTime(2022));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Select a date
      await tester.tap(find.text('15').first);
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

  group('CustomDateRangePickerDialog calendar view', () {
    testWidgets('is in french', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      expect(find.text('Enregistrer'), findsOneWidget);
      expect(find.text('Sélectionner la plage'), findsOneWidget);
      expect(find.text('Début'), findsOneWidget);
      expect(find.text('Fin'), findsOneWidget);
    });

    testWidgets('has keyboard icon', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      expect(find.byIcon(Icons.keyboard_outlined), findsOneWidget);
    });

    testWidgets('selecting a date is reflected in the header', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      expect(find.text('Début'), findsOneWidget);
      expect(find.text('Fin'), findsOneWidget);

      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();
      expect(find.text('15 janv.'), findsOneWidget);
      expect(find.text('Début'), findsNothing);
      expect(find.text('Fin'), findsOneWidget);

      await tester.tap(find.text('18').first);
      await tester.pumpAndSettle();
      expect(find.text('15 janv.'), findsOneWidget);
      expect(find.text('18 janv. 2021'), findsOneWidget);
      expect(find.text('Début'), findsNothing);
      expect(find.text('Fin'), findsNothing);
    });
  });

  group('CustomDateRangePickerDialog keyboard view', () {
    testWidgets('is in french', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Sélectionner la plage'), findsOneWidget);
      expect(find.text('Période'), findsOneWidget);
      expect(find.text('Date de début'), findsOneWidget);
      expect(find.text('Date de fin'), findsOneWidget);
      expect(find.text('jj-mm-aaaa'), findsNWidgets(2));

      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('has calendar icon', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('selecting dates is reflected in the header', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      await tester.tap(find.text('15').first);
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Période'), findsOneWidget);
      expect(find.text('Date de début'), findsOneWidget);
      expect(find.text('Date de fin'), findsOneWidget);
      expect(find.text('jj-mm-aaaa'), findsNWidgets(2));
      expect(find.text('2021-01-15'), findsOneWidget);

      // Navigate back to the calendar, select a end date and navigate back
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18').first);
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Période'), findsNothing);
      expect(find.text('15 janv.'), findsNothing);
      expect(find.text('18 janv. 2021'), findsNothing);

      expect(find.text('Date de début'), findsOneWidget);
      expect(find.text('Date de fin'), findsOneWidget);
      expect(find.text('jj-mm-aaaa'), findsNWidgets(2));
      expect(find.text('2021-01-15'), findsOneWidget);
      expect(find.text('2021-01-18'), findsOneWidget);
    });

    testWidgets('typing the wrong date is rejected', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '0');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsNWidgets(2));

      await tester.enterText(find.byType(TextField).first, '2021-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsOneWidget);
    });

    testWidgets('yyyy-mm-dd and dd-mm-yyyy are both accepted', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '2021-01-15');
      await tester.enterText(find.byType(TextField).last, '16-01-2021');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Format incorrect'), findsNothing);
    });

    testWidgets('typing outside date range is rejected', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021),
        lastDate: DateTime(2022),
        currentDate: DateTime(2021),
      )));

      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '15-01-2020');
      await tester.enterText(find.byType(TextField).last, '15-01-2020');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Hors de portée.'), findsNWidgets(2));

      await tester.enterText(find.byType(TextField).first, '15-01-2023');
      await tester.enterText(find.byType(TextField).last, '15-01-2023');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Hors de portée.'), findsNWidgets(2));

      await tester.enterText(find.byType(TextField).first, '2021-01-15');
      await tester.enterText(find.byType(TextField).last, '2021-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Hors de portée.'), findsNothing);
    });

    testWidgets('ending date after starting is rejected', (tester) async {
      await tester.pumpWidget(declareWidget(CustomDateRangePickerDialog(
        firstDate: DateTime(2021, 1, 15),
        lastDate: DateTime(2021, 1, 18),
        currentDate: DateTime(2021, 1, 15),
      )));
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '2021-01-16');
      await tester.enterText(find.byType(TextField).last, '2021-01-15');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Plage incorrecte.'), findsOneWidget);
    });
  });

  group('CustomDateRangePickerDialog return', () {
    testWidgets('The returned date is correct', (tester) async {
      time_utils.DateTimeRange? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomDateRangePicker(
                context: tester.element(find.byType(ElevatedButton)),
                firstDate: DateTime(2021),
                lastDate: DateTime(2022));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Select a date range
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('18').first);
      await tester.pumpAndSettle();

      // Tap the OK button
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(
          result,
          time_utils.DateTimeRange(
              start: DateTime(2021, 1, 15), end: DateTime(2021, 1, 18)));
    });

    testWidgets('the cancel icon works in calendar view', (tester) async {
      time_utils.DateTimeRange? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomDateRangePicker(
                context: tester.element(find.byType(ElevatedButton)),
                firstDate: DateTime(2021),
                lastDate: DateTime(2022));
          },
          child: const Text('Click me'));
      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Select a date range
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('18').first);
      await tester.pumpAndSettle();

      // Tap the cancel button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, null);
    });

    testWidgets('the cancel button works', (tester) async {
      time_utils.DateTimeRange? result;

      final myButton = ElevatedButton(
          onPressed: () async {
            result = await showCustomDateRangePicker(
                context: tester.element(find.byType(ElevatedButton)),
                firstDate: DateTime(2021),
                lastDate: DateTime(2022));
          },
          child: const Text('Click me'));

      await tester.pumpWidget(declareWidget(myButton));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Select a date range
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('18').first);
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
