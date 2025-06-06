import 'package:admin_app/providers/admins_provider.dart';
import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/enterprises_provider.dart';
import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/login/misc.dart';
import 'package:admin_app/screens/router.dart';
import 'package:admin_app/widgets/show_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  static const route = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;

  void _signIn() async {
    if (!FormService.validateForm(_formKey, save: true)) return;

    try {
      await AuthProvider.of(
        context,
      ).signInWithEmailAndPassword(email: _email!, password: _password!);
    } on firebase.FirebaseAuthException catch (e) {
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

      if (!mounted) return;
      showSnackBar(context, message: errorMessage);
    }
    setState(() {});
  }

  bool _isTransitioning = false;
  Future<void> _performHasSignedId() async {
    GoRouter.of(context).goNamed(Screens.home);
  }

  @override
  Widget build(BuildContext context) {
    // Calling the provider jumps start the authentication process and ensures data arrival
    final schoolBoardsProvider = SchoolBoardsProvider.of(context, listen: true);
    AdminsProvider.of(context, listen: false);
    EnterprisesProvider.of(context, listen: false);
    InternshipsProvider.of(context, listen: false);
    StudentsProvider.of(context, listen: false);

    final authProvider = AuthProvider.of(context, listen: true);
    if (!_isTransitioning && authProvider.isFullySignedIn) {
      _isTransitioning = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _performHasSignedId(),
      );
    }

    return PopScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Banque de stages')),
        drawer: const MainDrawer(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child:
                  authProvider.isAuthenticatorSignedIn
                      ? Center(
                        child: Text(
                          schoolBoardsProvider.hasProblemConnecting
                              ? 'Impossible de se connecter à la base de données, \n'
                                  'vérifiez votre connexion internet.'
                              : schoolBoardsProvider.connexionRefused
                              ? 'Connexion refusée, \n'
                                  'veuillez contacter votre administrateur'
                              : 'Connexion en cours...',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                      : Column(
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
                            onSaved: (email) => _email = email,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: 'Mot de passe',
                            ),
                            validator: FormService.passwordValidator,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                            onSaved: (password) => _password = password,
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
