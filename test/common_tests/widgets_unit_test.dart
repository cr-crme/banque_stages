import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:crcrme_banque_stages/common/widgets/add_job_button.dart';
import 'package:crcrme_banque_stages/common/widgets/address_list_tile.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'utils.dart';

///
/// [loadTheme] will use the CR-CRME theme. This however connects to GoogleFonts
/// which is incompatible with true async tests.
Widget _declareWidget(Widget child, {bool loadTheme = false}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
    theme: loadTheme ? crcrmeMaterialTheme : null,
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

  group('AddressListTile', () {
    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(_declareWidget(AddressListTile(
        title: 'Mon adresse de test',
        addressController: AddressController(),
        isMandatory: false,
        enabled: true,
      )));

      expect(find.text('Mon adresse de test'), findsOneWidget);
    });

    testWidgets('renders a mandatory indicator', (tester) async {
      await tester.pumpWidget(_declareWidget(AddressListTile(
        title: 'Mon adresse de test',
        addressController: AddressController(),
        isMandatory: true,
        enabled: true,
      )));

      expect(find.text('* Mon adresse de test'), findsOneWidget);
    });

    testWidgets('renders a search icon when address is empty', (tester) async {
      await tester.pumpWidget(_declareWidget(AddressListTile(
        addressController: AddressController(),
        isMandatory: false,
        enabled: true,
      )));

      // There are two search icon so we can control the color
      expect(find.byIcon(Icons.search), findsNWidgets(2));
    });

    testWidgets('renders a map icon when address is not empty', (tester) async {
      await tester.pumpWidget(_declareWidget(AddressListTile(
        addressController: AddressController(initialValue: dummyAddress()),
        isMandatory: false,
        enabled: true,
      )));

      // There are two search icon so we can control the color
      expect(find.byIcon(Icons.map), findsNWidgets(2));
    });

    testWidgets('icon is grey when address is empty, colored otherwise',
        (tester) async {
      final controller = AddressController();
      await tester.pumpWidget(_declareWidget(
          AddressListTile(
            addressController: controller,
            isMandatory: false,
            enabled: true,
          ),
          loadTheme: true));

      // Make sure the appareance is correct
      expect(tester.widget<Icon>(find.byIcon(Icons.search).last).color,
          Colors.grey);

      // Type something in the text field
      final formFinder = find.byType(TextFormField);
      await tester.enterText(formFinder, 'My new address');
      await tester.pump();

      expect(tester.widget<Icon>(find.byIcon(Icons.search).last).color,
          Theme.of(tester.context(formFinder)).primaryColor);
    });

    testWidgets('the form validates properly when not mandatory',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      bool isValidated = false;
      bool first = true;
      final controller = AddressController(
        onAddressChangedCallback: () => isValidated = true,
        fromStringOverrideForDebug: (_) async {
          final out = dummyAddress(skipAppartment: first);
          first = false;
          return out;
        },
        confirmAddressForDebug: (_) => true,
      );
      await tester.pumpWidget(_declareWidget(Form(
        key: formKey,
        child: AddressListTile(
          addressController: controller,
          isMandatory: false,
          enabled: true,
        ),
      )));
      // Submit the form
      expect(formKey.currentState!.validate(), isTrue);

      // Type something in the text field
      controller.address = dummyAddress();

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
      bool isValidated = false;
      bool first = true;
      final controller = AddressController(
        onAddressChangedCallback: () => isValidated = true,
        fromStringOverrideForDebug: (_) async {
          final out = dummyAddress(skipAppartment: first);
          first = false;
          return out;
        },
        confirmAddressForDebug: (_) => true,
      );
      await tester.pumpWidget(_declareWidget(Form(
        key: formKey,
        child: AddressListTile(
          addressController: controller,
          isMandatory: true,
          enabled: true,
        ),
      )));
      // Submit the form
      expect(formKey.currentState!.validate(), isFalse);

      // Type something in the text field
      controller.address = dummyAddress();

      // Submit the form
      expect(formKey.currentState!.validate(), isTrue);

      // Saving the form calls validate
      await tester.runAsync(() async {
        isValidated = false;
        formKey.currentState!.save();
        await Future.delayed(const Duration(milliseconds: 5));
        expect(isValidated, isTrue);
      });
    });

    testWidgets('unfocussing the text field calls validate', (tester) async {
      final formKey = GlobalKey<FormState>();
      bool isValidated = false;
      final controller = AddressController(
        onAddressChangedCallback: () => isValidated = true,
        fromStringOverrideForDebug: (_) async => dummyAddress(),
        confirmAddressForDebug: (_) => true,
      );
      await tester.pumpWidget(_declareWidget(Form(
        key: formKey,
        child: Column(
          children: [
            AddressListTile(
              addressController: controller,
              isMandatory: false,
              enabled: true,
            ),
            const TextField(),
          ],
        ),
      )));

      await tester.runAsync(() async {
        // Tapping in never triggers
        isValidated = false;
        await tester.tap(find.byType(TextFormField));
        await Future.delayed(const Duration(milliseconds: 5));
        expect(isValidated, isFalse);
      });
      await tester.runAsync(() async {
        // Tapping out the text field when empty does not validate
        isValidated = false;
        await tester.tap(find.byType(TextField).last);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(isValidated, isFalse);
      });

      await tester.runAsync(() async {
        // Tapping in the text field when not empty does validate
        isValidated = false;
        await tester.enterText(find.byType(TextFormField), 'My new address');
        await tester.tap(find.byType(TextFormField).last);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(isValidated, isFalse);
      });
      await tester.runAsync(() async {
        // Tapping out the text field when not empty does validate
        isValidated = false;
        await tester.enterText(find.byType(TextFormField), 'My new address');
        await tester.tap(find.byType(TextField).last);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(isValidated, isTrue);
      });
    });

    testWidgets('renders a text field when enabled', (tester) async {
      await tester.pumpWidget(_declareWidget(AddressListTile(
        addressController: AddressController(),
        isMandatory: false,
        enabled: true,
      )));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

      await tester.pumpWidget(_declareWidget(AddressListTile(
        addressController: AddressController(),
        isMandatory: false,
        enabled: false,
      )));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('can dynamically change the address', (tester) async {
      final addressController = AddressController();
      await tester.pumpWidget(_declareWidget(AddressListTile(
        addressController: addressController,
        isMandatory: false,
        enabled: true,
      )));

      expect(find.text(''), findsOneWidget);
      expect(addressController.address?.toString() ?? '', '');

      addressController.address = dummyAddress();
      await tester.pumpAndSettle();
      expect(find.text(dummyAddress().toString()), findsOneWidget);
      expect(addressController.address.toString(), dummyAddress().toString());
    });

    testWidgets('can validate the address while not being mandatory',
        (tester) async {
      await tester.runAsync(() async {
        bool addressHasChanged = false;

        final addressController = AddressController(
          onAddressChangedCallback: () {
            return addressHasChanged = true;
          },
          fromStringOverrideForDebug: (_) async => dummyAddress(),
          confirmAddressForDebug: (_) => true,
        );
        await tester.pumpWidget(_declareWidget(
          AddressListTile(
            addressController: addressController,
            isMandatory: false,
            enabled: true,
          ),
        ));
        // Address is valid, even though it is empty
        expect(await addressController.requestValidation(), null);

        // Make a change to the address, which automatically triggers the
        // validation request. But also call it manually so they collide,
        // effectively testing the mutex
        addressHasChanged = false;
        addressController.address = dummyAddress(skipAppartment: true);
        expect(await addressController.requestValidation(), null);
        expect(addressHasChanged, isTrue);
      });
    });

    testWidgets('can validate the address while being mandatory',
        (tester) async {
      final addressController = AddressController(
        fromStringOverrideForDebug: (_) async => dummyAddress(),
      );
      await tester.pumpWidget(_declareWidget(
        AddressListTile(
          addressController: addressController,
          isMandatory: true,
          enabled: true,
        ),
      ));
      // Address is valid, even though it is empty
      expect(await addressController.requestValidation(),
          'Entrer une adresse valide');
    });

    testWidgets('refuses the validation if address is invalid', (tester) async {
      await tester.runAsync(() async {
        final addressController = AddressController(
          fromStringOverrideForDebug: (_) async => throw 'Invalid address',
        );
        await tester.pumpWidget(_declareWidget(
          AddressListTile(
            addressController: addressController,
            isMandatory: false,
            enabled: true,
          ),
        ));
        // Address is valid, even though it is empty
        addressController.address = dummyAddress(skipAppartment: true);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(await addressController.requestValidation(),
            'L\'adresse n\'a pu être trouvée');
      });
    });

    testWidgets('refuses the validation if address is refused by the user',
        (tester) async {
      await tester.runAsync(() async {
        final addressController = AddressController(
          fromStringOverrideForDebug: (_) async => dummyAddress(),
          confirmAddressForDebug: (_) => false,
        );
        await tester.pumpWidget(_declareWidget(
          AddressListTile(
            addressController: addressController,
            isMandatory: false,
            enabled: true,
          ),
        ));
        // Address is valid, even though it is empty
        addressController.address = dummyAddress(skipAppartment: true);
        await Future.delayed(const Duration(milliseconds: 5));
        expect(await addressController.requestValidation(),
            'Essayer une nouvelle adresse');
      });
    });
  });
}
