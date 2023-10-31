import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';

import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

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
}
