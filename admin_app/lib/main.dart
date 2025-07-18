import 'package:admin_app/firebase_options.dart';
import 'package:admin_app/screens/router.dart';
import 'package:common/services/backend_helpers.dart';
import 'package:common_flutter/providers/admins_provider.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() async {
  final useMockers = false;
  final backendUri = BackendHelpers.backendUri(isSecured: false, isDev: true);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initializeDateFormatting('fr_CA');

  runApp(Home(useMockers: useMockers, backendUri: backendUri));
}

class Home extends StatelessWidget {
  const Home({super.key, required this.useMockers, required this.backendUri});

  final bool useMockers;
  final Uri backendUri;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(mockMe: useMockers),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SchoolBoardsProvider>(
          create:
              (context) =>
                  SchoolBoardsProvider(uri: backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminsProvider>(
          create:
              (context) => AdminsProvider(uri: backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TeachersProvider>(
          create:
              (context) =>
                  TeachersProvider(uri: backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, StudentsProvider>(
          create:
              (context) =>
                  StudentsProvider(uri: backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EnterprisesProvider>(
          create:
              (context) =>
                  EnterprisesProvider(uri: backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InternshipsProvider>(
          create:
              (context) =>
                  InternshipsProvider(uri: backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => 'Adminstration de Banque de stages',
        theme: crcrmeMaterialTheme,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'CA')],
      ),
    );
  }
}
