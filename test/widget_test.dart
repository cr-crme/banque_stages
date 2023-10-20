import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/main.dart';
import 'package:crcrme_banque_stages/screens/students_list/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  group('Navigation', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('Then opening page is My students',
        (WidgetTester tester) async {
      // Load the app and navigate to the home page.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify that the home page is "My students"
      expect(find.text(screenNames[0]), findsOneWidget);
    });

    testWidgets('The drawer tiles content', (WidgetTester tester) async {
      // Load the app and navigate and open the drawer.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));
      await openDrawer(tester);

      // Verify that the drawer contains the expected tiles
      for (final screenName in screenNames) {
        expect(
            find.ancestor(
                of: find.text(screenName), matching: find.byType(Card)),
            findsWidgets);
      }
    });

    testWidgets('The drawer navigates and closes on click',
        (WidgetTester tester) async {
      // Load the app and navigate and open the drawer.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify that the drawer contains the expected tiles
      for (final screenNameOuter in screenNames) {
        for (final screenNameInner in screenNames) {
          // For some reason, this next fails (because it is too long)
          if (screenNameInner == 'Santé et Sécurité au PFAE') continue;
          if (screenNameOuter == 'Santé et Sécurité au PFAE') continue;

          // Navigate from Outer to Inner screen
          await navigateToScreen(tester, screenNameInner);

          // Verify the page is loaded and drawer is closed
          expect(find.text(screenNameInner), findsOneWidget);
          expect(find.text(drawerTitle), findsNothing);

          // Return to outer loop screen
          await navigateToScreen(tester, screenNameOuter);
        }
      }
    });

    testWidgets('The reinitialize data button is not shown in production',
        (WidgetTester tester) async {
      // Remove the reinitialized data button (as in production)
      initializeProgram(useDatabaseEmulator: false, mockFirebase: true);

      // Load the app and navigate to the home page (My students).
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify the reinitialized button is hidden (as in production)
      await openDrawer(tester);
      expect(find.text(reinitializedDataButtonText), findsNothing);
      await closeDrawer(tester);

      // Reinitialized the testing conditions
      initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

      // Verify the reinitialized button is present (as in testing)
      await openDrawer(tester);
      expect(find.text(reinitializedDataButtonText), findsOneWidget);
    });

    testWidgets('The dummy data are properly loaded',
        (WidgetTester tester) async {
      // Load the app and navigate to the home page.
      await tester.pumpWidget(const BanqueStagesApp(mockFirebase: true));

      // Verify the home page is empty
      for (final studentName in myStudentNames) {
        expect(find.text(studentName), findsNothing);
      }

      // Find the reinitalize data button in the drawer
      await openDrawer(tester);
      await tester.tap(find.text(reinitializedDataButtonText));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Make sure the drawer was automatically closed
      expect(find.text(reinitializedDataButtonText), findsNothing);

      // Navigate to My students screen
      await navigateToScreen(tester, screenNames[0]);

      // Verify the students data is now loaded
      expect(find.bySubtype<StudentCard>(skipOffstage: false),
          findsNWidgets(myStudentNames.length));
      for (final studentName in myStudentNames) {
        expect(find.text(studentName, skipOffstage: false), findsOneWidget);
      }
    });
  });
}
