import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/auth_provider.dart';
import '/misc/form_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  String? _errorText;

  void _signIn() async {
    if (!FormService.validateForm(_formKey)) {
      return;
    }

    final navigator = Navigator.of(context);
    _formKey.currentState!.save();

    try {
      await context
          .read<AuthProvider>()
          .signInWithEmailAndPassword(email: _email!, password: _password!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
        case "user-not-found":
        case "wrong-password":
          setState(() {
            _errorText = "Identifiants invalides. Veuillez réssayer.";
          });
          break;
        case "user-disabled":
          setState(() {
            _errorText =
                "Impossible de se connecter; ce compte à été désactivé.";
          });
          break;
        default:
          const snackBar = SnackBar(
            content: Text('Erreur non reconnue lors de l\'activation'),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text(
                  "Connectez-vous à votre compte avant de poursuivre.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.mail),
                    labelText: "Courriel",
                  ),
                  validator: FormService.emailValidator,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (email) => _email = email!,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.lock), labelText: "Mot de passe"),
                  validator: FormService.passwordValidator,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onSaved: (function) => _password = function!,
                ),
                Visibility(
                  visible: _errorText != null,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: const Icon(Icons.error),
                      iconColor: Theme.of(context).errorColor,
                      title: Text(
                        _errorText ?? "",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text("Se connecter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
