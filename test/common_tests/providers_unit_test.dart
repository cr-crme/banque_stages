import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
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
      final enterprises = EnterprisesProvider.of(context);
      expect(enterprises, isNotNull);
    });
  });
}
