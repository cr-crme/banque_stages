import 'dart:convert';
import 'dart:io';

import 'package:backend/html_response.dart';

void main() async {
  // Create an HTTP server listening on localhost:3456
  var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 3456);
  print('Server running on http://localhost:3456');

  await for (HttpRequest request in server) {
    answerHttpRequest(request, onContentParsed: _printContent);
  }
}

String _printContent(String endpoint, HttpMethod method, String? content) {
  print('Endpoint: $endpoint, Method: $method, Content: $content');

  switch (method) {
    case HttpMethod.get:
      return 'Hello from Dart server!';
    case HttpMethod.post:
    case HttpMethod.put:
    case HttpMethod.delete:
      return jsonEncode({
        'status': 'success',
        'message': 'Hello from Dart server!',
      });
  }
}
