import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  group('AuthProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('can sign in and out', () {
      final authProvider =
          AuthProvider(mockMe: true, automaticallySignInIfMocked: false);
      expect(authProvider.isSignedIn(), false);

      authProvider.signInWithEmailAndPassword(
          email: 'my.email@test.ca', password: 'no password');
      expect(authProvider.isSignedIn(), true);
      expect(authProvider.currentUser?.uid, 'Mock User');

      authProvider.signOut();
      expect(authProvider.isSignedIn(), false);
      expect(authProvider.currentUser?.uid, isNull);
    });

    testWidgets('can get "of" context', (tester) async {
      final context =
          await tester.contextWithNotifiers(withAuthentication: true);

      final authProvider = AuthProvider.of(context);
      expect(authProvider.isSignedIn(), true);
    });
  });

  group('EnterprisesProvider', () {
    test('"replaceJob" works', () {
      final enterprises = EnterprisesProvider(mockMe: true);
      enterprises.add(Enterprise(
        name: 'Test Enterprise',
        activityTypes: {},
        recrutedBy: 'Nobody',
        shareWith: 'Noone',
        jobs: JobList()..add(dummyJob()),
        contact: Person(firstName: 'Not', middleName: 'A', lastName: 'Person'),
      ));

      final enterprise = enterprises[0];
      expect(enterprise.jobs[0].minimumAge, 12);
      enterprises.replaceJob(
          enterprise, enterprise.jobs[0].copyWith(minimumAge: 2));
      expect(enterprise.jobs[0].minimumAge, 2);
    });

    test('"deserializeItem" works', () {
      final enterprises = EnterprisesProvider(mockMe: true);
      final enterprise =
          enterprises.deserializeItem({'name': 'Test Enterprise'});
      expect(enterprise.name, 'Test Enterprise');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withEnterprises: true);
      final enterprises = EnterprisesProvider.of(context, listen: false);
      expect(enterprises, isNotNull);
    });
  });

  group('InternshipsProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"byStudentId" return the right student', () {
      final internships = InternshipsProvider(mockMe: true);
      internships.add(dummyInternship(studentId: '123'));
      internships.add(dummyInternship(studentId: '123'));
      internships.add(dummyInternship(studentId: '456'));

      expect(internships.byStudentId('123').length, 2);
      expect(internships.byStudentId('123')[0].studentId, '123');
      expect(internships.byStudentId('123')[1].studentId, '123');
      expect(internships.byStudentId('456').length, 1);
      expect(internships.byStudentId('456')[0].studentId, '456');
      expect(internships.byStudentId('789').length, 0);
    });

    test('deserializeItem works', () {
      final internships = InternshipsProvider(mockMe: true);
      final internship = internships.deserializeItem({
        'student': '123',
        'enterprise': '456',
        'priority': 0,
      });
      expect(internship.studentId, '123');
      expect(internship.enterpriseId, '456');
      expect(internship.visitingPriority, VisitingPriority.low);
    });

    test('can replace priority', () {
      final internships = InternshipsProvider(mockMe: true);
      internships.add(dummyInternship());

      expect(internships[0].visitingPriority, VisitingPriority.low);
      internships.replacePriority(
          internships[0].studentId, VisitingPriority.high);
      expect(internships[0].visitingPriority, VisitingPriority.high);
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withInternships: true);
      final internships = InternshipsProvider.of(context, listen: false);
      expect(internships, isNotNull);
    });
  });
}
