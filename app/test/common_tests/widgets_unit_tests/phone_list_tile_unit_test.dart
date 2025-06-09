import 'package:common_flutter/widgets/phone_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  group('PhoneListTile', () {
    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(declareWidget(const PhoneListTile(
          title: 'My phone test', isMandatory: false, enabled: true)));

      expect(find.text('My phone test'), findsOneWidget);
    });

    testWidgets('renders a mandatory indicator', (tester) async {
      await tester.pumpWidget(declareWidget(const PhoneListTile(
          title: 'My phone test', isMandatory: true, enabled: true)));

      expect(find.text('* My phone test'), findsOneWidget);
    });

    testWidgets('can initialize', (tester) async {
      await tester.pumpWidget(declareWidget(PhoneListTile(
          title: 'My phone test',
          initialValue: dummyPhoneNumber(),
          isMandatory: false,
          enabled: true)));

      expect(find.text(dummyPhoneNumber().toString()), findsOneWidget);
    });

    testWidgets('the form validates properly when not mandatory',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      bool isValidated = false;
      await tester.pumpWidget(declareWidget(Form(
        key: formKey,
        child: PhoneListTile(
          isMandatory: false,
          enabled: true,
          onSaved: (value) => isValidated = true,
        ),
      )));
      // Submit the form
      expect(formKey.currentState!.validate(), isTrue);

      // Type something in the text field
      await tester.enterText(
          find.byType(TextFormField), dummyPhoneNumber().toString());

      // Submit the form
      expect(formKey.currentState!.validate(), isTrue);

      // Saving the form calls validate
      await tester.runAsync(() async {
        isValidated = false;
        formKey.currentState!.save();
        await Future.delayed(const Duration(milliseconds: 50));
        expect(isValidated, isTrue);
      });
    });

    testWidgets('the form validates properly when mandatory', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(Column(
        children: [
          Form(
              key: formKey,
              child: const PhoneListTile(isMandatory: true, enabled: true)),
          const TextField(),
        ],
      )));
      expect(formKey.currentState!.validate(), isFalse);

      // Type something in the text field that will be change after tapping out
      await tester.enterText(find.byType(TextFormField), '1234567890');
      await tester.tap(find.byType(TextField).last);

      // Submit the form
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('renders a text field when enabled', (tester) async {
      await tester.pumpWidget(declareWidget(
          const PhoneListTile(isMandatory: false, enabled: true)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

      await tester.pumpWidget(declareWidget(
          const PhoneListTile(isMandatory: false, enabled: false)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('unfocussing the text field calls validate', (tester) async {
      await tester.pumpWidget(declareWidget(const Column(
        children: [
          PhoneListTile(isMandatory: true, enabled: true),
          TextField(),
        ],
      )));

      // Type something in the text field that will be change after tapping out
      await tester.enterText(find.byType(TextFormField), '1234567890');
      expect(find.text('1234567890'), findsOneWidget);

      // Tapping out the text field when empty does not validate
      await tester.tap(find.byType(TextField).last);
      await tester.pump();
      expect(find.text('(123) 456-7890'), findsOneWidget);
    });

    testWidgets('refuses the validation if phone number is invalid',
        (tester) async {
      await tester.pumpWidget(declareWidget(const Column(
        children: [
          PhoneListTile(isMandatory: true, enabled: true),
          TextField(),
        ],
      )));

      await tester.enterText(find.byType(TextFormField), '123456789');
      expect(find.text('123456789'), findsOneWidget);

      // Tapping out the text field when empty does not validate
      await tester.tap(find.byType(TextField).last);
      await tester.pump();
      expect(find.text('123456789'), findsOneWidget);
    });
  });
}
