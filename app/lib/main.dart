import 'dart:async';

import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/program_helpers.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// coverage:ignore-start
void main() async {
  BugReporter.loggerSetup();
  const showDebugElements = true;
  const useMockers = false;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await ProgramInitializer.initialize(
          showDebugElements: showDebugElements, mockMe: useMockers);

      runApp(const BanqueStagesApp(useMockers: useMockers));
    },
    (error, stackTrace) =>
        BugReporter.report(error, stackTrace, errorReportUri: _errorReportUri),
  );
}
// coverage:ignore-end

final Uri _backendUri = Uri.parse('ws://localhost:3456/connect');
final Uri _errorReportUri = Uri.parse('http://localhost:3456/bug-report');

class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp({super.key, this.useMockers = false});

  final bool useMockers;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => AuthProvider(mockMe: useMockers)),
        ChangeNotifierProxyProvider<AuthProvider, SchoolBoardsProvider>(
          create: (context) =>
              SchoolBoardsProvider(uri: _backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EnterprisesProvider>(
          create: (context) =>
              EnterprisesProvider(uri: _backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, InternshipsProvider>(
          create: (context) =>
              InternshipsProvider(uri: _backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TeachersProvider>(
          create: (context) =>
              TeachersProvider(uri: _backendUri, mockMe: useMockers),
          update: (context, auth, previous) => previous!..initializeAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, StudentsProvider>(
          create: (context) =>
              StudentsProvider(uri: _backendUri, mockMe: useMockers),
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
