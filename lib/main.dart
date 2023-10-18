import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeProgram();
  runApp(const BanqueStagesApp());
}

class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp({super.key, this.mockFirebase = false});

  final bool mockFirebase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthProvider(mockFirebase: mockFirebase)),
        ChangeNotifierProvider(
            create: (context) => SchoolsProvider(mockMe: mockFirebase)),
        ChangeNotifierProvider(
            create: (context) => EnterprisesProvider(mockMe: mockFirebase)),
        ChangeNotifierProvider(
            create: (context) => InternshipsProvider(mockMe: mockFirebase)),
        ChangeNotifierProxyProvider<AuthProvider, ItinerariesProvider>(
          create: (context) => ItinerariesProvider(mockMe: mockFirebase),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TeachersProvider>(
          create: (context) => TeachersProvider(mockMe: mockFirebase),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, StudentsProvider>(
          create: (context) => StudentsProvider(mockMe: mockFirebase),
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
