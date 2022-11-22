import 'dart:io';

import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'common/providers/auth_provider.dart';
import 'common/providers/enterprises_provider.dart';
import 'common/providers/students_provider.dart';
import 'firebase_options.dart';
import 'misc/form_service.dart';
import 'misc/job_data_file_service.dart';
import 'misc/question_file_service.dart';
import 'navigation.dart';
import 'screens/visiting_students/models/all_itineraries.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JobDataFileService.loadData();
  await QuestionFileService.loadData();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect Firebase to local emulators
  assert(() {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseDatabase.instance.useDatabaseEmulator(
        !kIsWeb && Platform.isAndroid ? "10.0.2.2" : "localhost", 9000);
    FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
    return true;
  }());
  runApp(const BanqueStagesApp());
}

class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => EnterprisesProvider()),
        ChangeNotifierProvider(create: (context) => AllStudentsWaypoints()),
        ChangeNotifierProvider(create: (context) => AllItineraries()),
        ChangeNotifierProxyProvider<AuthProvider, StudentsProvider>(
          create: (context) => StudentsProvider(),
          update: (context, auth, previous) {
            if (auth.currentUser == null) {
              previous!.pathToAvailableDataIds = "void";
            } else {
              previous!.pathToAvailableDataIds =
                  "/students-ids/${auth.currentUser!.uid}/";
            }
            return previous;
          },
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) {
          FormService.setContext = context;
          return AppLocalizations.of(context)!.appName;
        },
        theme: crcrmeMaterialTheme,
        routerDelegate: router,
        routeInformationParser: routerInformationParser,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
