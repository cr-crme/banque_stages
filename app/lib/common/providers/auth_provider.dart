import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({bool mockMe = false, bool automaticallySignInIfMocked = true})
      : _mockMe = mockMe {
    if (_mockMe) {
      _mockMe = true;
      _mockFirebaseAuth =
          MockFirebaseAuth(mockUser: MockUser(uid: 'Mock User'));
      if (automaticallySignInIfMocked) {
        signInWithEmailAndPassword(
            email: 'email@email.com', password: '123123123');
      }
    }
  }

  bool _mockMe;
  bool get mockMe => _mockMe;
  FirebaseAuth get _firebaseAuth =>
      mockMe ? _mockFirebaseAuth! : FirebaseAuth.instance;
  MockFirebaseAuth? _mockFirebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  static AuthProvider of(BuildContext context, {bool listen = false}) =>
      Provider.of<AuthProvider>(context, listen: listen);

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  ///
  /// Fetch the JWT from the Microsoft authentication server. For now, it simulates
  ///
  // TODO: At some point, this should be replaced with a real JWT token.
  final jwt =
      JWT({'app_secret': '1234567890'}).sign(SecretKey('secret passphrase'));
}
