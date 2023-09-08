import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  void _signIn() async {
    final scaffold = ScaffoldMessenger.of(context);

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    try {
      await context
          .read<AuthProvider>()
          .signInWithEmailAndPassword(email: _email!, password: _password!);
    } on FirebaseAuthException catch (e) {
      late final String errorMessage;
      switch (e.code) {
        case 'invalid-email':
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = 'Identifiants invalides. Veuillez réssayer.';
          break;
        case 'user-disabled':
          errorMessage =
              'Impossible de se connecter; ce compte à été désactivé.';
          break;
        default:
          errorMessage = 'Erreur non reconnue lors de la connexion';
      }

      scaffold.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthProvider.of(context).isSignedIn()) {
      Future.microtask(() => GoRouter.of(context).goNamed(Screens.home));
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Banque de stages'),
          automaticallyImplyLeading: false,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Connectez-vous à votre compte avant de poursuivre.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.mail),
                      labelText: 'Courriel',
                    ),
                    validator: FormService.emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (email) => _email = email!,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                        icon: Icon(Icons.lock), labelText: 'Mot de passe'),
                    validator: FormService.passwordValidator,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    onSaved: (function) => _password = function!,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
