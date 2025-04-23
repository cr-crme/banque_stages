import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

enum HttpMethod { get, post, put, delete }

Future<bool> _validateBearer(HttpRequest request) async {
  final bearer = request.headers['Authorization']?.first;
  if (bearer == null || !bearer.startsWith('Bearer ')) {
    await _sendConnexionRefused(request);
    return false;
  }

  try {
    final token = bearer.substring(7);
    JWT.verify(token, SecretKey('secret passphrase'));
    return true;
  } catch (e) {
    await _sendConnexionRefused(request);
    return false;
  }
}

Future<void> _sendConnexionRefused(HttpRequest request) async {
  request.response.statusCode = HttpStatus.unauthorized;
  request.response.write('Unauthorized');
  await request.response.close();
}

Future<void> _prepareResponseHeader(HttpRequest request) async {
  request.response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
    // ..set('X-Frame-Options', 'ALLOWALL') // Uncomment this line if InAppWebView is used
    ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

Future<void> answerHttpRequest(HttpRequest request,
    {required String Function(
            String endpoint, HttpMethod method, String? content)
        onContentParsed}) async {
  try {
    if (request.method == 'OPTIONS') {
      // Handle preflight requests
      _prepareResponseHeader(request);
      await request.response.close();
      return;
    } else if (request.method == 'GET') {
      if (!await _validateBearer(request)) return;

      _prepareResponseHeader(request);
      request.response
          .write(onContentParsed(request.uri.path, HttpMethod.get, null));
      await request.response.close();
      return;
    } else if (request.method == 'POST') {
      // Validate the Bearer token
      if (!await _validateBearer(request)) return;

      _prepareResponseHeader(request);
      request.response.write(onContentParsed(request.uri.path, HttpMethod.post,
          await utf8.decoder.bind(request).join()));
      await request.response.close();
      return;
    } else {
      // Handle other HTTP methods
      await _sendConnexionRefused(request);
      return;
    }
  } catch (e) {
    print('Error processing request: $e');
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write('Internal Server Error');
    await request.response.close();
  }
}
