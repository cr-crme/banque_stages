import 'package:common/models/persons/student.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/student_picker_form_field.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('StudentPickerForm', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    testWidgets('renders a title', (tester) async {
      await tester.pumpWidget(
          declareWidget(const StudentPickerFormField(students: [])));

      expect(find.text('* Élève'), findsOneWidget);
    });

    testWidgets('renders an hint when tapped', (tester) async {
      await tester.pumpWidget(declareWidget(const StudentPickerFormField(
        students: [],
      )));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(find.text('Saisir le nom de l\'élève'), findsOneWidget);
    });

    testWidgets('can narrow the selection by typing', (tester) async {
      await tester.pumpWidget(declareWidget(StudentPickerFormField(students: [
        dummyStudent(firstName: 'First', lastName: 'Student'),
        dummyStudent(firstName: 'Second', lastName: 'Student'),
      ])));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(find.byType(InkWell), findsNWidgets(3));

      await tester.enterText(find.byType(TextField), 'First');
      await tester.pump();
      expect(find.byType(InkWell), findsNWidgets(2));

      await tester.enterText(find.byType(TextField), 'None');
      await tester.pump();
      expect(find.byType(InkWell), findsNWidgets(1));

      await tester.enterText(find.byType(TextField), 'Student');
      await tester.pump();
      expect(find.byType(InkWell), findsNWidgets(3));
    });

    testWidgets('tapping a choice moves it to the text field', (tester) async {
      final firstStudent =
          dummyStudent(firstName: 'First', lastName: 'Student');
      final secondStudent =
          dummyStudent(firstName: 'Second', lastName: 'Student');
      await tester.pumpWidget(declareWidget(
          StudentPickerFormField(students: [firstStudent, secondStudent])));

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.text(firstStudent.fullName), findsOneWidget);
      expect(find.text(secondStudent.fullName), findsOneWidget);

      await tester.tap(find.text(secondStudent.fullName));
      await tester.pump();
      expect(find.text(firstStudent.fullName), findsNothing);
      expect(find.text(secondStudent.fullName), findsOneWidget);
    });

    testWidgets('can initialize', (tester) async {
      final firstStudent =
          dummyStudent(firstName: 'First', lastName: 'Student');
      final secondStudent =
          dummyStudent(firstName: 'Second', lastName: 'Student');
      await tester.pumpWidget(declareWidget(StudentPickerFormField(
        students: [firstStudent, secondStudent],
        initialValue: secondStudent,
      )));

      expect(find.text(secondStudent.fullName), findsOneWidget);
    });

    testWidgets('"onSelect" callback behaves properly', (tester) async {
      final firstStudent =
          dummyStudent(firstName: 'First', lastName: 'Student');
      final secondStudent =
          dummyStudent(firstName: 'Second', lastName: 'Student');
      Student? selectedStudent;
      await tester.pumpWidget(declareWidget(StudentPickerFormField(
        students: [firstStudent, secondStudent],
        onSelect: (student) => selectedStudent = student,
      )));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(secondStudent.fullName));
      await tester.pump();

      expect(selectedStudent, secondStudent);
    });

    testWidgets('can clear text by tapping clear icon', (tester) async {
      final secondStudent =
          dummyStudent(firstName: 'Second', lastName: 'Student');
      await tester.pumpWidget(declareWidget(StudentPickerFormField(students: [
        dummyStudent(firstName: 'First', lastName: 'Student'),
        secondStudent,
      ])));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(secondStudent.fullName));
      await tester.pump();
      expect(find.text(secondStudent.fullName), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(find.text(secondStudent.fullName), findsNothing);
    });

    testWidgets('tapping clear closes the suggestion box', (tester) async {
      await tester.pumpWidget(declareWidget(StudentPickerFormField(students: [
        dummyStudent(firstName: 'First', lastName: 'Student'),
        dummyStudent(firstName: 'Second', lastName: 'Student'),
      ])));

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(find.byType(InkWell), findsNWidgets(3));

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      expect(find.byType(InkWell), findsNWidgets(1));
    });

    testWidgets('validation fails if nothing is entered', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: const StudentPickerFormField(students: []),
      ))));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('Sélectionner un élève.'), findsOneWidget);
    });

    testWidgets('validation fails if the user did not actively tap on a choice',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final firstStudent =
          dummyStudent(firstName: 'First', lastName: 'Student');
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: StudentPickerFormField(
          students: [
            firstStudent,
            dummyStudent(firstName: 'Second', lastName: 'Student'),
          ],
        ),
      ))));

      await tester.enterText(find.byType(TextField), firstStudent.fullName);
      await tester.pump();
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text('Sélectionner un élève.'), findsOneWidget);
    });

    testWidgets('validation succeeds if a valid value is tapped',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final firstStudent =
          dummyStudent(firstName: 'First', lastName: 'Student');
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: StudentPickerFormField(
          students: [
            firstStudent,
            dummyStudent(firstName: 'Second', lastName: 'Student'),
          ],
        ),
      ))));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(firstStudent.fullName));
      await tester.pump();
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pump();

      expect(find.text('Sélectionner un élève.'), findsNothing);
    });

    testWidgets('"onSaved" callback is called if form is saved',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      final firstStudent =
          dummyStudent(firstName: 'First', lastName: 'Student');
      Student? savedStudent;
      await tester.pumpWidget(declareWidget(SingleChildScrollView(
          child: Form(
        key: formKey,
        child: StudentPickerFormField(
          students: [
            firstStudent,
            dummyStudent(firstName: 'Second', lastName: 'Student'),
          ],
          onSaved: (student) => savedStudent = student,
        ),
      ))));

      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(firstStudent.fullName));

      formKey.currentState!.save();
      await tester.pump();

      expect(savedStudent, firstStudent);
    });
  });
}
