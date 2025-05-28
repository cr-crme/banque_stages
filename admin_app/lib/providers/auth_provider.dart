import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({bool mockMe = false, bool automaticallySignInIfMocked = true})
    : _mockMe = mockMe {
    if (_mockMe) {
      _mockMe = true;
      _mockFirebaseAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'Mock User'),
      );
      if (automaticallySignInIfMocked) {
        signInWithEmailAndPassword(
          email: 'email@email.com',
          password: '123123123',
        );
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
    final user = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    backendId = null;
    notifyListeners();
  }

  Future<String?> getAuthenticatorIdToken() async {
    if (!isAuthenticatorSignedIn()) return null;
    return await _firebaseAuth.currentUser!.getIdToken();
  }

  bool isAuthenticatorSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  String? _backendId;
  String? get backendId => _backendId;
  set backendId(String? id) {
    _backendId = id;
    notifyListeners();
  }

  bool isBackendConnected() {
    return backendId != null && backendId!.isNotEmpty;
  }

  bool isFullySignedIn() => isAuthenticatorSignedIn() && isBackendConnected();
}
