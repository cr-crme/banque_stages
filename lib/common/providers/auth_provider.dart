import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({this.mockFirebase = false}) {
    if (!mockFirebase) {
      _currentUser = FirebaseAuth.instance.currentUser;
      FirebaseAuth.instance.userChanges().listen((user) {
        _currentUser = user;
        notifyListeners();
      });
    }
  }

  final bool mockFirebase;

  static AuthProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<AuthProvider>(context, listen: listen);

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  bool isSignedIn() {
    return kDebugMode || mockFirebase ? true : currentUser != null;
  }

  User? _currentUser;
  User? get currentUser => _currentUser;
}
