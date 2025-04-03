import 'dart:io';

import 'package:backend/connexions.dart';
import 'package:backend/utils.dart';
import 'package:logging/logging.dart';

final _logger = Logger('HttpResponse');
final _connexions = Connexions();

// TODO: What happens if two persons modify the same data at the same time?

Future<void> answerHttpRequest(HttpRequest request) async {
  try {
    if (request.method == 'OPTIONS') {
      await _answerOptionsRequest(request);
      return;
    } else if (request.method == 'GET') {
      await _answerGetRequest(request);
      return;
    } else {
      // Handle other HTTP methods
      await _sendConnexionRefused(request);
      return;
    }
  } catch (e) {
    _logger.severe('Error processing request: $e');
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write('Internal Server Error');
    await request.response.close();
  }
}

Future<void> _answerOptionsRequest(HttpRequest request) async {
  // Handle preflight requests
  request.response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, OPTIONS')
    // ..set('X-Frame-Options', 'ALLOWALL') // Uncomment this line if InAppWebView is used
    ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  await request.response.close();
}

Future<void> _answerGetRequest(HttpRequest request) async {
  if (request.uri.path == '/connect') {
    _logger.info('Received a connection request');
    _connexions.add(await WebSocketTransformer.upgrade(request));
    return;
  } else if (request.uri.path == '/admin') {
    final token = await _getOauthToken(request);
    if (token == null) return;
    // TODO: Check the token if user is admin, otherwise refuse the connexion
    await _sendConnexionRefused(request);
    return;
  } else {
    await _sendConnexionRefused(request);
    return;
  }
}

Future<String?> _getOauthToken(HttpRequest request) async {
  final bearer = request.headers['Authorization']?.first;
  if (bearer == null || !bearer.startsWith('Bearer ')) {
    await _sendConnexionRefused(request);
    return null;
  }

  try {
    final token = bearer.substring(7);
    if (!isJwtValid(token)) throw 'Invalid token';
    return token;
  } catch (e) {
    await _sendConnexionRefused(request);
    return null;
  }
}

Future<void> _sendConnexionRefused(HttpRequest request) async {
  request.response.statusCode = HttpStatus.unauthorized;
  request.response.write('Unauthorized');
  await request.response.close();
}
