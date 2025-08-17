import 'dart:convert';
import 'dart:io';

import 'package:firebase_admin/firebase_admin.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:stagess_backend/repositories/repository_abstract.dart';
import 'package:stagess_backend/repositories/sql_interfaces.dart';
import 'package:stagess_backend/server/database_manager.dart';
import 'package:stagess_backend/utils/database_user.dart';
import 'package:stagess_backend/utils/exceptions.dart';
import 'package:stagess_backend/utils/helpers.dart';
import 'package:stagess_common/communication_protocol.dart';
import 'package:stagess_common/exceptions.dart';
import 'package:stagess_common/models/generic/access_level.dart';
import 'package:stagess_common/utils.dart';

final _logger = Logger('Connexions');

class Connexions {
  final Map<WebSocket, DatabaseUser> _clients = {};
  int get clientCount => _clients.length;
  final DatabaseManager _database;
  DatabaseManager get database => _database;
  final Duration _timeout;
  final String _firebaseApiKey;

  // coverage:ignore-start
  Connexions({
    Duration timeout = const Duration(seconds: 5),
    required DatabaseManager database,
    required String firebaseApiKey,
  })  : _timeout = timeout,
        _database = database,
        _firebaseApiKey = firebaseApiKey;
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
        case RequestType.post:
        case RequestType.delete:
          if (protocol.field == null) {
            throw MissingFieldException(
                'Field is required to ${protocol.requestType.name} data');
          }
          _logger.finer(
              '${protocol.requestType.name} data to field: ${protocol.field} for '
              'client ${client.hashCode}');
          final response = switch (protocol.requestType) {
            RequestType.get => await _database.get(protocol.field!,
                data: protocol.data, user: _clients[client]!),
            RequestType.post => await _database.put(protocol.field!,
                data: protocol.data, user: _clients[client]!),
            RequestType.delete => await _database.delete(protocol.field!,
                data: protocol.data, user: _clients[client]!),
            _ => throw InvalidRequestTypeException(
                'Invalid request type: ${protocol.requestType}'),
          };
          _sendSuccessResponse(
              client: client, protocol: protocol, response: response);
          break;

        case RequestType.registerUser:
          final myAccessLevel =
              _clients[client]?.accessLevel ?? AccessLevel.invalid;
          final email = protocol.data?['email'] as String?;
          final userType =
              AccessLevel.fromSerialized(protocol.data?['user_type']);
          if (email == null || userType == AccessLevel.invalid) {
            throw ConnexionRefusedException('Invalid request data.');
          }

          final app = FirebaseAdmin.instance.app();
          if (app == null) {
            throw ConnexionRefusedException(
                'Firebase app is not initialized. Please check your configuration.');
          }

          // Get the related user data
          late Map<String, dynamic>? user;
          switch (userType) {
            case AccessLevel.teacher:
              if (myAccessLevel < AccessLevel.admin) {
                throw ConnexionRefusedException(
                    'Client ${client.hashCode} is not authorized to register user');
              }
              user = await _getTeacherFromDatabase(
                  user: _clients[client]!,
                  sqlInterface: _database.sqlInterface,
                  email: email);
              break;
            case AccessLevel.admin:
              if (myAccessLevel < AccessLevel.superAdmin) {
                throw ConnexionRefusedException(
                    'Client ${client.hashCode} is not authorized to register user');
              }
              user = await _getAdminFromDatabase(
                  user: _clients[client]!,
                  sqlInterface: _database.sqlInterface,
                  email: email);
              break;
            case AccessLevel.superAdmin:
            case AccessLevel.invalid:
              throw ConnexionRefusedException(
                  'Client ${client.hashCode} is not authorized to register user.');
          }

          // Make sure only previously added teachers can be registered
          if (user == null || user['has_registered_account'] == 1) {
            throw ConnexionRefusedException(
                'No user found with email $email. Please add the user to the database before registering them.');
          }

          // Register the user in Firebase
          try {
            await app.auth().createUser(email: email, emailVerified: false);
            await _sendPasswordResetEmail(email, _firebaseApiKey);
          } on FirebaseAuthError catch (e) {
            if (e.code == 'auth/email-already-exists') {
              // Continue as it means the user is registered
            } else {
              rethrow;
            }
          }
          // Send confirmation to the client
          await _send(client,
              message: CommunicationProtocol(
                  id: protocol.id,
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

          // Add the confirmation to the database
          final field = switch (userType) {
            AccessLevel.teacher => RequestFields.teacher,
            AccessLevel.admin => RequestFields.admin,
            AccessLevel.superAdmin ||
            AccessLevel.invalid =>
              throw 'Client ${client.hashCode} is not authorized to register user.',
          };
          await _database.put(field,
              data: {'id': user['id'], 'has_registered_account': true},
              user: _clients[client]!);

          // Notify all clients that the teacher has registered an account
          await _sendAll(CommunicationProtocol(
            requestType: RequestType.update,
            field: field,
            data: {
              'id': user['id'],
              'updated_fields': ['has_registered_account']
            },
          ));

        case RequestType.unregisterUser:
          final myAccessLevel =
              _clients[client]?.accessLevel ?? AccessLevel.invalid;
          final email = protocol.data?['email'] as String?;
          final userType =
              AccessLevel.fromSerialized(protocol.data?['user_type']);
          if (email == null || userType == AccessLevel.invalid) {
            throw ConnexionRefusedException('Invalid request data.');
          }

          final app = FirebaseAdmin.instance.app();
          if (app == null) {
            throw ConnexionRefusedException(
                'Firebase app is not initialized. Please check your configuration.');
          }

          // Delete the user from Firebase
          try {
            final user = await app.auth().getUserByEmail(email);
            await app.auth().deleteUser(user.uid);
          } on FirebaseAuthError catch (e) {
            if (e.code == 'auth/user-not-found') {
              // Continue as it means the user is not registered
            } else {
              rethrow;
            }
          }
          // Send confirmation to the client
          await _send(client,
              message: CommunicationProtocol(
                  id: protocol.id,
                  requestType: RequestType.response,
                  field: protocol.field,
                  response: Response.success));

          // Adjust the internal database to reflect the unregistration
          late Map<String, dynamic>? user;
          switch (userType) {
            case AccessLevel.teacher:
              if (myAccessLevel < AccessLevel.admin) {
                throw ConnexionRefusedException(
                    'Client is not authorized to register user');
              }
              user = await _getTeacherFromDatabase(
                  user: _clients[client]!,
                  sqlInterface: _database.sqlInterface,
                  email: email);
              break;
            case AccessLevel.admin:
              if (myAccessLevel < AccessLevel.superAdmin) {
                throw ConnexionRefusedException(
                    'Client is not authorized to register user');
              }
              user = await _getAdminFromDatabase(
                  user: _clients[client]!,
                  sqlInterface: _database.sqlInterface,
                  email: email);
              break;
            case AccessLevel.superAdmin:
            case AccessLevel.invalid:
              throw ConnexionRefusedException(
                  'Client is not authorized to register user.');
          }

          if (user != null) {
            // Remove the confirmation from the database
            final field = switch (userType) {
              AccessLevel.teacher => RequestFields.teacher,
              AccessLevel.admin => RequestFields.admin,
              AccessLevel.invalid ||
              AccessLevel.superAdmin =>
                throw 'Client is not authorized to register user.',
            };

            await _database.put(field,
                data: {'id': user['id'], 'has_registered_account': false},
                user: _clients[client]!);
            // Notify all clients that the teacher has unregistered an account
            await _sendAll(CommunicationProtocol(
              requestType: RequestType.update,
              field: field,
              data: {
                'id': user['id'],
                'updated_fields': ['has_registered_account']
              },
            ));
          }

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

  Future<void> _sendSuccessResponse({
    required WebSocket client,
    required CommunicationProtocol protocol,
    required RepositoryResponse response,
  }) async {
    await _send(client,
        message: CommunicationProtocol(
            id: protocol.id,
            requestType: RequestType.response,
            field: protocol.field,
            data: response.data,
            response: Response.success));

    // Notify all clients for the fields that were updated, but do not send the
    // actual new data. The client must request it for security reasons
    for (final field in response.updatedData?.keys ?? <RequestFields>[]) {
      for (final updatedId in response.updatedData![field]!.keys) {
        _logger.finer(
            'Client ${client.hashCode} updated $field for id $updatedId');
        final updateFields = response.updatedData![field]![updatedId]!;
        if (updateFields.isEmpty) continue;

        await _sendAll(CommunicationProtocol(
          requestType: RequestType.update,
          field: field,
          data: {'id': updatedId, 'updated_fields': updateFields},
        ));
      }
    }

    // Notify all clients for the fields that were deleted
    for (final field in response.deletedData?.keys ?? <RequestFields>[]) {
      final deletedIds = response.deletedData![field]!;
      if (deletedIds.isEmpty) continue;

      await _sendAll(CommunicationProtocol(
        requestType: RequestType.delete,
        field: field,
        data: {'deleted_ids': deletedIds},
      ));
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
    final user = await _getValidatedUser(_database.sqlInterface,
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

Future<DatabaseUser?> _getValidatedUser(SqlInterface sqlInterface,
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
  var users = await _getAdminFromDatabase(
      user: user, sqlInterface: sqlInterface, email: email);

  user = user.copyWith(
    userId: users?['id'],
    schoolBoardId: users?['school_board_id'],
    schoolId: (users?['teachers'] as List?)?.firstOrNull?['school_id'],
    accessLevel: AccessLevel.fromSerialized(users?['access_level']),
  );
  // This will be true if the user is an admin or a super admin
  if (user.isVerified) return user;

  // If there is information missing in the user structure, then we are not admin (case 1)
  // We therefore try to log using the information from the 'teachers' table
  final teacher = await _getTeacherFromDatabase(
      user: user, sqlInterface: sqlInterface, email: email);
  // If there is no teacher with that email, the user is not valid (case 3)
  if (teacher == null) return null;
  (teacher as Map).addAll((teacher['teachers'] as List).firstOrNull);

  // Otherwise, we probably are logging in a teacher (case 2
  user = user.copyWith(
    userId: teacher['id'],
    schoolBoardId: teacher['school_board_id'],
    schoolId: teacher['school_id'],
    accessLevel: AccessLevel.teacher,
  );

  // Just make sure, even though at this point it should always be verified
  if (user.isNotVerified) return null;
  return user;
}

Future<Map<String, dynamic>?> _getTeacherFromDatabase(
    {required DatabaseUser user,
    required SqlInterface sqlInterface,
    required String email}) async {
  final teacher = (await sqlInterface.performSelectQuery(
          user: user.copyWith(accessLevel: AccessLevel.superAdmin),
          tableName: 'persons',
          fieldsToFetch: [
        'email'
      ],
          filters: {
        'email': email
      },
          subqueries: [
        sqlInterface.selectSubquery(
          dataTableName: 'teachers',
          idNameToDataTable: 'id',
          fieldsToFetch: [
            'id',
            'school_board_id',
            'school_id',
            'has_registered_account',
          ],
        ),
      ]) as List)
      .firstOrNull;
  if (teacher == null || teacher['teachers'] == null) return null;

  (teacher as Map).addAll((teacher['teachers'] as List).firstOrNull);
  return teacher as Map<String, dynamic>?;
}

Future<Map<String, dynamic>?> _getAdminFromDatabase(
    {required DatabaseUser user,
    required SqlInterface sqlInterface,
    required String email}) async {
  return (await sqlInterface.performSelectQuery(
    user: user,
    tableName: 'admins',
    filters: {'email': email},
    subqueries: [
      sqlInterface.selectSubquery(
          dataTableName: 'teachers',
          idNameToDataTable: 'id',
          fieldsToFetch: ['school_id'])
    ],
  ) as List)
      .firstOrNull as Map<String, dynamic>?;
}

Future<void> _sendPasswordResetEmail(String email, String apiKey) async {
  final uri = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$apiKey',
  );

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'requestType': 'PASSWORD_RESET',
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    _logger.info('Password initialization email sent to $email');
  } else {
    throw ConnexionRefusedException('Failed to send password reset email');
  }
}
