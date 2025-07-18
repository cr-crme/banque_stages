import 'dart:io';

import 'package:backend/repositories/admins_repository.dart';
import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/internships_repository.dart';
import 'package:backend/repositories/school_boards_repository.dart';
import 'package:backend/repositories/students_repository.dart';
import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/server/connexions.dart';
import 'package:backend/server/database_manager.dart';
import 'package:backend/server/http_request_handler.dart';
import 'package:backend/utils/network_rate_limiter.dart';
import 'package:common/services/backend_helpers.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_admin/src/auth/credential.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('BackendServer');

enum DatabaseBackend { mysql, mock }

final _databaseBackend = DatabaseBackend.mysql;
final _backendIp = InternetAddress.loopbackIPv4;
final _backendPort = BackendHelpers.backendPort;
final _devSettings = ConnectionSettings(
    host: 'localhost',
    port: BackendHelpers.devDatabasePort,
    user: 'devuser',
    password: 'devpassword',
    db: BackendHelpers.devDatabaseName);
final _productionSettings = ConnectionSettings(
  host: 'localhost',
  port: BackendHelpers.productionDatabasePort,
  user: 'admin',
  password: null,
  db: BackendHelpers.productionDatabaseName,
);

void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Connect to the authentication service
  Credentials.firebaseAdminCredentialPath;
  FirebaseAdmin.instance.initializeApp(
    AppOptions(
      credential:
          ServiceAccountCredential('backendFirebaseServiceAccountKey.json'),
    ),
  );
  // Get the Firebase API key from the environment variable
  final firebaseApiKey = Platform.environment['FIREBASE_WEB_API_KEY'];
  if (firebaseApiKey == null || firebaseApiKey.isEmpty) {
    _logger.severe('FIREBASE_WEB_API_KEY environment variable is not set.');
    exit(1);
  }

  // Create an HTTP server listening on localhost:_backendPort
  var server = await HttpServer.bind(_backendIp, _backendPort);
  _logger.info('Server running on http://${_backendIp.address}:$_backendPort/');
  _logger.info('Using database backend: ${_databaseBackend.name}');

  final devConnexions = await _connectDatabase(
      databaseBackend: _databaseBackend,
      firebaseApiKey: firebaseApiKey,
      settings: _devSettings);

  _productionSettings.password =
      Platform.environment['DATABASE_PRODUCTION_ADMIN_PASSWORD'];
  if (_productionSettings.password == null ||
      _productionSettings.password!.isEmpty) {
    _logger.severe(
        'DATABASE_PRODUCTION_ADMIN_PASSWORD environment variable is not set.');
    exit(1);
  }
  final productionConnexions = await _connectDatabase(
      databaseBackend: _databaseBackend,
      firebaseApiKey: firebaseApiKey,
      settings: _productionSettings);

  _logger.info('Waiting for requests...');
  final requestHandler = HttpRequestHandler(
      devConnexions: devConnexions, productionConnexions: productionConnexions);

  final rateLimiter =
      NetworkRateLimiter(maxRequests: 50, duration: Duration(minutes: 1));
  await for (HttpRequest request in server) {
    requestHandler.answer(request, rateLimiter: rateLimiter);
  }

  if (_databaseBackend == DatabaseBackend.mysql) {
    await devConnexions.database.connection.close();
    await productionConnexions.database.connection.close();
  }
}

Future<Connexions> _connectDatabase({
  required DatabaseBackend databaseBackend,
  required String firebaseApiKey,
  required ConnectionSettings settings,
}) async {
  final connection = switch (databaseBackend) {
    DatabaseBackend.mock => null,
    DatabaseBackend.mysql => await MySqlConnection.connect(settings)
  };
  // Give a bit of time just in case
  await Future.delayed(Duration(milliseconds: 100));

  final connexions = Connexions(
      firebaseApiKey: firebaseApiKey,
      database: DatabaseManager(
        connection: connection!,
        schoolBoardsDatabase: switch (databaseBackend) {
          DatabaseBackend.mysql =>
            MySqlSchoolBoardsRepository(connection: connection),
          DatabaseBackend.mock => SchoolBoardsRepositoryMock()
        },
        adminsDatabase: switch (databaseBackend) {
          DatabaseBackend.mysql =>
            MySqlAdminsRepository(connection: connection),
          DatabaseBackend.mock => AdminsRepositoryMock()
        },
        teachersDatabase: switch (databaseBackend) {
          DatabaseBackend.mysql =>
            MySqlTeachersRepository(connection: connection),
          DatabaseBackend.mock => TeachersRepositoryMock()
        },
        studentsDatabase: switch (databaseBackend) {
          DatabaseBackend.mysql =>
            MySqlStudentsRepository(connection: connection),
          DatabaseBackend.mock => StudentsRepositoryMock()
        },
        enterprisesDatabase: switch (databaseBackend) {
          DatabaseBackend.mysql =>
            MySqlEnterprisesRepository(connection: connection),
          DatabaseBackend.mock => EnterprisesRepositoryMock()
        },
        internshipsDatabase: switch (databaseBackend) {
          DatabaseBackend.mysql =>
            MySqlInternshipsRepository(connection: connection),
          DatabaseBackend.mock => InternshipsRepositoryMock()
        },
      ));
  return connexions;
}
