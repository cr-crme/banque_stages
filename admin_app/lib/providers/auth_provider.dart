import 'package:common/models/generic/access_level.dart';
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

  User? get currentUser =>
      isAuthenticatorSignedIn ? _firebaseAuth.currentUser : null;

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

    notifyListeners();
    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    teacherId = null;
    schoolId = null;
    schoolBoardId = null;
    databaseAccessLevel = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticatorSignedIn) {
      return Future.value(false);
    }

    try {
      // First make sure the user is signed in with recent credentials
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: oldPassword,
      );

      // Now update the password
      await _firebaseAuth.currentUser!.updatePassword(newPassword);

      shouldChangePassword = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Error changing password: $error');
      return false;
    }
  }

  Future<String?> getAuthenticatorIdToken() async {
    if (!isAuthenticatorSignedIn) return null;
    return await _firebaseAuth.currentUser!.getIdToken();
  }

  bool get isAuthenticatorSignedIn {
    return _firebaseAuth.currentUser != null;
  }

  String? _teacherId;
  String? get teacherId => _teacherId;
  set teacherId(String? id) {
    _teacherId = id;
    notifyListeners();
  }

  bool? _shouldChangePassword;
  bool? get shouldChangePassword => _shouldChangePassword;
  set shouldChangePassword(bool? value) {
    _shouldChangePassword = value;
    notifyListeners();
  }

  String? _schoolId;
  String? get schoolId => _schoolId;
  set schoolId(String? id) {
    _schoolId = id;
    notifyListeners();
  }

  String? _schoolBoardId;
  String? get schoolBoardId => _schoolBoardId;
  set schoolBoardId(String? id) {
    _schoolBoardId = id;
    notifyListeners();
  }

  AccessLevel? databaseAccessLevel;

  bool get isBackendConnected {
    return (teacherId != null && teacherId!.isNotEmpty) ||
        databaseAccessLevel == AccessLevel.superAdmin;
  }

  bool get isFullySignedIn => isAuthenticatorSignedIn && isBackendConnected;
}
