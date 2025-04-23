import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/activity_types_picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('ActivityTypesPickerFormField functionalities', () {
    testWidgets('renders a hint and nothing else', (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      expect(find.text('* Type d\'activité de l\'entreprise'), findsOneWidget);
      expect(find.text(activityTypes[0]), findsNothing);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('tapping in text field opens a tab with options',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.text(activityTypes[0]), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('selecting an activity renders a tab showing the choice',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      expect(find.text(activityTypes[0]), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('the choice is no longer shown if already selected',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      expect(find.text(activityTypes[0]), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text(activityTypes[0]), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // There is still the text, but it is on the card
      final chipFinder = find.byType(Chip);
      final textOnChip = tester.widget<Text>(
          find.descendant(of: chipFinder, matching: find.byType(Text)));
      expect(chipFinder, findsOneWidget);
      expect(textOnChip.data, activityTypes[0]);
    });

    testWidgets('the choice reappear in tab if deleted', (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      // Select the first choice
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();
      expect(find.text(activityTypes[0]), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text(activityTypes[0]), findsOneWidget);

      // Delete the card
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNothing);
      expect(find.text(activityTypes[0]), findsNothing);

      // The choice is back in the list
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text(activityTypes[0]), findsOneWidget);
    });

    testWidgets('can delete a choice when multiple choices were made',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      // Add two activities
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[1]));
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsNWidgets(2));

      // Delete the first one
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // The second card is still present
      final chipFinder = find.byType(Chip);
      final textOnChip = tester.widget<Text>(
          find.descendant(of: chipFinder, matching: find.byType(Text)));
      expect(chipFinder, findsOneWidget);
      expect(textOnChip.data, activityTypes[1]);
    });

    testWidgets('can delete a choice when only one choice was made',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      // Add an activity
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsOneWidget);

      // Delete the card
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // The card is no longer present
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('type text to narrow the search in tab', (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      // The choices are Text which also exists in the Picker, so level out
      final baseNbOfTexts = find.byType(Text).evaluate().length;

      // Open the tab
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(find.byType(Text),
          findsNWidgets(baseNbOfTexts + activityTypes.length));

      // Type the first letter of the first activity
      await tester.enterText(find.byType(TextField), 'Agr');
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNWidgets(baseNbOfTexts + 1));

      // Also try not capitalizing the first letter of the activity
      await tester.enterText(find.byType(TextField), 'agr');
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNWidgets(baseNbOfTexts + 1));

      // Selecting the activity closes the tab and clears the text
      expect(find.text('agr'), findsOneWidget);
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('agr'), findsNothing);
    });

    testWidgets('typed text can be erased by the clear button', (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      // Type something
      await tester.enterText(find.byType(TextField), 'Agr');
      await tester.pumpAndSettle();
      expect(find.text('Agr'), findsOneWidget);

      // Clear the text
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('Agr'), findsNothing);
    });
  });

  group('ActivityTypesPickerFormField positioning of chips', () {
    testWidgets(
        'renders the chips over the textfield if activityTabAtTop is true',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: true)));

      // Add an activity
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      // test the chip is rendered over the textfield
      final chipFinder = find.byType(Chip);
      final textFinder = find.byType(TextField);
      expect(tester.getTopLeft(chipFinder).dy,
          lessThan(tester.getTopLeft(textFinder).dy));
    });

    testWidgets(
        'renders the chips under the textfield if activityTabAtTop is false',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(ActivityTypesPickerFormField(activityTabAtTop: false)));

      // Add an activity
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      // test the chip is rendered under the textfield
      final chipFinder = find.byType(Chip);
      final textFinder = find.byType(TextField);
      expect(tester.getTopLeft(chipFinder).dy,
          greaterThan(tester.getTopLeft(textFinder).dy));
    });
  });

  group('ActivityTypesPickerFormField validation', () {
    testWidgets('shows an error if no activity is selected', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(Form(
          key: formKey,
          child: ActivityTypesPickerFormField(activityTabAtTop: false))));

      // Try validating
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // The error is shown
      expect(
          find.text('Choisir au moins un type d\'activité.'), findsOneWidget);
    });

    testWidgets('shows no error if an activity is selected', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(Form(
          key: formKey,
          child: ActivityTypesPickerFormField(activityTabAtTop: false))));

      // Add an activity
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text(activityTypes[0]));
      await tester.pumpAndSettle();

      // Try validating
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // No error is shown
      expect(find.text('Choisir au moins un type d\'activité.'), findsNothing);
    });
  });
}
