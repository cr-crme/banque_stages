import 'dart:io';

import 'package:backend/connexions.dart';
import 'package:backend/database_manager.dart';
import 'package:backend/database_teachers.dart';
import 'package:backend/http_request_handler.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('BackendServer');

enum DatabaseBackend { mysql, mock }

void main() async {
  // Set up logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create an HTTP server listening on localhost:3456
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3456);
  _logger.info('Server running on http://localhost:3456');
  final databaseBackend = DatabaseBackend.mock;

  _logger.info('Using database backend: ${databaseBackend.name}');
  final requestHandler = HttpRequestHandler(
      connexions: Connexions(
          database: DatabaseManager(
    teacherDatabase: switch (databaseBackend) {
      DatabaseBackend.mysql => MySqlDatabaseTeacher(
            connection: await MySqlConnection.connect(ConnectionSettings(
          host: 'localhost',
          port: 3306,
          user: 'user_to_be_defined',
          password: 'password_to_be_defined',
          db: 'database_to_be_defined',
        ))),
      DatabaseBackend.mock => DatabaseTeachersMock()
    },
  )));
  _logger.info('Waiting for requests...');
  await for (HttpRequest request in server) {
    requestHandler.answer(request);
  }
}
