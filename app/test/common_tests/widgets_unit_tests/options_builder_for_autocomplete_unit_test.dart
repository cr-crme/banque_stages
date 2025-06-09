import 'package:common_flutter/widgets/autocomplete_options_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

enum _Options {
  option1,
  option2,
  option3,
  option4;

  @override
  String toString() {
    switch (this) {
      case _Options.option1:
        return 'My first option';
      case _Options.option2:
        return 'My second option';
      case _Options.option3:
        return 'My third option';
      case _Options.option4:
        return 'My fourth option';
    }
  }
}

void main() {
  group('OptionsBuilderForAutocomplete', () {
    testWidgets('options are showed', (tester) async {
      await tester
          .pumpWidget(declareWidget(OptionsBuilderForAutocomplete<_Options>(
        onSelected: (option) {},
        optionToString: (p0) => p0.toString(),
        options: _Options.values,
      )));

      expect(find.text('My first option'), findsOneWidget);
      expect(find.text('My second option'), findsOneWidget);
      expect(find.text('My third option'), findsOneWidget);
      expect(find.text('My fourth option'), findsOneWidget);
    });

    testWidgets('can select an option', (tester) async {
      _Options? selectedOption;
      await tester
          .pumpWidget(declareWidget(OptionsBuilderForAutocomplete<_Options>(
        onSelected: (option) => selectedOption = option,
        optionToString: (p0) => p0.toString(),
        options: _Options.values,
      )));

      await tester.tap(find.text('My first option'));
      await tester.pumpAndSettle();
      expect(selectedOption, _Options.option1);

      await tester.tap(find.text('My second option'));
      await tester.pumpAndSettle();
      expect(selectedOption, _Options.option2);
    });
  });
}
