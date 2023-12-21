import 'package:crcrme_banque_stages/common/widgets/web_site_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('WebSiteListTile', () {
    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(declareWidget(const WebSiteListTile()));

      expect(find.text('Site web'), findsOneWidget);
    });

    testWidgets('renders a custom title', (tester) async {
      await tester.pumpWidget(
          declareWidget(const WebSiteListTile(title: 'My website')));

      expect(find.text('My website'), findsOneWidget);
    });

    testWidgets('renders a mandatory indicator', (tester) async {
      await tester.pumpWidget(declareWidget(
          const WebSiteListTile(title: 'My website', isMandatory: true)));

      expect(find.text('* My website'), findsOneWidget);
    });

    testWidgets('adds https when losing focus', (tester) async {
      await tester.pumpWidget(declareWidget(
          const Column(children: [WebSiteListTile(), TextField()])));

      await tester.enterText(find.byType(TextField).first, 'www.pariterre.net');
      await tester.pumpAndSettle();

      expect(find.text('www.pariterre.net'), findsOneWidget);

      await tester.tap(find.byType(TextField).last);
      await tester.pumpAndSettle();

      expect(find.text('https://www.pariterre.net'), findsOneWidget);
    });

    testWidgets('can initialize', (tester) async {
      await tester.pumpWidget(declareWidget(const Column(
          children: [WebSiteListTile(initialValue: 'pariterre.net')])));

      expect(find.text('https://pariterre.net'), findsOneWidget);
    });

    testWidgets('renders a text field when enabled', (tester) async {
      await tester.pumpWidget(declareWidget(
          const WebSiteListTile(isMandatory: false, enabled: true)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);

      await tester.pumpWidget(declareWidget(
          const WebSiteListTile(isMandatory: false, enabled: false)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('can dynamically change the website', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(declareWidget(WebSiteListTile(
        controller: controller,
        isMandatory: false,
        enabled: true,
      )));

      expect(find.text(''), findsOneWidget);

      controller.text = 'pariterre.net';
      await tester.pumpAndSettle();

      expect(find.text('pariterre.net'), findsOneWidget);
    });

    testWidgets('on save add the https', (tester) async {
      final formKey = GlobalKey<FormState>();
      String? value;
      await tester.pumpWidget(declareWidget(Form(
        key: formKey,
        child: WebSiteListTile(
          onSaved: (v) => value = v,
          isMandatory: false,
          enabled: true,
        ),
      )));

      await tester.enterText(find.byType(TextField), 'pariterre.net');
      await tester.pumpAndSettle();

      formKey.currentState!.save();

      expect(value, 'https://pariterre.net');
    });
  });
}
