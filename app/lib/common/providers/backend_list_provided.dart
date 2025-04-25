import 'dart:developer' as dev;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common/communication_protocol.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:enhanced_containers/database_list_provided.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';
import 'package:web_socket_client/web_socket_client.dart';

/// A [BackendListProvided] that automagically saves all of its into the backend
/// implemented in $ROOT/backend,
///
/// Written by: @pariterre
abstract class BackendListProvided<T extends ItemSerializable>
    extends DatabaseListProvided<T> {
  final Uri uri;
  static bool _handshakeReceived = false;
  bool get isConnected =>
      _deserializers[getField()] != null &&
      _socket != null &&
      _handshakeReceived;
  static WebSocket? _socket;

  final Map<RequestFields, Function(Map<String, dynamic>)> _deserializers = {};

  /// Creates a [BackendListProvided] with the specified data path and ids path.
  BackendListProvided({required this.uri, this.mockMe = false});

  /// This method should be called after the user has logged on
  @override
  Future<void> initializeFetchingData({AuthProvider? authProvider}) async {
    if (isConnected) return;
    if (authProvider == null) {
      throw Exception('AuthProvider is required to initialize the connection');
    }

    // Get the JWT token
    String token = authProvider.jwt;

    // If the socket is already connected, it means another provider is already connected
    // Simply return now after having kept the reference to the deserializer function
    if (_socket == null) {
      try {
        // Send a connexion request to the server
        _socket = WebSocket(
          uri,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          timeout: const Duration(seconds: 5),
        );

        _socket!.connection.listen((event) {
          if (event is Connected || event is Reconnected) {
            _socket!.send(jsonEncode(CommunicationProtocol(
                requestType: RequestType.handshake,
                data: {'token': token}).serialize()));
          } else if (event is Disconnected) {
            _handshakeReceived = false;
            notifyListeners();
          }
        });
        _socket!.messages.listen(_incommingMessage);

        final started = DateTime.now();
        while (!_handshakeReceived) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (DateTime.now().isAfter(started.add(const Duration(seconds: 5)))) {
            throw Exception('Handshake timeout');
          }
        }
      } catch (e) {
        dev.log('Error while connecting to the server: $e',
            error: e, stackTrace: StackTrace.current);
        stopFetchingData();
      }
    }

    // Keep a reference to the deserializer function
    _deserializers[getField()] = deserializeItem;
    _deserializers[getField(true)] = deserializeItemCollection;

    // Send a get request to the server for the list of items
    while (!_handshakeReceived) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_socket == null) {
        throw Exception('Connection to the server failed');
      }
    }
    _get();
  }

  /// Returns a new [T] from the provided serialized data.
  List<T> deserializeItemCollection(data);

  @override
  Future<void> stopFetchingData() async {
    _socket?.close();
    _socket = null;

    _deserializers.remove(getField());
    _deserializers.remove(getField(true));
    _handshakeReceived = false;

    super.clear();
  }

  final bool mockMe;

  bool isOfCorrectRequestFields(RequestFields field) =>
      field == getField(false) || field == getField(true);
  bool isNotOfCorrectRequestFields(RequestFields field) =>
      !isOfCorrectRequestFields(field);

  RequestFields getField([bool asList = false]);

  Function(Map<String, dynamic>) _getDeserializer(RequestFields field) {
    final deserializer = _deserializers[field];
    if (deserializer == null) {
      throw Exception(
          'No deserializer found for field $field, please call initializeFetchingData()');
    }
    return deserializer;
  }

  Future<void> _incommingMessage(message) async {
    try {
      final map = jsonDecode(message);
      final protocol = CommunicationProtocol.deserialize(map);
      switch (protocol.requestType) {
        case RequestType.handshake:
          {
            _handshakeReceived = true;
            notifyListeners();
            return;
          }
        case RequestType.response:
          {
            if (protocol.data == null || protocol.field == null) return;
            if (isNotOfCorrectRequestFields(protocol.field!)) return;

            final values = _getDeserializer(protocol.field!)(protocol.data!);
            if (values is List) {
              for (final item in values) {
                super.add(item, notify: false);
              }
            } else {
              super.add(values, notify: false);
            }
            notifyListeners();
            return;
          }
        case RequestType.update:
          {
            _get(
                id: protocol.data!['id'],
                fields: (protocol.data!['updated_fields'] as List?)
                    ?.cast<String>());
            return;
          }
        case RequestType.delete:
          {
            if (protocol.data == null || protocol.field == null) return;
            if (isNotOfCorrectRequestFields(protocol.field!)) return;

            final deletedIds =
                (protocol.data!['deleted_ids'] as List).cast<String>();
            for (final id in deletedIds) {
              super.remove(id, notify: false);
            }
            notifyListeners();
            return;
          }
        case RequestType.get:
        case RequestType.post:
          throw Exception('Unsupported request type: ${protocol.requestType}');
      }
    } catch (e) {
      dev.log(e.toString(), error: e, stackTrace: StackTrace.current);
      return;
    }
  }

  void _sanityChecks({required bool notify}) {
    assert(notify, 'Notify has no effect here and should not be used.');
    assert(isConnected, 'Please call \'initializeFetchingData\' at least once');
  }

  void _get({String? id, List<String>? fields}) {
    final message = jsonEncode(CommunicationProtocol(
      requestType: RequestType.get,
      field: getField(id == null), // Id is not null for item of the list
      data: id == null ? null : {'id': id, 'fields': fields},
    ).serialize());
    _socket?.send(message);
  }

  /// Adds an item to the Realtime Database.
  ///
  /// Note that [notify] has no effect here and should not be used.
  @override
  void add(T item, {bool notify = true}) {
    _sanityChecks(notify: notify);

    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: getField(),
        data: item.serialize(),
      ).serialize());
      _socket?.send(message);
    } on Exception {
      // Make sure to keep the list in sync with the database
      notifyListeners();
    }

    if (mockMe) {
      super.add(item, notify: true);
    }
  }

  /// Inserts elements in a list of a logged user
  ///
  void insertInList(String pathToItem, ListSerializable<T> items) {
    try {
      for (final item in items) {
        add(item, notify: true);
      }
    } on Exception {
      // Make sure to keep the list in sync with the database
      notifyListeners();
    }
  }

  /// Replaces the current item by [item] in the Realtime Database.
  /// The item to replace is identified by its id.
  ///
  /// Note that [notify] has no effect here and should not be used.
  @override
  Future<void> replace(T item, {bool notify = true}) async {
    _sanityChecks(notify: notify);

    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: getField(),
        data: item.serialize(),
      ).serialize());
      _socket?.send(message);
    } on Exception {
      // Make sure to keep the list in sync with the database
      notifyListeners();
    }
    if (mockMe) {
      super.replace(item, notify: true);
    }
  }

  /// You can't not use this function with [FirebaseListProvided] in case the ids of the provided values dont match.
  /// Use the function [replace] intead.
  @override
  operator []=(value, T item) {
    throw const ShouldNotCall(
        'You should not use this operator. Use the function replace instead.');
  }

  /// Removes an item from the Realtime Database.
  ///
  /// Note that [notify] has no effect here and should not be used.
  @override
  void remove(value, {bool notify = true}) {
    _sanityChecks(notify: notify);

    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.delete,
        field: getField(),
        data: value.serialize(),
      ).serialize());
      _socket?.send(message);
    } on Exception {
      // Make sure to keep the list in sync with the database
      notifyListeners();
    }

    if (mockMe) {
      super.remove(value, notify: true);
    }
  }

  /// Removes all objects from this list and from the Realtime Database; the length of the list becomes zero.
  /// Setting [confirm] to true is required in order to call this function as a 'security' mesure.
  ///
  /// Note that [notify] has no effect here and should not be used.
  @override
  void clear({bool confirm = false, bool notify = true}) {
    _sanityChecks(notify: notify);
    if (!confirm) {
      throw const ShouldNotCall(
          'You almost cleared the entire database ! Set the parameter confirm to true if that was really your intention.');
    }

    for (final item in this) {
      remove(item);
    }
  }
}
