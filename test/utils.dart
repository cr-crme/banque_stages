import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const drawerTitle = 'Banque de stages';
const reinitializedDataButtonText = 'Réinitialiser la base de données';

const screenNames = [
  'Mes élèves',
  'Tableau des supervisions',
  'Tâches à réaliser',
  'Entreprises',
  'Santé et Sécurité au PFAE',
];

const myStudentNames = [
  'Cedric Masson',
  'Thomas Caron',
  'Mikael Boucher',
  'Kevin Leblanc',
  'Diego Vargas',
  'Jeanne Tremblay',
  'Vincent Picard',
  'Vanessa Monette',
  'Melissa Poulain',
];

Future<void> loadDummyData(WidgetTester tester) async {
  // Find the reinitalize data button in the drawer
  await openDrawer(tester);
  final reinitializeButton = find.text(reinitializedDataButtonText);
  await tester.tap(reinitializeButton);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> openDrawer(WidgetTester tester) async {
  final drawerIcon = find.byIcon(Icons.menu);
  await tester.tap(drawerIcon);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> closeDrawer(WidgetTester tester) async {
  BuildContext context = tester.element(find.byType(Drawer));
  Navigator.pop(context);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> navigateToScreen(WidgetTester tester, String target) async {
  // This function assumes drawer menu is shown
  await openDrawer(tester);
  final targetButton =
      find.ancestor(of: find.text(target), matching: find.byType(Card));
  await tester.tap(targetButton);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

// Add the providers to the widget tree
Future<void> pumpWidgetWithNotifiers(
  WidgetTester tester,
  Widget child, {
  bool withSchools = false,
  bool withTeachers = false,
  bool withStudents = false,
  bool withEnterprises = false,
  bool withInternships = false,
}) async {
  // Add the providers to the widget tree
  if (withSchools) {
    child = ChangeNotifierProvider<SchoolsProvider>(
      create: (context) => SchoolsProvider(),
      child: child,
    );
  }

  if (withTeachers) {
    child = ChangeNotifierProvider<TeachersProvider>(
      create: (context) => TeachersProvider(),
      child: child,
    );
  }

  if (withStudents) {
    child = ChangeNotifierProvider<StudentsProvider>(
      create: (context) => StudentsProvider(),
      child: child,
    );
  }

  if (withEnterprises) {
    child = ChangeNotifierProvider<EnterprisesProvider>(
      create: (context) => EnterprisesProvider(),
      child: child,
    );
  }

  if (withInternships) {
    child = ChangeNotifierProvider<InternshipsProvider>(
      create: (context) => InternshipsProvider(),
      child: child,
    );
  }

  child = MaterialApp(
    builder: (context, ch) => child,
  );

  await tester.pumpWidget(child);
}
