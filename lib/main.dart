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

// coverage:ignore-start
void main() async {
  const mockFirebase = false;
  const useDatabaseEmulator = false; //kDebugMode;

  WidgetsFlutterBinding.ensureInitialized();
  await initializeProgram(
      useDatabaseEmulator: useDatabaseEmulator, mockFirebase: mockFirebase);
  runApp(const BanqueStagesApp(mockFirebase: mockFirebase));
}
// coverage:ignore-end

class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp({super.key, this.mockFirebase = false});

  final bool mockFirebase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthProvider(mockMe: useDatabaseEmulator)),
        ChangeNotifierProvider(
            create: (context) => SchoolsProvider(mockMe: mockFirebase)),
        ChangeNotifierProvider(
            create: (context) => EnterprisesProvider(mockMe: mockFirebase)),
        ChangeNotifierProvider(
            create: (context) => InternshipsProvider(mockMe: mockFirebase)),
        // coverage:ignore-start
        ChangeNotifierProxyProvider<AuthProvider, ItinerariesProvider>(
          create: (context) => ItinerariesProvider(mockMe: mockFirebase),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        // coverage:ignore-end
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
