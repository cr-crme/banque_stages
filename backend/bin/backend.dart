import 'dart:io';

import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/students_repository.dart';
import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/server/connexions.dart';
import 'package:backend/server/database_manager.dart';
import 'package:backend/server/http_request_handler.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('BackendServer');

enum DatabaseBackend { mysql, mock }

void main() async {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Set up the database backend
  final databaseBackend = DatabaseBackend.mysql;

  // Create an HTTP server listening on localhost:3456
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3456);
  _logger.info('Server running on http://localhost:3456');

  _logger.info('Using database backend: ${databaseBackend.name}');
  final connection = switch (databaseBackend) {
    DatabaseBackend.mock => null,
    DatabaseBackend.mysql => await MySqlConnection.connect(ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'devuser',
        password: 'devpassword',
        db: 'dev_db',
      ))
  };
  await Future.delayed(
      Duration(milliseconds: 100)); // Give a bit of time just in case
  final connexions = Connexions(
      database: DatabaseManager(
    teachersDatabase: switch (databaseBackend) {
      DatabaseBackend.mysql => MySqlTeachersRepository(connection: connection!),
      DatabaseBackend.mock => TeachersRepositoryMock()
    },
    studentsDatabase: switch (databaseBackend) {
      DatabaseBackend.mysql => MySqlStudentsRepository(connection: connection!),
      DatabaseBackend.mock => StudentsRepositoryMock()
    },
    enterprisesDatabase: switch (databaseBackend) {
      DatabaseBackend.mysql =>
        MySqlEnterprisesRepository(connection: connection!),
      DatabaseBackend.mock => EnterprisesRepositoryMock()
    },
  ));
  final requestHandler = HttpRequestHandler(connexions: connexions);
  _logger.info('Waiting for requests...');
  await for (HttpRequest request in server) {
    requestHandler.answer(request);
  }

  if (databaseBackend == DatabaseBackend.mysql) {
    await connection!.close();
  }
}
