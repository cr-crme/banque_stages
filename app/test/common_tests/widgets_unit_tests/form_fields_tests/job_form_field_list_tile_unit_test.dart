import 'package:common/models/enterprises/job.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/widgets/checkbox_with_other.dart';
import 'package:common_flutter/widgets/radio_with_follow_up.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:crcrme_banque_stages/program_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../utils.dart';
import '../utils.dart';

Map<Specialization, int> _formattingSpecialization(
    Iterable<Specialization> specializations) {
  final Map<Specialization, int> out = {};
  for (final specialization in specializations) {
    out[specialization] = 1;
  }
  return out;
}

Future<void> fillAllJobFormFieldsListTile(
  WidgetTester tester, {
  bool skipJob = false,
  bool skipAge = false,
  bool skipAvailability = false,
  bool skipPrerequisites = false,
  bool skipUniform = false,
  bool skipEquipment = false,
}) async {
  // Sanity check
  expect(find.byType(JobFormFieldListTile), findsOneWidget);
  expect(find.byType(TextField), findsNWidgets(3));

  int nextTextFieldIndex = 0;
  int nextOtherIndex = 0;

  // Enter a specialization
  if (!skipJob) {
    await tester.tap(find.byType(TextField).at(nextTextFieldIndex));
    await tester.pump();
    await tester.tap(find.text(ActivitySectorsService.allSpecializations
        .where((e) => e.id == '8349')
        .first
        .idWithName));
    await tester.pump();
    nextTextFieldIndex++;
  }

  // Enter an age
  if (!skipAge) {
    await tester.enterText(find.byType(TextField).at(nextTextFieldIndex), '15');
    await tester.pump();
    nextTextFieldIndex++;
  }

  // Add at least one position
  if (!skipAvailability) {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  }
  nextTextFieldIndex++;

  // Drag the screen up to reveal the rest of the form
  await tester.drag(
      find.byType(SingleChildScrollView).first, const Offset(0, -500));
  await tester.pumpAndSettle();

  // Add prerequisites
  if (!skipPrerequisites) {
    await tester
        .tap(find.text(PreInternshipRequestTypes.soloInterview.toString()));
    await tester.pump();
    await tester.tap(find.text('Autre').at(0));
    await tester.pump();
    await tester.enterText(
        find.byType(TextField).at(nextTextFieldIndex), 'My prerequisite');
    await tester.pump();
    nextTextFieldIndex++;
  }
  nextOtherIndex++;

  // Add uniform
  if (!skipUniform) {
    await tester.tap(find.text(UniformStatus.suppliedByStudent.toString()));
    await tester.pump();
    await tester.enterText(
        find.byType(TextField).at(nextTextFieldIndex), 'My uniform');
    await tester.pump();

    // Drag the screen up to reveal the rest of the form
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    nextTextFieldIndex++;
  }

  // Add protection equipment
  if (!skipEquipment) {
    await tester
        .tap(find.text(ProtectionsStatus.suppliedByEnterprise.toString()));
    await tester.pump();

    // Drag the screen up to reveal the rest of the form
    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.text(ProtectionsType.steelToeShoes.toString()));
    await tester.pump();
    await tester.tap(find.text('Autre').at(nextOtherIndex));
    await tester.pump();
    await tester.enterText(
        find.byType(TextField).at(nextTextFieldIndex), 'My equipment');
    await tester.pump();

    await tester.drag(
        find.byType(SingleChildScrollView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    nextTextFieldIndex++;
    nextOtherIndex++;
  }
}

void main() {
  group('JobFormFieldListTile jobs', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      expect(find.text('* Métier semi-spécialisé'), findsOneWidget);
    });

    testWidgets('renders an hint when tapped', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.text('Saisir nom ou n° de métier'), findsOneWidget);
    });

    testWidgets('can narrow the selection by typing', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));
      final nbInkWellBase = find.byType(InkWell).evaluate().length;

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(
          find.byType(InkWell),
          findsNWidgets(nbInkWellBase +
              ActivitySectorsService.allSpecializations.length));

      await tester.enterText(find.byType(TextField).first, 'aide');
      await tester.pumpAndSettle();
      expect(find.byType(InkWell), findsNWidgets(nbInkWellBase + 29));

      await tester.enterText(find.byType(TextField).first, '8166');
      await tester.pumpAndSettle();
      expect(find.byType(InkWell), findsNWidgets(nbInkWellBase + 1));
    });

    testWidgets('all of them is the default', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      final nbInkWellBase = find.byType(InkWell).evaluate().length;

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(
          find.byType(InkWell),
          findsNWidgets(nbInkWellBase +
              ActivitySectorsService.allSpecializations.length));
    });

    testWidgets('can request a subset to pick from', (tester) async {
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: JobFormFieldListTile(
        specializations: _formattingSpecialization(
            ActivitySectorsService.allSpecializations.sublist(0, 10)),
      ))));

      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).first)
              .enabled,
          isTrue);

      final nbInkWellBase = find.byType(InkWell).evaluate().length;

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsNWidgets(nbInkWellBase + 10));
    });

    testWidgets(
        'if there is only one choice it should be automatically selected',
        (tester) async {
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: JobFormFieldListTile(
        specializations: _formattingSpecialization(
            ActivitySectorsService.allSpecializations.sublist(0, 1)),
      ))));

      expect(find.text(ActivitySectorsService.allSpecializations[0].idWithName),
          findsOneWidget);

      expect(
          tester
              .widget<TextFormField>(find.byType(TextFormField).first)
              .enabled,
          isFalse);
    });

    testWidgets('can clear text by tapping clear icon', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'aide');
      await tester.pumpAndSettle();
      expect(find.text('aide'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('aide'), findsNothing);
    });

    testWidgets(
        'tapping a choice moves it to the textfield and closes the choice view',
        (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));
      final choiceToTap = ActivitySectorsService.allSpecializations
          .firstWhere((e) => e.id == '8345')
          .idWithName;
      final choiceToControl = ActivitySectorsService.allSpecializations
          .firstWhere((e) => e.id == '8166')
          .idWithName;

      await tester.tap(find.byType(TextFormField).first);
      await tester.pumpAndSettle();

      expect(find.text(choiceToTap), findsOneWidget);
      expect(find.text(choiceToControl), findsOneWidget);

      await tester.tap(find.text(choiceToTap));
      await tester.pumpAndSettle();

      expect(find.text(choiceToTap), findsOneWidget); // In textview
      expect(find.text(choiceToControl), findsNothing);
    });

    testWidgets('confirming is refused if nothing is entered', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(key: formKey, child: const JobFormFieldListTile()))));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Sélectionner un métier.'), findsOneWidget);
    });

    testWidgets(
        'confirming is refused if the user did not actively selected a value',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(key: formKey, child: const JobFormFieldListTile()))));

      final textToTap = ActivitySectorsService.allSpecializations
          .firstWhere((e) => e.id == '8345')
          .idWithName;
      await tester.enterText(find.byType(TextField).first, textToTap);
      await tester.pump();

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Sélectionner un métier.'), findsOneWidget);
    });

    testWidgets('confirming is accepted if a valid value is entered',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(key: formKey, child: const JobFormFieldListTile()))));

      await tester.tap(find.byType(TextFormField).at(0));
      await tester.pumpAndSettle();

      await tester.tap(find.text(ActivitySectorsService.allSpecializations
          .firstWhere((e) => e.id == '8345')
          .idWithName));
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Sélectionner un métier.'), findsNothing);
    });
  });

  group('JobFormFieldListTile minimum age', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      expect(find.text('* Âge minimum des stagiaires (ans)'), findsOneWidget);
    });

    testWidgets('validation fails if no age is entered', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(key: formKey, child: const JobFormFieldListTile()))));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Préciser'), findsOneWidget);
    });

    testWidgets('validation fails if age is outside bounds', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(key: formKey, child: const JobFormFieldListTile()))));

      await tester.enterText(find.byType(TextField).at(1), '9');
      await tester.pump();
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Entre 10 et 30'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(1), '10');
      await tester.pump();
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Entre 10 et 30'), findsNothing);

      await tester.enterText(find.byType(TextField).at(1), '31');
      await tester.pump();
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Entre 10 et 30'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(1), '30');
      await tester.pump();
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Entre 10 et 30'), findsNothing);
    });
  });

  group('JobFormFieldListTile availability', () {
    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      expect(find.text('* Places de stages disponibles'), findsOneWidget);
    });

    testWidgets('can increase an decrease number of places', (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // Cannot go under 1
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('validation fails if none is selected, success otherwise',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(key: formKey, child: const JobFormFieldListTile()))));

      expect(find.text('Combien\u00a0?'), findsNothing);

      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Combien\u00a0?'), findsOneWidget);

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('Combien\u00a0?'), findsNothing);
    });
  });

  group('JobFormFieldListTile BuildPrerequisitesCheckboxes', () {
    testWidgets('is of type CheckboxWithOtherState with proper title',
        (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      final prerequisitesFinder = find.bySubtype<CheckboxWithOther>().first;
      final prerequisites =
          tester.widget<CheckboxWithOther>(prerequisitesFinder);

      expect(
          find.text(
              '* Exigences de l\'entreprise avant d\'accueillir des élèves en stage:'),
          findsOneWidget);
      expect(prerequisites.title,
          '* Exigences de l\'entreprise avant d\'accueillir des élèves en stage:');
      expect(prerequisites.titleStyle,
          Theme.of(tester.context(prerequisitesFinder)).textTheme.bodyLarge);
    });

    testWidgets('can hide the title', (tester) async {
      final key =
          GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>();
      await tester.pumpWidget(declareWidget(
          BuildPrerequisitesCheckboxes(checkBoxKey: key, hideTitle: true)));

      expect(
          find.text(
              '* Exigences de l\'entreprise avant d\'accueillir des élèves en stage:'),
          findsNothing);
    });

    testWidgets('can initialize values', (tester) async {
      final key =
          GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>();
      await tester.pumpWidget(declareWidget(BuildPrerequisitesCheckboxes(
          checkBoxKey: key,
          hideTitle: true,
          initialValues: [
            PreInternshipRequestTypes.soloInterview.toString()
          ])));

      for (final checkbox in tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))) {
        if ((checkbox.title as Text).data ==
            PreInternshipRequestTypes.soloInterview.toString()) {
          expect(checkbox.value, isTrue);
        } else {
          expect(checkbox.value, isFalse);
        }
      }
    });
  });

  group('JobFormFieldListTile BuildUniformRadio', () {
    testWidgets('is of type RadioWithFollowUp with proper title',
        (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      final uniformFinder = find.bySubtype<RadioWithFollowUp>().first;
      final uniform = tester.widget<RadioWithFollowUp>(uniformFinder);

      expect(
          find.text(
              '* Est-ce qu\'une tenue de travail spécifique est exigée pour ce poste\u00a0?'),
          findsOneWidget);
      expect(uniform.title,
          '* Est-ce qu\'une tenue de travail spécifique est exigée pour ce poste\u00a0?');
      expect(uniform.titleStyle,
          Theme.of(tester.context(uniformFinder)).textTheme.bodyLarge);
    });

    testWidgets('choices are UniformStatus', (tester) async {
      final key = GlobalKey<RadioWithFollowUpState<UniformStatus>>();
      final uniformTextController = TextEditingController();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: BuildUniformRadio(
        uniformKey: key,
        uniformTextController: uniformTextController,
      ))));

      final uniformFinder = find.bySubtype<RadioWithFollowUp>().first;
      final uniform = tester.widget<RadioWithFollowUp>(uniformFinder);

      for (int i = 0; i < uniform.elements.length; i++) {
        expect(
            uniform.elements[i].toString(), UniformStatus.values[i].toString());
      }
    });

    testWidgets('all choices except None trigger the follow up',
        (tester) async {
      final key = GlobalKey<RadioWithFollowUpState<UniformStatus>>();
      final uniformTextController = TextEditingController();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: BuildUniformRadio(
        uniformKey: key,
        uniformTextController: uniformTextController,
      ))));

      final uniformFinder = find.bySubtype<RadioWithFollowUp>().first;
      final uniform = tester.widget<RadioWithFollowUp>(uniformFinder);

      expect(find.byType(TextFormField), findsNothing);

      for (int i = 0; i < uniform.elements.length; i++) {
        await tester.tap(find.text(uniform.elements[i].toString()));
        await tester.pump();

        if (uniform.elements[i] == UniformStatus.none) {
          expect(find.byType(TextFormField), findsNothing);
        } else {
          expect(find.byType(TextFormField), findsOneWidget);
        }
      }
    });

    testWidgets(
        'validate fails if nothing is selected or if the follow up is left empty',
        (tester) async {
      await tester.binding.setSurfaceSize(Size(400, 1080));

      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the uniform
      await fillAllJobFormFieldsListTile(tester, skipUniform: true);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      // Fill the uniform but not the follow up
      for (int i = 0; i < UniformStatus.values.length; i++) {
        // First refers to "Non" which appear twice (once in uniform and once in protections)
        await tester.tap(find.text(UniformStatus.values[i].toString()).first);
        await tester.pumpAndSettle();

        if (UniformStatus.values[i] == UniformStatus.none) {
          expect(formKey.currentState!.validate(), isTrue);
          await tester.pump();
          expect(find.text('Décrire la tenue de travail.'), findsNothing);
        } else {
          expect(formKey.currentState!.validate(), isFalse);
          await tester.pump();
          expect(find.text('Décrire la tenue de travail.'), findsOneWidget);
        }
      }

      // Fill the follow up
      await tester.tap(find.text(UniformStatus.values[0].toString()));
      await tester.pump();
      expect(
          find.text(
              'Décrire la tenue exigée par l\'entreprise ou les règles d\'habillement\u00a0:'),
          findsOneWidget);

      await tester.enterText(find.byType(TextField).at(4), 'My uniform');
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Décrire la tenue de travail.'), findsNothing);
    });
  });

  group('JobFormFieldListTile BuildProtectionsRadio', () {
    testWidgets('is of type RadioWithFollowUp with proper title',
        (tester) async {
      await tester.pumpWidget(declareWidget(
          const SingleChildScrollView(child: JobFormFieldListTile())));

      final protectionsFinder = find.bySubtype<RadioWithFollowUp>().last;
      final protections = tester.widget<RadioWithFollowUp>(protectionsFinder);

      expect(
          find.text(
              '* Est-ce que l\'élève devra porter des équipements de protection individuelle (EPI)\u00a0?'),
          findsOneWidget);
      expect(protections.title,
          '* Est-ce que l\'élève devra porter des équipements de protection individuelle (EPI)\u00a0?');
      expect(protections.titleStyle,
          Theme.of(tester.context(protectionsFinder)).textTheme.bodyLarge);
    });

    testWidgets('choices are ProtectionsStatus', (tester) async {
      final key = GlobalKey<RadioWithFollowUpState<ProtectionsStatus>>();
      final protectionsController =
          GlobalKey<CheckboxWithOtherState<ProtectionsType>>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: BuildProtectionsRadio(
        protectionsKey: key,
        protectionsTypeKey: protectionsController,
      ))));

      final protectionsFinder = find.bySubtype<RadioWithFollowUp>().first;
      final protections = tester.widget<RadioWithFollowUp>(protectionsFinder);

      for (int i = 0; i < protections.elements.length; i++) {
        expect(protections.elements[i].toString(),
            ProtectionsStatus.values[i].toString());
      }
    });

    testWidgets('all choices except None trigger the follow up',
        (tester) async {
      final key = GlobalKey<RadioWithFollowUpState<ProtectionsStatus>>();
      final protectionsController =
          GlobalKey<CheckboxWithOtherState<ProtectionsType>>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: BuildProtectionsRadio(
        protectionsKey: key,
        protectionsTypeKey: protectionsController,
      ))));

      final protectionsFinder = find.bySubtype<RadioWithFollowUp>().first;
      final protections = tester.widget<RadioWithFollowUp>(protectionsFinder);

      expect(find.byType(TextFormField), findsNothing);

      for (int i = 0; i < protections.elements.length; i++) {
        await tester.tap(find.text(protections.elements[i].toString()));
        await tester.pump();

        if (protections.elements[i] == ProtectionsStatus.none) {
          expect(find.bySubtype<CheckboxWithOther>(), findsNothing);
        } else {
          expect(find.bySubtype<CheckboxWithOther>(), findsOneWidget);
        }
      }
    });

    testWidgets(
        'validate fails if nothing is selected or if the follow up is left empty',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipEquipment: true);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      // Fill the protections but not the follow up
      for (int i = 0; i < ProtectionsStatus.values.length; i++) {
        // Last refers to "Non" which appear twice (once in uniform and once in protections)
        await tester
            .tap(find.text(ProtectionsStatus.values[i].toString()).last);
        await tester.pump();
        if (ProtectionsStatus.values[i] == ProtectionsStatus.none) {
          expect(formKey.currentState!.validate(), isTrue);
          await tester.pump();
          expect(find.text('Décrire la tenue de travail.'), findsNothing);
        } else {
          expect(formKey.currentState!.validate(), isFalse);
          await tester.pump();
        }
      }

      // Fill the follow up
      await tester.tap(find.text(ProtectionsStatus.values[0].toString()));
      await tester.pump();
      expect(find.text('Lesquels\u00a0:'), findsOneWidget);
      await tester.drag(
          find.byType(SingleChildScrollView), const Offset(0, -500));

      // Selecting one suffise to validate except if it is "Autre"
      await tester.tap(find.text(ProtectionsType.steelToeShoes.toString()));
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
      // Uselect
      await tester.tap(find.text(ProtectionsType.steelToeShoes.toString()));
      await tester.pump();
      expect(formKey.currentState!.validate(), isFalse);

      // Selecting "Autre" require to fill the follow up
      expect(find.text('Préciser\u00a0:'), findsOneWidget);
      await tester.tap(find.text('Autre').last);
      await tester.pump();
      expect(find.text('Préciser\u00a0:'), findsNWidgets(2));
      expect(formKey.currentState!.validate(), isFalse);
      // Fill the follow up
      await tester.enterText(find.byType(TextField).at(5), 'My equipment');
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('JobFormFieldListTile validation failing condition', () {
    testWidgets('validation fails if job is missing', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipJob: true);
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('validation fails if age is missing', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipAge: true);
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('validation fails if availability is missing', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipAvailability: true);
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('validation succeed even if the prerequisites is missing',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipPrerequisites: true);
      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('validation fails if the uniform is missing', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipUniform: true);
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('validation fails if the equipment is missing', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const JobFormFieldListTile(),
      ))));

      // Fill all field but the Protections
      await fillAllJobFormFieldsListTile(tester, skipEquipment: true);
      expect(formKey.currentState!.validate(), isFalse);
    });
  });
}
