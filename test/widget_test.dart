// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Build our app and trigger a frame.
// await tester.pumpWidget(ChangeNotifierProvider<TeachersProvider>(
//   create: (context) => TeachersProvider(),
//   child: ChangeNotifierProvider<StudentsProvider>(
//       create: (context) => StudentsProvider(),
//       child: MaterialApp(
//           builder: (context, child) => const StudentsListScreen())),
// ));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  initializeProgram(mockFirebase: true);

  testWidgets('Opening page and loading data', (WidgetTester tester) async {
    // Load the app and navigate to the home page.
    await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

    // Verify that the home page is "My students"
    expect(find.text('Mes élèves'), findsOneWidget);

    // Find and open the drawer
    final drawerIcon = find.byIcon(Icons.menu);
    expect(drawerIcon, findsOneWidget);
    await tester.tap(drawerIcon);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text('Tableau des supervisions'), findsOneWidget);

    // // Open the drawer
    // await tester.tap(find.byIcon(Icons.menu));
    // expect(find.text('Tableau des supervisions'), findsOneWidget);

    // expect(find.text('1'), findsNothing);

    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
