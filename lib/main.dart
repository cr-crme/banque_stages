import 'dart:io';

import 'package:crcrme_banque_stages/crcrme_material_theme/lib/crcrme_material_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/auth_provider.dart';
import '/common/providers/enterprises_provider.dart';
import 'firebase_options.dart';
import 'screens/add_enterprise/add_enterprise_screen.dart';
import 'screens/enterprise/enterprise_screen.dart';
import 'screens/enterprises_list/enterprises_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/internship_forms/post_internship_evaluation_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect Firebase to local emulators
  assert(() {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseDatabase.instance.useDatabaseEmulator(
        !kIsWeb && Platform.isAndroid ? "10.0.2.2" : "localhost", 9000);
    FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
    return true;
  }());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => EnterprisesProvider()),
      ],
      child: MaterialApp(
        title: 'Banque de Stages',
        theme: crcrmeMaterialTheme,
        initialRoute: HomeScreen.route,
        home: const HomeScreen(),
        routes: {
          LoginScreen.route: (context) => const LoginScreen(),
          EnterprisesListScreen.route: (context) =>
              const EnterprisesListScreen(),
          AddEnterpriseScreen.route: (context) => const AddEnterpriseScreen(),
          EnterpriseScreen.route: (context) => const EnterpriseScreen(),
          PostInternshipEvaluationScreen.route: (context) =>
              const PostInternshipEvaluationScreen(),
        },
      ),
    );
  }
}
