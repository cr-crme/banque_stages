import 'dart:convert';
import 'dart:io';

import 'package:backend/database_manager.dart';
import 'package:backend/utils.dart';
import 'package:common/communication_protocol.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Connexions');

class Connexions {
  final Map<WebSocket, dynamic> _clients = {};
  final DatabaseManager _database = DatabaseManager();

  Future<void> add(WebSocket client) async {
    try {
      _clients[client] = {'is_verified': false};

      client.listen((message) => _incommingMessage(client, message: message),
          onDone: () =>
              _onConnexionClosed(client, message: 'Client disconnected'),
          onError: (error) =>
              _onConnexionClosed(client, message: 'Connexion error $error'));

      DateTime start = DateTime.now();
      while (!_clients[client]!['is_verified']) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (DateTime.now().isAfter(start.add(const Duration(seconds: 5)))) {
          throw 'Handshake timeout';
        }
      }
    } catch (e) {
      await _refuseConnexion(client, message: e.toString());
      return;
    }

    // Send the handshake to the client
    _send(client,
        message: CommunicationProtocol(requestType: RequestType.handshake));
  }

  Future<void> _refuseConnexion(WebSocket client, {String? message}) async {
    await _send(client,
        message: CommunicationProtocol(
            requestType: RequestType.response,
            field: null,
            data: {'error': message ?? 'Connexion refused'},
            response: Response.failure));
    _onConnexionClosed(client, message: message ?? 'Connexion refused');
  }

  void _onConnexionClosed(WebSocket client, {required String message}) {
    _clients.remove(client);
    _logger.info(message);
  }

  Future<void> _incommingMessage(WebSocket client,
      {required dynamic message}) async {
    try {
      final map = jsonDecode(message);
      final protocol = CommunicationProtocol.deserialize(map);

      switch (protocol.requestType) {
        case RequestType.handshake:
          _validateHandshake(client, protocol: protocol);
        case RequestType.get:
          try {
            if (protocol.field == null) {
              throw Exception('Field is required to get data');
            }
            _send(client,
                message: CommunicationProtocol(
                    requestType: RequestType.response,
                    field: protocol.field,
                    data: await _database.get(protocol.field!,
                        data: protocol.data),
                    response: Response.success));
          } catch (e) {
            _send(client,
                message: CommunicationProtocol(
                    requestType: RequestType.response,
                    field: protocol.field,
                    data: {'error': e.toString()},
                    response: Response.failure));
          }

        case RequestType.post:
        case RequestType.delete:
          try {
            if (protocol.field == null) {
              throw Exception('Field is required to put or delete data');
            }
            _send(client,
                message: CommunicationProtocol(
                    requestType: RequestType.response,
                    field: protocol.field,
                    data: await _database.put(protocol.field!,
                        data: protocol.data),
                    response: Response.success));
            // Notify all clients that the data has been updated
            _sendAll(CommunicationProtocol(
              requestType: RequestType.update,
              field: protocol.field,
              data: await _database.get(protocol.field!, data: protocol.data),
            ));
          } catch (e) {
            _send(client,
                message: CommunicationProtocol(
                    requestType: RequestType.response,
                    field: protocol.field,
                    data: {'error': e.toString()},
                    response: Response.failure));
          }
          break;
        case RequestType.response:
        case RequestType.update:
          // Invalid request type for the server
          _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.response,
                  field: protocol.field,
                  data: {'error': 'Invalid request type for the server'},
                  response: Response.failure));
      }
    } catch (e) {
      _send(client,
          message: CommunicationProtocol(
              requestType: RequestType.response,
              data: {'error': 'Invalid message format: $e'},
              response: Response.failure));
    }
  }

  Future<void> _send(WebSocket client,
      {required CommunicationProtocol message}) async {
    try {
      client.add(jsonEncode(message.serialize()));
    } catch (e) {
      // If we can't send the message, we can assume the client is disconnected
      _onConnexionClosed(client, message: 'Connexion closed');
    }
  }

  Future<void> _sendAll(CommunicationProtocol message) async {
    for (var client in _clients.values) {
      _send(client, message: message);
    }
  }

  Future<void> _validateHandshake(WebSocket client,
      {required CommunicationProtocol protocol}) async {
    try {
      if (protocol.data == null) {
        throw Exception('Data is required to validate the handshake');
      }
      if (protocol.data!['token'] == null) {
        throw Exception('Token is required to validate the handshake');
      }
      final token = protocol.data!['token'];
      if (!isJwtValid(token)) {
        throw Exception('Invalid token');
      }
      _clients[client]!['is_verified'] = true;
    } catch (e) {
      await _refuseConnexion(client, message: e.toString());
    }
  }
}
