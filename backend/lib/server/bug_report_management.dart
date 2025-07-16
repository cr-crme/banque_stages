import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

final _logger = Logger('BanqueStagesApp');

Future<void> answerBugReportRequest(HttpRequest request) async {
  _logger.info('Received a post bug request');

  final body = await utf8.decoder.bind(request).join();
  final data = jsonDecode(body);

  // Sanitize timestamp for filename
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
  final file = File('error_report_$timestamp.log');

  // Parse the data
  final error = data['error'] ?? 'No error provided';
  final stackTrace = data['stack_trace'] ?? 'No stack trace';
  final breadcrumbs = data['breadcrumbs'] ?? 'No breadcrumbs';
  final content = '''
Breadcrumbs:
$breadcrumbs

--------------------------

Error:
$error

Stack Trace:
$stackTrace

''';

  // Write the error report to a log file
  await file.writeAsString(content);

  // Response to the client
  request.response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.text
    ..write('Bug report received');
  await request.response.close();
}
