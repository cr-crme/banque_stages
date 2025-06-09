import 'package:common_flutter/helpers/form_service.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    if (!FormService.validateForm(_formKey, save: true)) return;

    try {
      await AuthProvider.of(context)
          .signInWithEmailAndPassword(email: _email!, password: _password!);
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Erreur de connexion')));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (AuthProvider.of(context).isFullySignedIn) {
      Future.microtask(() {
        if (context.mounted) GoRouter.of(context).goNamed(Screens.home);
      });
    }

    return PopScope(
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
