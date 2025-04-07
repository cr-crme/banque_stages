import 'dart:io';

import 'package:backend/http_request_handler.dart';
import 'package:logging/logging.dart';

final _logger = Logger('BackendServer');

void main() async {
  // Set up logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create an HTTP server listening on localhost:3456
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3456);
  _logger.info('Server running on http://localhost:3456');

  final requestHandler =
      HttpRequestHandler(databaseBackend: DatabaseBackend.mock);
  _logger.info('Waiting for requests...');
  await for (HttpRequest request in server) {
    requestHandler.answer(request);
  }
}
