import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    FirebaseAuth.instance.userChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

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

  User? _currentUser;
  User? get currentUser => _currentUser;
}
