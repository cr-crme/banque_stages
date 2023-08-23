import 'dart:io';

import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/firebase_options.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/misc/question_file_service.dart';
import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

bool useDatabaseEmulator = kDebugMode;
bool populateWithDebugData = kDebugMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_CA');

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ActivitySectorsService.initializeActivitySectorSingleton(),
    RiskDataFileService.loadData(),
    QuestionFileService.loadData(),
  ]);

  // Connect Firebase to local emulators
  assert(() {
    if (useDatabaseEmulator) {
      final host = !kIsWeb && Platform.isAndroid ? '10.0.2.2' : 'localhost';
      FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
    }
    return true;
  }());

  setPathUrlStrategy();
  runApp(const BanqueStagesApp());
}

class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => SchoolsProvider()),
        ChangeNotifierProvider(create: (context) => EnterprisesProvider()),
        ChangeNotifierProvider(create: (context) => InternshipsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ItinerariesProvider>(
          create: (context) => ItinerariesProvider(),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TeachersProvider>(
          create: (context) => TeachersProvider(),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, StudentsProvider>(
          create: (context) => StudentsProvider(),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => 'Banque de stages',
        theme: crcrmeMaterialTheme,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'CA'),
        ],
      ),
    );
  }
}
