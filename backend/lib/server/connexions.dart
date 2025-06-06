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
import 'package:common/utils.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

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
      _clients[client] = DatabaseUser.empty();

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

          // Send the handshake to the client
          _send(client,
              message: CommunicationProtocol(
                  requestType: RequestType.handshake,
                  response: Response.success,
                  data: _clients[client]!.serialize()));
          break;

        case RequestType.get:
          if (protocol.field == null) {
            throw MissingFieldException('Field is required to get data');
          }
          _logger.finer(
              'Getting data from field: ${protocol.field} for client ${client.hashCode}');
          await _send(client,
              message: CommunicationProtocol(
                  id: protocol.id,
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
                  id: protocol.id,
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
                  id: protocol.id,
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
        case RequestType.registerUser:
          // Limit this to admins only
          if ((_clients[client]?.accessLevel ?? AccessLevel.teacher) <
              AccessLevel.admin) {
            throw ConnexionRefusedException(
                'Client ${client.hashCode} is not authorized to register users');
          }

          final email = protocol.data?['email'] as String?;
          final password = protocol.data?['password'] as String?;

          final app = FirebaseAdmin.instance.app();
          if (email == null || app == null) {
            throw ConnexionRefusedException(
                'Firebase app is not initialized. Please check your configuration.');
          }
          await app.auth().createUser(email: email, password: password);

          await _send(client,
              message: CommunicationProtocol(
                  id: protocol.id,
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

        case RequestType.unregisterUser:
          // Limit this to admins only
          if ((_clients[client]?.accessLevel ?? AccessLevel.teacher) <
              AccessLevel.admin) {
            throw ConnexionRefusedException(
                'Client ${client.hashCode} is not authorized to unregister users');
          }

          final email = protocol.data?['email'] as String?;

          final app = FirebaseAdmin.instance.app();
          if (email == null || app == null) {
            throw ConnexionRefusedException(
                'Firebase app is not initialized. Please check your configuration.');
          }

          final user = await app.auth().getUserByEmail(email);
          await app.auth().deleteUser(user.uid);

          await _send(client,
              message: CommunicationProtocol(
                  id: protocol.id,
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

        case RequestType.changedPassword:
          final tableName =
              switch ((_clients[client]?.accessLevel ?? AccessLevel.teacher)) {
            AccessLevel.teacher => 'teachers',
            AccessLevel.admin || AccessLevel.superAdmin => 'admins',
          };
          MySqlHelpers.performUpdateQuery(
            connection: _database.connection,
            tableName: tableName,
            filters: {'id': _clients[client]!.userId!},
            data: {
              'should_change_password': false,
            },
          );
          await _send(client,
              message: CommunicationProtocol(
                  id: protocol.id,
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

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
              response: Response.connexionRefused));
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
    final email = payload['email'] as String?;
    if (authenticatorId == null || email == null) {
      throw ConnexionRefusedException('Invalid token payload');
    }

    // Get the user information from the database to first verify its identity
    final user = await _getValidatedUser(_database.connection,
        id: authenticatorId, email: email);
    if (user == null) throw ConnexionRefusedException('Invalid token payload');
    _clients[client] = user;
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

Future<DatabaseUser?> _getValidatedUser(MySqlConnection connection,
    {required String id, required String email}) async {
  // There are 3 possible cases:
  // 1. The user has previously connected so they will be in the 'users' table.
  //    We can retrieve their information from there and return it.
  // 2. The user has never connected before, but was added to the teachers database.
  //    We can retrieve their information from the 'teachers' table and provide
  //    them with an AccessLevel of 'user', register them in the 'users' table
  //    and return the user.
  // 3. The user has never connected before, and is not in the teachers database.
  //    This is probably someone who is not supposed to be using the app, so we
  //    return null to indicate that the user is not valid.

  // Slowly build the user object as we go through the cases
  var user = DatabaseUser.empty(authenticatorId: id);

  // At this point, we know the JWT is valid and secure. So we can safely use the email
  // to fetch the user information.
  // First, try to login via the 'users' table
  var users = (await MySqlHelpers.performSelectQuery(
    connection: connection,
    user: user,
    tableName: 'admins',
    filters: {'email': email},
    subqueries: [
      MySqlSelectSubQuery(
          dataTableName: 'teachers',
          idNameToDataTable: 'id',
          fieldsToFetch: ['school_id'])
    ],
  ) as List)
      .firstOrNull as Map<String, dynamic>?;

  user = user.copyWith(
    userId: users?['id'],
    schoolBoardId: users?['school_board_id'],
    schoolId: (users?['teachers'] as List?)?.firstOrNull?['school_id'],
    shouldChangePassword: users?['should_change_password'] == 1,
    accessLevel: AccessLevel.fromSerialized(users?['access_level']),
  );
  // This will be true if the user is an admin or a super admin
  if (user.isVerified) return user;

  // If there is information missing in the user structure, then we are not admin (case 1)
  // We therefore try to log using the information from the 'teachers' table
  final teacher = (await MySqlHelpers.performSelectQuery(
          connection: connection,
          user: user.copyWith(accessLevel: AccessLevel.superAdmin),
          tableName: 'persons',
          fieldsToFetch: [
        'email'
      ],
          filters: {
        'email': email
      },
          subqueries: [
        MySqlSelectSubQuery(
          dataTableName: 'teachers',
          idNameToDataTable: 'id',
          fieldsToFetch: [
            'id',
            'school_board_id',
            'school_id',
            'should_change_password'
          ],
        ),
      ]) as List)
      .firstOrNull;
  // If there is no teacher with that email, the user is not valid (case 3)
  if (teacher == null) return null;
  (teacher as Map).addAll((teacher['teachers'] as List).firstOrNull);

  // Otherwise, we probably are logging in a teacher (case 2
  user = user.copyWith(
    userId: teacher['id'],
    schoolBoardId: teacher['school_board_id'],
    schoolId: teacher['school_id'],
    accessLevel: AccessLevel.teacher,
    shouldChangePassword: teacher['should_change_password'] == 1,
  );

  // Just make sure, even though at this point it should always be verified
  if (user.isNotVerified) return null;
  return user;
}
