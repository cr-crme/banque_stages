import 'dart:convert';
import 'dart:io';

import 'package:common/communication_protocol.dart';
import 'package:common/teacher.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_client/web_socket_client.dart';

final Map<String, Teacher> _dummyTeachers = {};
Future<void> _updateTeachers(Map<String, dynamic> data) async {
  if (data.containsKey("id")) {
    // Update a single teacher
    final id = data["id"];
    final teacherData = data;
    _dummyTeachers[id] = _dummyTeachers.containsKey(id)
        ? _dummyTeachers[id]!.copyWithData(teacherData)
        : Teacher.deserialize(teacherData);
  } else {
    // Update all teachers
    for (final entry in data.entries) {
      final id = entry.key;
      final teacherData = entry.value;
      _dummyTeachers[id] = _dummyTeachers.containsKey(id)
          ? _dummyTeachers[id]!.copyWithData(teacherData)
          : Teacher.deserialize(teacherData);
    }
  }
}

void main() {
  runApp(const MyApp());
}

class Token {
  final String? accessToken;
  final String? idToken;

  Token({required this.accessToken, required this.idToken});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  WebSocket? _socket;
  bool _handshakeReceived = false;
  bool get isConnecting => _socket != null && !_handshakeReceived;
  bool get isConnected => _socket != null && _handshakeReceived;

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: isConnecting || isConnected ? null : _connect,
                child: Text(isConnecting ? 'Connecting...' : 'Connect')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _getTeachers : null,
                child: Text('Get teacher')),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: isConnected && _controller.text.isNotEmpty
                        ? _changeTeacher
                        : null,
                    child: Text('Change teacher')),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    enabled: isConnected,
                    decoration: InputDecoration(
                      labelText: 'New age',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? _closeConnexion : null,
              child: Text('Disconnect'),
            ),
            ..._dummyTeachers.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    if (isConnected) return;

    // Get the JWT token
    String token = _getJwtToken();

    // Send a get request to the server
    try {
      _socket = WebSocket(
        Uri.parse('ws://localhost:3456/connect'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        timeout: const Duration(seconds: 5),
      );
      setState(() {});
      _socket!.connection.listen((event) {
        if (event is Connected || event is Reconnected) {
          _socket!.send(jsonEncode(CommunicationProtocol(
              requestType: RequestType.handshake,
              data: {'token': token}).serialize()));
        } else if (event is Disconnected) {
          debugPrint('Disconnected from server');
          _handshakeReceived = false;
          setState(() {});
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
      _socket = null;
      debugPrint('Error: $e');
    }
    setState(() {});
  }

  Future<void> _incommingMessage(message) async {
    try {
      final map = jsonDecode(message);
      final protocol = CommunicationProtocol.deserialize(map);
      switch (protocol.requestType) {
        case RequestType.handshake:
          {
            _handshakeReceived = true;
            setState(() {});
            debugPrint('Handshake received');
            return;
          }
        case RequestType.response:
        case RequestType.update:
          {
            debugPrint('Message received: $message');
            if (protocol.requestType == RequestType.response &&
                protocol.data == null) {
              return;
            }
            switch (protocol.field) {
              case RequestFields.teachers:
              case RequestFields.teacher:
                if (protocol.data == null) throw Exception('No data received');
                _updateTeachers(protocol.data!);
                setState(() {});
                break;
              case null:
                throw Exception('Unsupported request field: ${protocol.field}');
            }
            return;
          }
        case RequestType.get:
        case RequestType.post:
        case RequestType.delete:
          throw Exception('Unsupported request type: ${protocol.requestType}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _getTeachers() async {
    if (!isConnected) return;

    // Send a get request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.get,
        field: RequestFields.teachers,
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _changeTeacher() async {
    if (!isConnected || _controller.text.isEmpty) return;

    // Send a post request to the server
    try {
      // TODO: This if we can get the error message
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.teacher,
        data: {'id': 1, 'age': int.parse(_controller.text)},
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _closeConnexion() async {
    if (!isConnected) return;

    // Close the WebSocket connection
    try {
      _socket?.close();
      _socket = null;
      _handshakeReceived = false;
      debugPrint('Connection closed');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
    setState(() {});
  }
}

String _getJwtToken() {
  // Create a fake JWT signed token to simulate a login.
  // TODO: At some point, this should be replaced with a real JWT token.
  return JWT({'app_secret': '1234567890'}).sign(SecretKey('secret passphrase'));
}
