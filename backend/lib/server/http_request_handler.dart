import 'dart:io';

import 'package:backend/server/connexions.dart';
import 'package:backend/server/bug_report_management.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:backend/utils/network_rate_limiter.dart';
import 'package:common/services/backend_helpers.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AnswerHttpRequest');

class HttpRequestHandler {
  final Connexions? _devConnexions;
  final Connexions _productionConnexions;

  HttpRequestHandler(
      {required Connexions? devConnexions,
      required Connexions productionConnexions})
      : _devConnexions = devConnexions,
        _productionConnexions = productionConnexions;

  Future<void> answer(HttpRequest request,
      {NetworkRateLimiter? rateLimiter}) async {
    if (rateLimiter != null && rateLimiter.isRefused(request)) {
      _logger.warning(
          'Rate limit exceeded for ${request.connectionInfo?.remoteAddress.address}');
      request.response.statusCode = HttpStatus.tooManyRequests;
      request.response.write('Too Many Requests');
      await request.response.close();
      return;
    }

    try {
      if (request.method == 'OPTIONS') {
        return await _answerOptionsRequest(request);
      } else if (request.method == 'GET') {
        return await _answerGetRequest(request);
      } else if (request.method == 'POST') {
        return await _answerPostRequest(request);
      } else {
        // Handle other HTTP methods
        return await _sendConnexionRefused(request);
      }
    } on ConnexionRefusedException catch (e) {
      _logger.severe('Connexion refused: $e');
      request.response.statusCode = HttpStatus.unauthorized;
      request.response.write('Unauthorized: $e');
      await request.response.close();
    } catch (e) {
      // This is a catch-all for any exceptions so the server doesn't crash on an
      // unhandled/unexpected exception. This should never actually happens

      // Remove from test coverage (the next four lines)
      // coverage:ignore-start
      _logger.severe('Internal error: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Internal Server Error');
      await request.response.close();
      // coverage:ignore-end
    }
  }

  Future<void> _answerOptionsRequest(HttpRequest request) async {
    // Handle preflight requests
    request.response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
      // ..set('X-Frame-Options', 'ALLOWALL') // Uncomment this line if InAppWebView is used
      ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    await request.response.close();
  }

  Future<void> _answerGetRequest(HttpRequest request) async {
    if (request.uri.path ==
        '/${BackendHelpers.connectEndpoint(isDev: false)}') {
      _logger.info('Received a connection request to the production database');
      try {
        _productionConnexions.add(await WebSocketTransformer.upgrade(request));
        return;
      } catch (e) {
        _logger.severe('Error during WebSocket upgrade: $e');
        throw ConnexionRefusedException('WebSocket upgrade failed');
      }
    } else if (request.uri.path ==
        '/${BackendHelpers.connectEndpoint(isDev: true)}') {
      _logger.info('Received a connection request to the development database');
      try {
        _devConnexions?.add(await WebSocketTransformer.upgrade(request));
        return;
      } catch (e) {
        _logger.severe('Error during WebSocket upgrade: $e');
        throw ConnexionRefusedException('WebSocket upgrade failed');
      }
    } else {
      throw ConnexionRefusedException('Invalid endpoint');
    }
  }

  Future<void> _answerPostRequest(HttpRequest request) async {
    if (request.uri.path == '/${BackendHelpers.bugReportEndpoint}') {
      await answerBugReportRequest(request);
    } else {
      throw ConnexionRefusedException('Invalid endpoint');
    }
  }

  Future<void> _sendConnexionRefused(HttpRequest request) async {
    request.response.statusCode = HttpStatus.unauthorized;
    request.response.write('Unauthorized');
    await request.response.close();
  }
}
