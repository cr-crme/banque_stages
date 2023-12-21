import 'dart:io';

import 'package:crcrme_banque_stages/firebase_options.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/misc/question_file_service.dart';
import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_strategy/url_strategy.dart';

bool get useDatabaseEmulator => _useDatabaseEmulator;
bool _useDatabaseEmulator = kDebugMode;

Future<void> initializeProgram(
    {bool useDatabaseEmulator = false, bool mockFirebase = false}) async {
  _useDatabaseEmulator = useDatabaseEmulator;
  initializeDateFormatting('fr_CA');

  await Future.wait([
    // coverage:ignore-start
    if (!mockFirebase)
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    // coverage:ignore-end
    ActivitySectorsService.initializeActivitySectorSingleton(),
    RiskDataFileService.loadData(),
    QuestionFileService.loadData(),
  ]);

  // Connect Firebase to local emulators
  assert(() {
    if (useDatabaseEmulator && !mockFirebase) {
      // coverage:ignore-start
      final host = !kIsWeb && Platform.isAndroid ? '10.0.2.2' : 'localhost';
      FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
      FirebaseStorage.instance.useStorageEmulator(host, 9199);
      // coverage:ignore-end
    }
    return true;
  }());

  setPathUrlStrategy();
}
