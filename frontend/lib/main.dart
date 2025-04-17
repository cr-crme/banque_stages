import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:common/communication_protocol.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_client/web_socket_client.dart';

final Map<String, Teacher> _dummyTeachers = {};
Future<void> _updateTeachers(Map<String, dynamic> data) async {
  if (data.containsKey('id')) {
    // Update a single teacher
    final id = data['id'];
    final teacherData = data;
    _dummyTeachers[id] = _dummyTeachers.containsKey(id)
        ? _dummyTeachers[id]!.copyWithData(teacherData)
        : Teacher.fromSerialized(teacherData);
  } else {
    // Update all teachers
    _dummyTeachers.clear();
    for (final entry in data.entries) {
      final id = entry.key;
      final teacherData = entry.value;
      _dummyTeachers[id] = _dummyTeachers.containsKey(id)
          ? _dummyTeachers[id]!.copyWithData(teacherData)
          : Teacher.fromSerialized(teacherData);
    }
  }
}

final Map<String, Enterprise> _dummyEnterprises = {};
Future<void> _updateEnterprises(Map<String, dynamic> data) async {
  if (data.containsKey('id')) {
    // Update a single enterprise
    final id = data['id'];
    final enterpriseData = data;
    _dummyEnterprises[id] = _dummyEnterprises.containsKey(id)
        ? _dummyEnterprises[id]!.copyWithData(enterpriseData)
        : Enterprise.fromSerialized(enterpriseData);
  } else {
    // Update all enterprises
    _dummyEnterprises.clear();
    for (final entry in data.entries) {
      final id = entry.key;
      final enterpriseData = entry.value;
      _dummyEnterprises[id] = _dummyEnterprises.containsKey(id)
          ? _dummyEnterprises[id]!.copyWithData(enterpriseData)
          : Enterprise.fromSerialized(enterpriseData);
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
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: isConnecting || isConnected ? null : _connect,
                child: Text(isConnecting ? 'Connecting...' : 'Connect')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _addRandomTeacher : null,
                child: Text('Add random teacher')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _getTeachers : null,
                child: Text('Get teachers')),
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
                      labelText: 'New first name',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _dummyTeachers.isNotEmpty && isConnected
                    ? _addRandomEnterprise
                    : null,
                child: Text('Add random Enterprise')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _getEnterprises : null,
                child: Text('Get enterprises')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? _closeConnexion : null,
              child: Text('Disconnect'),
            ),
            ..._dummyTeachers.entries.map((entry) {
              final teacher = entry.value;
              return TeacherTile(teacher: teacher);
            }),
            SizedBox(height: 20),
            ..._dummyEnterprises.entries.map((entry) {
              final enterprise = entry.value;
              return EnterpriseTile(enterprise: enterprise);
            }),
          ],
        ),
      )),
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
              case RequestFields.enterprises:
              case RequestFields.enterprise:
                if (protocol.data == null) throw Exception('No data received');
                _updateEnterprises(protocol.data!);
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

  final _random = Random();

  Person _randomPerson() {
    final firstName =
        ['John', 'Jane', 'Alice', 'Bob', 'Charlie'][_random.nextInt(5)];
    final lastName =
        ['Doe', 'Smith', 'Johnson', 'Williams', 'Brown'][_random.nextInt(5)];

    return Person(
        firstName: firstName,
        middleName: null,
        lastName: lastName,
        dateBirth: DateTime(_random.nextInt(50) + 1970, _random.nextInt(12) + 1,
            _random.nextInt(28) + 1),
        email:
            '${firstName.toLowerCase()}.${lastName.toLowerCase()}@banque_stage.org',
        phone: _randomPhoneNumber(),
        address: _randomAddress());
  }

  PhoneNumber _randomPhoneNumber() => PhoneNumber.fromString(
      '${_random.nextInt(900) + 100}-${_random.nextInt(900) + 100}-${_random.nextInt(9000) + 1000}');

  Address _randomAddress() => Address(
        civicNumber: _random.nextInt(100),
        street: ['Street', 'Boulevard', 'Avenue'][_random.nextInt(3)],
        city: ['Montreal', 'Quebec', 'Laval'][_random.nextInt(3)],
        postalCode: 'H0H 0H0',
      );

  String _randomWebsite() {
    final name = [
      ['The', 'A', 'Your', 'Our'][Random().nextInt(4)],
      ['Company', 'Business', 'Enterprise', 'Corporation'][Random().nextInt(4)],
    ].join('');
    final domain = [
      'example.com',
      'example.org',
      'example.net',
      'example.edu',
    ][Random().nextInt(4)];
    return 'https://$name.$domain';
  }

  Future<void> _addRandomTeacher() async {
    if (!isConnected) return;

    // Send a post request to the server
    try {
      final groups = <String>[];
      for (int i = 0; i < _random.nextInt(5); i++) {
        groups.add(_random.nextInt(100).toString());
      }

      final teacher = _randomPerson();
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.teacher,
        data: Teacher(
          firstName: teacher.firstName,
          middleName: null,
          lastName: teacher.lastName,
          schoolId: _random.nextInt(100).toString(),
          groups: groups,
          email: teacher.email,
          phone: teacher.phone,
          address: Address.empty,
          dateBirth: null,
        ).serialize(),
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _addRandomEnterprise() async {
    if (!isConnected) return;

    // Send a post request to the server
    try {
      final random = Random();
      final name = [
        ['The ', 'A ', 'Your ', 'Our '][random.nextInt(4)],
        ['Company', 'Business', 'Enterprise', 'Corporation'][random.nextInt(4)],
        ['Inc.', 'LLC', 'Ltd.', 'Co.'][random.nextInt(4)]
      ].join(' ');
      final activities = {
        for (int i = 0; i < _random.nextInt(5); i++)
          ActivityTypes.values[random.nextInt(ActivityTypes.values.length)]
      };
      final jobs = JobList();
      for (int i = 0; i < _random.nextInt(5) + 1; i++) {
        jobs.add(Job(
            specialization: ActivitySectorsService.specialization('8192'),
            positionsOffered: _random.nextInt(10),
            minimumAge: random.nextInt(5) + 13,
            photosUrl: ['https://example.com/photo${_random.nextInt(100)}.jpg'],
            preInternshipRequests: [
              PreInternshipRequest
                  .values[random.nextInt(PreInternshipRequest.values.length)]
            ],
            comments: [
              'Comment ${_random.nextInt(100)}',
              'Comment ${_random.nextInt(100)}'
            ],
            uniforms: Uniforms(
                status: UniformStatus
                    .values[random.nextInt(UniformStatus.values.length)],
                uniforms: [
                  ['Shirt', 'Pants', 'Shoes'][random.nextInt(3)],
                  ['Hat', 'Gloves'][random.nextInt(2)]
                ]),
            protections: Protections(
                status: ProtectionsStatus
                    .values[random.nextInt(ProtectionsStatus.values.length)],
                protections: [
                  ProtectionsType
                      .values[random.nextInt(ProtectionsType.values.length)]
                      .toString(),
                  ProtectionsType
                      .values[random.nextInt(ProtectionsType.values.length)]
                      .toString()
                ]),
            incidents: Incidents(severeInjuries: [
              Incident('Knee capped', date: DateTime.now()),
              Incident('Burnt', date: DateTime.now())
            ], minorInjuries: [
              Incident('Scratched', date: DateTime.now()),
              Incident('Fell', date: DateTime.now())
            ]),
            sstEvaluation: JobSstEvaluation(questions: {
              'Q1': ['Oui'],
              'Q1+t': ['Peu souvent, à la discrétion des employés.'],
              'Q3': ['Un diable'],
              'Q5': ['Des ciseaux'],
              'Q9': ['Des solvants', 'Des produits de nettoyage'],
              'Q12': ['Bruyant'],
              'Q12+t': ['Bouchons a oreilles'],
              'Q15': ['Oui'],
              'Q18': ['Non'],
            })));
      }

      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.enterprise,
        data: Enterprise(
          name: name,
          activityTypes: activities,
          jobs: jobs,
          recruiterId: _dummyTeachers.keys
              .toList()[random.nextInt(_dummyTeachers.length)],
          contact: _randomPerson(),
          contactFunction: 'Looking',
          address: _randomAddress(),
          phone: _randomPhoneNumber(),
          fax: _randomPhoneNumber(),
          website: _randomWebsite(),
          headquartersAddress: _randomAddress(),
          neq: (_random.nextInt(1000000) + 1000000).toString(),
        ).serialize(),
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
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

  Future<void> _getEnterprises() async {
    if (!isConnected) return;

    // Send a get request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.get,
        field: RequestFields.enterprises,
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
        data: {'id': _dummyTeachers.keys.first, 'first_name': _controller.text},
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

class TeacherTile extends StatelessWidget {
  const TeacherTile({
    super.key,
    required this.teacher,
  });

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return Text('${teacher.toString()} '
        '(${teacher.phone}) '
        '[${teacher.groups.join(', ')}]');
  }
}

class EnterpriseTile extends StatelessWidget {
  const EnterpriseTile({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  Widget build(BuildContext context) {
    return Text(
        '${enterprise.name}, ${enterprise.address} [${enterprise.headquartersAddress}].\n'
        'Activities: ${enterprise.activityTypes.join(', ')},\n'
        'First job: ${enterprise.jobs.first}\n'
        'Contact: ${enterprise.contact}, phone: ${enterprise.phone}, recruted by ${_dummyTeachers[enterprise.recruiterId]}\n'
        'Website: ${enterprise.website}, fax: ${enterprise.fax}, neq: ${enterprise.neq}\n\n');
  }
}

String _getJwtToken() {
  // Create a fake JWT signed token to simulate a login.
  // TODO: At some point, this should be replaced with a real JWT token.
  return JWT({'app_secret': '1234567890'}).sign(SecretKey('secret passphrase'));
}
