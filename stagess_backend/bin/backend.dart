import 'dart:io';

import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_admin/src/auth/credential.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';
import 'package:stagess_backend/repositories/admins_repository.dart';
import 'package:stagess_backend/repositories/enterprises_repository.dart';
import 'package:stagess_backend/repositories/internships_repository.dart';
import 'package:stagess_backend/repositories/school_boards_repository.dart';
import 'package:stagess_backend/repositories/students_repository.dart';
import 'package:stagess_backend/repositories/teachers_repository.dart';
import 'package:stagess_backend/server/connexions.dart';
import 'package:stagess_backend/server/database_manager.dart';
import 'package:stagess_backend/server/http_request_handler.dart';
import 'package:stagess_backend/utils/network_rate_limiter.dart';
import 'package:stagess_common/services/backend_helpers.dart';

final _logger = Logger('BackendServer');

enum DatabaseBackend { mysql, mock }

final _databaseBackend = DatabaseBackend.mysql;
final _backendIp = InternetAddress.loopbackIPv4;
final _backendPort = BackendHelpers.backendPort;
final _devSettings = ConnectionSettings(
  host: _getFromEnvironment('DATABASE_DEV_HOST'),
  port: int.parse(_getFromEnvironment('DATABASE_DEV_PORT')),
  user: _getFromEnvironment('DATABASE_DEV_USER'),
  password: _getFromEnvironment('DATABASE_DEV_PASSWORD'),
  db: _getFromEnvironment('DATABASE_DEV_NAME'),
);
final _productionSettings = ConnectionSettings(
  host: _getFromEnvironment('DATABASE_PRODUCTION_HOST'),
  port: int.parse(_getFromEnvironment('DATABASE_PRODUCTION_PORT')),
  user: _getFromEnvironment('DATABASE_PRODUCTION_USER'),
  password: _getFromEnvironment('DATABASE_PRODUCTION_PASSWORD'),
  db: _getFromEnvironment('DATABASE_PRODUCTION_NAME'),
);

void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Connect to the authentication service
  FirebaseAdmin.instance.initializeApp(
    AppOptions(
      credential:
          ServiceAccountCredential('backendFirebaseServiceAccountKey.json'),
    ),
  );
  // Get the Firebase API key from the environment variable
  final firebaseApiKey = _getFromEnvironment('FIREBASE_WEB_API_KEY');

  // Create an HTTP server listening on localhost:_backendPort
  var server = await HttpServer.bind(_backendIp, _backendPort);
  _logger.info('Server running on http://${_backendIp.address}:$_backendPort/');
  _logger.info('Using database backend: ${_databaseBackend.name}');

  final devConnexions = await _connectDatabase(
      databaseBackend: _databaseBackend,
      firebaseApiKey: firebaseApiKey,
      settings: _devSettings);

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

String _getFromEnvironment(String key) {
  final value = Platform.environment[key];
  if (value == null || value.isEmpty) {
    _logger.severe('$key environment variable is not set.');
    exit(1);
  }
  return value;
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
