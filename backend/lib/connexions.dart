import 'dart:convert';
import 'dart:io';

import 'package:backend/database_manager.dart';
import 'package:backend/exceptions.dart';
import 'package:backend/utils.dart';
import 'package:common/communication_protocol.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Connexions');

class Connexions {
  final Map<WebSocket, dynamic> _clients = {};
  int get clientCount => _clients.length;
  final DatabaseManager _database = DatabaseManager();
  final Duration _timeout;

  Connexions({Duration timeout = const Duration(seconds: 5)})
      : _timeout = timeout;

  Future<bool> add(WebSocket client) async {
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
        if (DateTime.now().isAfter(start.add(_timeout))) {
          throw HandshakeException('Handshake timeout');
        }
      }
    } catch (e) {
      await _refuseConnexion(client, e.toString());
      return false;
    }

    // Send the handshake to the client
    _send(client,
        message: CommunicationProtocol(requestType: RequestType.handshake));
    return true;
  }

  Future<void> _incommingMessage(WebSocket client,
      {required dynamic message}) async {
    try {
      final map = jsonDecode(message);
      final protocol = CommunicationProtocol.deserialize(map);

      switch (protocol.requestType) {
        case RequestType.handshake:
          await _handleHandshake(client, protocol: protocol);
          break;

        case RequestType.get:
          if (protocol.field == null) {
            throw MissingFieldException('Field is required to get data');
          }
          await _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.response,
                  field: protocol.field,
                  data:
                      await _database.get(protocol.field!, data: protocol.data),
                  response: Response.success));
          break;

        case RequestType.post:
          if (protocol.field == null) {
            throw MissingFieldException(
                'Field is required to put or delete data');
          }
          await _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.response,
                  field: protocol.field,
                  data:
                      await _database.put(protocol.field!, data: protocol.data),
                  response: Response.success));
          // Notify all clients that the data has been updated
          await _sendAll(CommunicationProtocol(
            requestType: RequestType.update,
            field: protocol.field,
            data: await _database.get(protocol.field!, data: protocol.data),
          ));
          break;

        case RequestType.delete:
        case RequestType.response:
        case RequestType.update:
          throw InvalidRequestTypeException(
              'Invalid request type: ${protocol.requestType}');
      }
    } on HandshakeException catch (e) {
      await _refuseConnexion(client, e.toString());
    } on DatabaseException catch (e) {
      await _send(client,
          message: CommunicationProtocol(
              requestType: RequestType.response,
              data: {'error': e.toString()},
              response: Response.failure));
    } catch (e) {
      await _send(client,
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
      await _onConnexionClosed(client, message: 'Connexion closed');
    }
  }

  Future<void> _sendAll(CommunicationProtocol message) async {
    for (final client in _clients.keys) {
      _send(client, message: message);
    }
  }

  Future<void> _handleHandshake(WebSocket client,
      {required CommunicationProtocol protocol}) async {
    if (protocol.data == null) {
      throw HandshakeException('Data is required to validate the handshake');
    }
    if (protocol.data!['token'] == null) {
      throw HandshakeException('Token is required to validate the handshake');
    }
    final token = protocol.data!['token'];
    if (!isJwtValid(token)) {
      throw HandshakeException('Invalid token');
    }
    _clients[client]!['is_verified'] = true;
  }

  Future<void> _refuseConnexion(WebSocket client, String message) async {
    await _send(client,
        message: CommunicationProtocol(
            requestType: RequestType.response,
            field: null,
            data: {'error': message},
            response: Response.failure));
    await _onConnexionClosed(client, message: message);
  }

  Future<void> _onConnexionClosed(WebSocket client,
      {required String message}) async {
    await client.close();
    _clients.remove(client);
    _logger.info(message);
  }
}
