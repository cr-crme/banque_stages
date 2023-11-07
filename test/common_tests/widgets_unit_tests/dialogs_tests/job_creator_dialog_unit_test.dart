import 'package:crcrme_banque_stages/common/widgets/dialogs/job_creator_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('JobCreatorDialog', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      expect(find.text('Ajouter un nouveau poste'), findsOneWidget);
    });

    testWidgets('renders a JobFormFieldListTile', (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      expect(find.byType(JobFormFieldListTile), findsOneWidget);
    });

    testWidgets('should display a cancel button', (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      final cancelFinder = find.byType(OutlinedButton);
      expect(find.byType(OutlinedButton), findsOneWidget);

      final textFinder =
          find.descendant(of: cancelFinder, matching: find.byType(Text));
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.data, 'Annuler');
    });

    testWidgets('should display a confirm button', (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      final confirmFinder = find.byType(TextButton);
      expect(confirmFinder, findsOneWidget);

      final textFinder =
          find.descendant(of: confirmFinder, matching: find.byType(Text));
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.data, 'Confirmer');
    });

    testWidgets('can cancel', (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      // Drag the screen up to reveal the cancel button
      await tester.drag(find.byType(JobCreatorDialog), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // The dialog should be closed
      expect(find.byType(JobCreatorDialog), findsNothing);
    });

    testWidgets(
        'confirming is refused with snackbar if not all mandatory fields are filled',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      // Drag the screen up to reveal the cancel button
      await tester.drag(find.byType(JobCreatorDialog), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      // The dialog should still be open
      expect(find.byType(JobCreatorDialog), findsOneWidget);

      // A snackbar should be displayed
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('confirming is accepted if a valid values are entered',
        (tester) async {
      await tester.pumpWidget(
          declareWidget(JobCreatorDialog(enterprise: dummyEnterprise())));

      // Enter a specialization
      final textFinders = find.byType(TextField);
      await tester.tap(textFinders.at(0));
      await tester.pump();
      await tester.tap(find.text(ActivitySectorsService.allSpecializations
          .where((e) => e.id == '8349')
          .first
          .idWithName));
      await tester.pump();

      // Enter an age
      await tester.enterText(find.byType(TextField).at(1), '15');
      await tester.pump();

      // Add at least one position
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Drag the screen up to reveal the rest of the form
      await tester.drag(find.byType(JobCreatorDialog), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Add uniform and equipment
      final noFinders = find.text('Non');
      expect(noFinders, findsNWidgets(2));
      await tester.tap(noFinders.first);
      await tester.pump();
      await tester.tap(noFinders.last);
      await tester.pump();

      // Validate
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      // The dialog should still be open
      expect(find.byType(JobCreatorDialog), findsNothing);
    });
  });
}
