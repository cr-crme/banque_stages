import 'package:common_flutter/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/program_initializer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';

void main() {
  group('AuthProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    test('can sign in and out', () {
      final authProvider =
          AuthProvider(mockMe: true, automaticallySignInIfMocked: false);
      expect(authProvider.isFullySignedIn, isFalse);

      authProvider.signInWithEmailAndPassword(
          email: 'my.email@test.ca', password: 'no password');
      expect(authProvider.isFullySignedIn, isTrue);
      expect(authProvider.currentUser?.uid, 'Mock User');

      authProvider.signOut();
      expect(authProvider.isFullySignedIn, isFalse);
      expect(authProvider.currentUser?.uid, isNull);
    });

    testWidgets('can get "of" context', (tester) async {
      final context =
          await tester.contextWithNotifiers(withAuthentication: true);

      final authProvider = AuthProvider.of(context);
      expect(authProvider.isFullySignedIn, isTrue);
    });
  });
}
