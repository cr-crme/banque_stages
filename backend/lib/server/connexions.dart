import 'dart:convert';
import 'dart:io';

import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/server/database_manager.dart';
import 'package:backend/utils/database_user.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:backend/utils/helpers.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/exceptions.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:logging/logging.dart';

final _logger = Logger('Connexions');

class Connexions {
  final Map<WebSocket, DatabaseUser> _clients = {};
  int get clientCount => _clients.length;
  final DatabaseManager _database;
  final Duration _timeout;

  // coverage:ignore-start
  Connexions({
    Duration timeout = const Duration(seconds: 5),
    required DatabaseManager database,
  })  : _timeout = timeout,
        _database = database;
  // coverage:ignore-end

  Future<bool> add(WebSocket client) async {
    try {
      _clients[client] = DatabaseUser.unverified();

      client.listen((message) => _incommingMessage(client, message: message),
          onDone: () => _onConnexionClosed(client,
              message: 'Client ${client.hashCode} disconnected'),
          onError: (error) =>
              _onConnexionClosed(client, message: 'Connexion error $error'));

      final startTime = DateTime.now();
      while (_clients[client]?.isNotVerified ?? true) {
        await Future.delayed(Duration(milliseconds: 100));

        // If client disconnected before the handshake was completed
        if (!_clients.containsKey(client)) return false;
        if (startTime.add(_timeout).isBefore(DateTime.now())) {
          throw ConnexionRefusedException('Handshake timeout');
        }
      }
    } catch (e) {
      await _refuseConnexion(client, e.toString());
      return false;
    }

    // Send the handshake to the client
    _send(client,
        message: CommunicationProtocol(
            requestType: RequestType.handshake,
            response: Response.success,
            data: {
              'user_id': _clients[client]!.databaseId,
              'access_level': _clients[client]!.accessLevel.name,
            }));
    return true;
  }

  Future<void> _incommingMessage(WebSocket client,
      {required dynamic message}) async {
    try {
      final map = jsonDecode(message);
      final protocol = CommunicationProtocol.deserialize(map);

      // Prevent unauthorized access to the database
      if ((_clients[client]?.isNotVerified ?? true) &&
          protocol.requestType != RequestType.handshake) {
        throw ConnexionRefusedException(
            'Client ${client.hashCode} not verified');
      }

      switch (protocol.requestType) {
        case RequestType.handshake:
          await _handleHandshake(client, protocol: protocol);
          break;

        case RequestType.get:
          if (protocol.field == null) {
            throw MissingFieldException('Field is required to get data');
          }
          _logger.finer(
              'Getting data from field: ${protocol.field} for client ${client.hashCode}');
          await _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.response,
                  field: protocol.field,
                  data: await _database.get(protocol.field!,
                      data: protocol.data, user: _clients[client]!),
                  response: Response.success));
          break;

        case RequestType.post:
          if (protocol.field == null) {
            throw MissingFieldException(
                'Field is required to put or delete data');
          }
          _logger.finer(
              'Putting data to field: ${protocol.field} for client ${client.hashCode}');
          final updatedFields = await _database.put(protocol.field!,
              data: protocol.data, user: _clients[client]!);
          await _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

          // Notify all clients that the data has been updated (but do not send
          // the actual new data. The client must request it for security reasons)
          if (updatedFields != null) {
            await _sendAll(CommunicationProtocol(
              requestType: RequestType.update,
              field: protocol.field,
              data: {
                'id': protocol.data?['id'],
                'updated_fields': updatedFields
              },
            ));
          }
          break;

        case RequestType.delete:
          if (protocol.field == null) {
            throw MissingFieldException('Field is required to get data');
          }
          _logger.info(
              'Deleting data from field: ${protocol.field} for client ${client.hashCode}');
          final deletedIds = await _database.delete(protocol.field!,
              data: protocol.data, user: _clients[client]!);
          await _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

          // Notify all clients that the data has been deleted
          if (deletedIds.isNotEmpty) {
            await _sendAll(CommunicationProtocol(
              requestType: RequestType.delete,
              field: protocol.field,
              data: {'deleted_ids': deletedIds},
            ));
          }

          break;

        case RequestType.response:
        case RequestType.update:
          _logger.finer(
              'Invalid request type: ${protocol.requestType} for client ${client.hashCode}');
          throw InvalidRequestTypeException(
              'Invalid request type: ${protocol.requestType}');
      }
    } on ConnexionRefusedException catch (e) {
      _logger.severe('Connexion refused for client ${client.hashCode}');
      await _send(client,
          message: CommunicationProtocol(
              requestType: RequestType.response,
              data: {'error': e.toString()},
              response: Response.failure));
    } on InternshipBankException catch (e) {
      _logger
          .severe('Error processing request for client ${client.hashCode}: $e');
      await _send(client,
          message: CommunicationProtocol(
              requestType: RequestType.response,
              data: {'error': e.toString()},
              response: Response.failure));
    } catch (e) {
      _logger.severe('Unrecognized error for client ${client.hashCode}: $e ');
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
      client.add(
          jsonEncode(message.copyWith(socketId: client.hashCode).serialize()));
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
      throw ConnexionRefusedException(
          'Data is required to validate the handshake');
    }
    if (protocol.data!['token'] == null) {
      throw ConnexionRefusedException(
          'Token is required to validate the handshake');
    }

    final payload = await extractJwt(protocol.data!['token']);
    if (payload == null) {
      throw ConnexionRefusedException('Invalid token');
    }
    final authenticatorId = payload['user_id'] as String?;
    if (authenticatorId == null) {
      throw ConnexionRefusedException('Invalid token payload');
    }

    // Get the user id from the database to first verify
    final users = (await MySqlHelpers.performSelectQuery(
            connection: _database.connection,
            tableName: 'users',
            filters: {
          'authenticator_id': authenticatorId,
        }) as List)
        .firstOrNull;
    if (users == null) throw ConnexionRefusedException('Invalid token payload');

    _clients[client] = DatabaseUser.verified(
      databaseId: users['shared_id'] as String,
      authenticatorId: authenticatorId,
      schoolBoardId: users['school_board_id'] as String? ?? '',
      accessLevel: AccessLevel.fromSerialized(users['access_level']),
    );
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
