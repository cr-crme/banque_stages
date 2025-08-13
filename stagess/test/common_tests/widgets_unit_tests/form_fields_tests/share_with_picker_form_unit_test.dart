import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagess/common/widgets/form_fields/share_with_picker_form_field.dart';

import '../utils.dart';

void main() {
  group('ShareWithPickerFormField', () {
    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      expect(find.text('* Partager l\'entreprise avec'), findsOneWidget);
    });

    testWidgets('default selection is PFAE', (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      expect(find.text('Enseignants PFAE de l\'école'), findsOneWidget);
    });

    testWidgets('tapping on the textfield reveals the selection box',
        (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      final nbText = tester.widgetList(find.byType(Text)).length;

      // Tap on the textfield
      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(tester.widgetList(find.byType(Text)).length,
          nbText + shareWithSuggestions.length);
    });

    testWidgets('selecting a choice moves it to the textfield', (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      // Default value
      expect(find.text(shareWithSuggestions[1]), findsOneWidget);

      // Tap on the textfield
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Tap on the first choice
      await tester.tap(find.text(shareWithSuggestions[0]));
      await tester.pump();

      expect(find.text(shareWithSuggestions[0]), findsOneWidget);
      expect(find.text(shareWithSuggestions[1]), findsNothing);
    });

    testWidgets('cannot change the selection by typing', (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      // Default value
      expect(find.text(shareWithSuggestions[1]), findsOneWidget);

      // Type a new value
      await tester.enterText(find.byType(TextField), 'My new selection');
      await tester.pump();

      // The value should not have changed
      expect(find.text(shareWithSuggestions[1]), findsNWidgets(2));
      expect(find.text('My new selection'), findsNothing);
    });

    testWidgets('can clear selection using the icon', (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      // Default value
      expect(find.text(shareWithSuggestions[1]), findsOneWidget);

      // Tap the clear icon
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // The value should be cleared
      expect(find.text(shareWithSuggestions[1]), findsNothing);
    });

    testWidgets('clearing closes the selection box', (tester) async {
      await tester.pumpWidget(declareWidget(const ShareWithPickerFormField()));

      // Tap on the textfield
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Tap the clear icon
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // The selection box should be closed
      expect(find.text(shareWithSuggestions[0]), findsNothing);
    });

    testWidgets('validation fails if text is empty', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(
          Form(key: formKey, child: const ShareWithPickerFormField())));

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('Sélectionner avec qui partager'), findsOneWidget);
    });

    testWidgets('validation succeeds if text is not empty', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(
          Form(key: formKey, child: const ShareWithPickerFormField())));

      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();

      expect(find.text('Sélectionner avec qui partager'), findsNothing);
    });

    testWidgets('"onSaved" callback is call if the form is saved',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      String? shareWith = 'initialValue';
      await tester.pumpWidget(declareWidget(Form(
        key: formKey,
        child: ShareWithPickerFormField(
          onSaved: (value) => shareWith = value,
        ),
      )));

      expect(shareWith, 'initialValue');

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      formKey.currentState!.save();
      await tester.pump();
      expect(shareWith, isNull);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.tap(find.text(shareWithSuggestions[0]));
      await tester.pump();
      formKey.currentState!.save();
      await tester.pump();
      expect(shareWith, shareWithSuggestions[0]);
    });
  });
}
