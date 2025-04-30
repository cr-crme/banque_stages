import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:common/communication_protocol.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/internship_evaluation_attitude.dart';
import 'package:common/models/internships/internship_evaluation_skill.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/task_appreciation.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/itineraries/waypoint.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
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

final Map<String, Student> _dummyStudents = {};
Future<void> _updateStudents(Map<String, dynamic> data) async {
  if (data.containsKey('id')) {
    // Update a single student
    final id = data['id'];
    final studentData = data;
    _dummyStudents[id] = _dummyStudents.containsKey(id)
        ? _dummyStudents[id]!.copyWithData(studentData)
        : Student.fromSerialized(studentData);
  } else {
    // Update all students
    _dummyStudents.clear();
    for (final entry in data.entries) {
      final id = entry.key;
      final studentData = entry.value;
      _dummyStudents[id] = _dummyStudents.containsKey(id)
          ? _dummyStudents[id]!.copyWithData(studentData)
          : Student.fromSerialized(studentData);
    }
  }
}

final Map<String, Internship> _dummyInternships = {};
Future<void> _updateInternships(Map<String, dynamic> data) async {
  if (data.containsKey('id')) {
    // Update a single internship
    final id = data['id'];
    final internshipData = data;
    _dummyInternships[id] = _dummyInternships.containsKey(id)
        ? _dummyInternships[id]!.copyWithData(internshipData)
        : Internship.fromSerialized(internshipData);
  } else {
    // Update all internships
    _dummyInternships.clear();
    for (final entry in data.entries) {
      final id = entry.key;
      final internshipData = entry.value;
      _dummyInternships[id] = _dummyInternships.containsKey(id)
          ? _dummyInternships[id]!.copyWithData(internshipData)
          : Internship.fromSerialized(internshipData);
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
  final _teacherController = TextEditingController();
  final _studentController = TextEditingController();
  final _enterpriseController = TextEditingController();

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
                    onPressed: isConnected && _teacherController.text.isNotEmpty
                        ? _changeTeacher
                        : null,
                    child: Text('Change teacher')),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _teacherController,
                    enabled: isConnected,
                    decoration: InputDecoration(
                      labelText: 'New first name',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                )
              ],
            ),
            SizedBox(width: 20),
            ElevatedButton(
                onPressed: isConnected ? _addRandomItinerary : null,
                child: Text('Add random itinerary')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _addRandomStudent : null,
                child: Text('Add random student')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _getStudents : null,
                child: Text('Get students')),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: isConnected &&
                            _studentController.text.isNotEmpty &&
                            _dummyStudents.isNotEmpty
                        ? _changeStudent
                        : null,
                    child: Text('Change student')),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _studentController,
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
                onPressed: isConnected &&
                        _dummyStudents.isNotEmpty &&
                        _dummyEnterprises.isNotEmpty
                    ? _addRandomInternship
                    : null,
                child: Text('Add internship')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _getInternships : null,
                child: Text('Get internships')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected &&
                        _dummyInternships.isNotEmpty &&
                        _dummyStudents.length >= 2
                    ? _changeInternship
                    : null,
                child: Text('Change internship')),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _dummyTeachers.isNotEmpty && isConnected
                    ? _addRandomEnterprise
                    : null,
                child: Text('Add random Enterprise')),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: isConnected && _dummyEnterprises.isNotEmpty
                        ? _changeEnterprise
                        : null,
                    child: Text('Change name')),
                SizedBox(width: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _enterpriseController,
                    enabled: isConnected,
                    decoration: InputDecoration(
                      labelText: 'New name',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: isConnected ? _getEnterprises : null,
                child: Text('Get enterprises')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? _closeConnexion : null,
              child: Text('Disconnect'),
            ),
            ..._dummyTeachers.entries
                .map((entry) => TeacherTile(teacher: entry.value)),
            SizedBox(height: 20),
            ..._dummyStudents.entries
                .map((entry) => StudentTile(student: entry.value)),
            SizedBox(height: 20),
            ..._dummyInternships.entries
                .map((entry) => InternshipTile(internship: entry.value)),
            SizedBox(height: 20),
            ..._dummyEnterprises.entries
                .map((entry) => EnterpriseTile(enterprise: entry.value)),
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
      _socket?.close();
      _socket = null;
      _handshakeReceived = false;
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
          {
            if (protocol.data == null || protocol.field == null) return;

            switch (protocol.field!) {
              case RequestFields.schoolBoards:
              case RequestFields.schoolBoard:
                throw 'Not implemented request field: ${protocol.field}';
              case RequestFields.teachers:
              case RequestFields.teacher:
                _updateTeachers(protocol.data!);
                break;
              case RequestFields.students:
              case RequestFields.student:
                _updateStudents(protocol.data!);
                break;
              case RequestFields.enterprises:
              case RequestFields.enterprise:
                _updateEnterprises(protocol.data!);
                break;
              case RequestFields.internships:
              case RequestFields.internship:
                _updateInternships(protocol.data!);
                break;
            }
            setState(() {});
          }
        case RequestType.update:
          {
            debugPrint('Message received: $message');
            switch (protocol.field) {
              case RequestFields.schoolBoards:
              case RequestFields.schoolBoard:
                throw 'Not implemented request field: ${protocol.field}';
              case RequestFields.teachers:
              case RequestFields.teacher:
                _getTeachers(
                    id: protocol.data!['id'],
                    fields: (protocol.data!['updated_fields'] as List?)
                        ?.cast<String>());
                break;
              case RequestFields.students:
              case RequestFields.student:
                _getStudents(
                    id: protocol.data!['id'],
                    fields: (protocol.data!['updated_fields'] as List?)
                        ?.cast<String>());
                break;
              case RequestFields.enterprises:
              case RequestFields.enterprise:
                _getEnterprises(
                    id: protocol.data!['id'],
                    fields: (protocol.data!['updated_fields'] as List?)
                        ?.cast<String>());
                break;
              case RequestFields.internships:
              case RequestFields.internship:
                _getInternships(
                    id: protocol.data!['id'],
                    fields: (protocol.data!['updated_fields'] as List?)
                        ?.cast<String>());
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
          schoolBoardId: _random.nextInt(100).toString(),
          schoolId: _random.nextInt(100).toString(),
          groups: groups,
          email: teacher.email,
          phone: teacher.phone,
          address: Address.empty,
          dateBirth: null,
          itineraries: [],
        ).serialize(),
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _addRandomItinerary() async {
    if (!isConnected) return;

    final teacherId = _dummyTeachers.keys.firstOrNull;
    if (teacherId == null) {
      debugPrint('No teacher available');
      return;
    }
    final teacher = _dummyTeachers[teacherId]!;

    if (teacher.itineraries.isEmpty) {
      teacher.itineraries.add(Itinerary(
        id: 'itinerary-${_random.nextInt(100)}',
        date: DateTime.now(),
      ));
    }
    final itinerary = teacher.itineraries.first;
    itinerary.add(Waypoint(
      title: 'Waypoint ${itinerary.length + 1}',
      latitude: _random.nextDouble() * 90,
      longitude: _random.nextDouble() * 180,
      address: _randomAddress(),
      priority: VisitingPriority
          .values[_random.nextInt(VisitingPriority.values.length)],
    ));

    // Send a post request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
              requestType: RequestType.post,
              field: RequestFields.teacher,
              data: teacher.serialize())
          .serialize());
      _socket?.send(message);
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _addRandomStudent() async {
    if (!isConnected) return;

    // Send a post request to the server
    try {
      final groups = <String>[];
      for (int i = 0; i < _random.nextInt(5); i++) {
        groups.add(_random.nextInt(100).toString());
      }

      final student = _randomPerson();
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.student,
        data: Student(
          schoolBoardId: '${_random.nextInt(100) + 100}',
          schoolId: '${_random.nextInt(100) + 100}',
          firstName: student.firstName,
          middleName: null,
          lastName: student.lastName,
          email: student.email,
          phone: student.phone,
          address: student.address,
          dateBirth: student.dateBirth,
          group: '${_random.nextInt(100) + 100}',
          program: Program.values[_random.nextInt(Program.values.length)],
          contact: _randomPerson(),
          contactLink: ['Mother', 'Father', 'Guardian'][_random.nextInt(3)],
          photo: '${_random.nextInt(0xEFFFFF) + 0x1000000}',
        ).serialize(),
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _addRandomInternship() async {
    if (!isConnected) return;

    // Send a post request to the server
    try {
      final student = _dummyStudents[_dummyStudents.keys
          .toList()[_random.nextInt(_dummyStudents.length)]]!;

      final enterprise = _dummyEnterprises.values
          .toList()[_random.nextInt(_dummyEnterprises.length)];

      final internship = Internship(
          schoolBoardId: student.schoolBoardId,
          studentId: student.id,
          signatoryTeacherId: _dummyTeachers.keys
              .toList()[_random.nextInt(_dummyTeachers.length)],
          extraSupervisingTeacherIds: [
            _dummyTeachers.keys.toList()[_random.nextInt(_dummyTeachers.length)]
          ],
          enterpriseId: enterprise.id,
          jobId: enterprise.jobs
              .map((e) => e.id)
              .toList()[_random.nextInt(enterprise.jobs.length)],
          extraSpecializationIds: [
            enterprise.jobs
                .map((e) => e.id)
                .toList()[_random.nextInt(enterprise.jobs.length)],
            enterprise.jobs
                .map((e) => e.id)
                .toList()[_random.nextInt(enterprise.jobs.length)],
          ],
          creationDate: DateTime(2020, 1, 1),
          dates: time_utils.DateTimeRange(
              start: DateTime(2020, 1, 1), end: DateTime(2020, 1, 31)),
          supervisor: _dummyTeachers[_dummyTeachers.keys
              .toList()[_random.nextInt(_dummyTeachers.length)]]!,
          weeklySchedules: [
            WeeklySchedule(
                schedule: [
                  DailySchedule(
                      dayOfWeek: Day.monday,
                      start: time_utils.TimeOfDay(hour: 8, minute: 0),
                      end: time_utils.TimeOfDay(hour: 16, minute: 0)),
                  DailySchedule(
                      dayOfWeek: Day.wednesday,
                      start: time_utils.TimeOfDay(hour: 8, minute: 0),
                      end: time_utils.TimeOfDay(hour: 16, minute: 0)),
                  DailySchedule(
                      dayOfWeek: Day.friday,
                      start: time_utils.TimeOfDay(hour: 8, minute: 0),
                      end: time_utils.TimeOfDay(hour: 12, minute: 0)),
                ],
                period: time_utils.DateTimeRange(
                    start: DateTime(2020, 1, 1), end: DateTime(2020, 1, 31))),
          ],
          expectedDuration: 30,
          achievedDuration: -1,
          visitingPriority: VisitingPriority.high,
          endDate: null,
          teacherNotes: 'No notes');
      internship.addVersion(
          creationDate: DateTime(2020, 1, 15),
          dates: time_utils.DateTimeRange(
              start: DateTime(2020, 1, 2), end: DateTime(2020, 2, 1)),
          supervisor: internship.supervisor,
          weeklySchedules: [
            WeeklySchedule(
                schedule: [
                  DailySchedule(
                      dayOfWeek: Day.monday,
                      start: time_utils.TimeOfDay(hour: 8, minute: 0),
                      end: time_utils.TimeOfDay(hour: 16, minute: 0)),
                  DailySchedule(
                      dayOfWeek: Day.wednesday,
                      start: time_utils.TimeOfDay(hour: 8, minute: 0),
                      end: time_utils.TimeOfDay(hour: 16, minute: 0)),
                  DailySchedule(
                      dayOfWeek: Day.friday,
                      start: time_utils.TimeOfDay(hour: 8, minute: 0),
                      end: time_utils.TimeOfDay(hour: 12, minute: 0)),
                ],
                period: time_utils.DateTimeRange(
                    start: DateTime(2020, 1, 2), end: DateTime(2020, 2, 1))),
          ]);

      internship.skillEvaluations.add(InternshipEvaluationSkill(
          date: DateTime(2024, 2, 29),
          presentAtEvaluation: ['Me', 'Myself', 'I'],
          skillGranularity: SkillEvaluationGranularity.byTask,
          skills: [
            SkillEvaluation(
                specializationId: 'specializationId',
                skillName: 'Your skill',
                tasks: [
                  TaskAppreciation(
                      title: 'First task',
                      level: TaskAppreciationLevel.autonomous),
                  TaskAppreciation(
                      title: 'Second task',
                      level: TaskAppreciationLevel.notEvaluated),
                  TaskAppreciation(
                      title: 'Third task',
                      level: TaskAppreciationLevel.withConstantHelp),
                ],
                appreciation: SkillAppreciation.acquired,
                comments: 'Acquired but no good'),
            SkillEvaluation(
                specializationId: 'specializationId',
                skillName: 'Your skill again',
                tasks: [],
                appreciation: SkillAppreciation.failed,
                comments: 'Very not good'),
          ],
          comments: 'No comments',
          formVersion: InternshipEvaluationSkill.currentVersion));
      internship.skillEvaluations.add(InternshipEvaluationSkill(
          date: DateTime(2024, 3, 29),
          presentAtEvaluation: ['You', 'Yourself', 'Truly yours'],
          skillGranularity: SkillEvaluationGranularity.byTask,
          comments: 'Still no comments',
          skills: [],
          formVersion: InternshipEvaluationSkill.currentVersion));

      internship.attitudeEvaluations.add(InternshipEvaluationAttitude(
          date: DateTime(2024, 2, 29),
          presentAtEvaluation: ['Me', 'Myself', 'I'],
          attitude: AttitudeEvaluation(
              inattendance: Inattendance.frequently,
              ponctuality: Ponctuality.highly,
              sociability: Sociability.high,
              politeness: Politeness.inappropriate,
              motivation: Motivation.high,
              dressCode: DressCode.notEvaluated,
              qualityOfWork: QualityOfWork.negligent,
              productivity: Productivity.low,
              autonomy: Autonomy.none,
              cautiousness: Cautiousness.mostly,
              generalAppreciation: GeneralAppreciation.good),
          comments: 'Very good',
          formVersion: InternshipEvaluationAttitude.currentVersion));
      internship.attitudeEvaluations.add(InternshipEvaluationAttitude(
          date: DateTime(2024, 2, 29),
          presentAtEvaluation: ['Me', 'Myself', 'I'],
          attitude: AttitudeEvaluation(
              inattendance: Inattendance.never,
              ponctuality: Ponctuality.highly,
              sociability: Sociability.low,
              politeness: Politeness.inappropriate,
              motivation: Motivation.none,
              dressCode: DressCode.highlyAppropriate,
              qualityOfWork: QualityOfWork.high,
              productivity: Productivity.high,
              autonomy: Autonomy.high,
              cautiousness: Cautiousness.mostly,
              generalAppreciation: GeneralAppreciation.passable),
          comments: 'Very good',
          formVersion: InternshipEvaluationAttitude.currentVersion));
      internship.enterpriseEvaluation = PostInternshipEnterpriseEvaluation(
          skillsRequired: ['skill1', 'skill2', 'skill3'],
          internshipId: 'internshipId',
          taskVariety: 2.1,
          trainingPlanRespect: 3.1,
          autonomyExpected: 1.0,
          efficiencyExpected: 1.3,
          supervisionStyle: 3.9,
          easeOfCommunication: 3.4,
          absenceAcceptance: 2.0,
          supervisionComments: 'Could be better...',
          acceptanceTsa: 0.1,
          acceptanceLanguageDisorder: 2.1,
          acceptanceIntellectualDisability: 2.4,
          acceptancePhysicalDisability: 2.8,
          acceptanceMentalHealthDisorder: 3.5,
          acceptanceBehaviorDifficulties: 3.1);

      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.internship,
        data: internship.serialize(),
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
            preInternshipRequests: PreInternshipRequests(
              requests: [
                PreInternshipRequestTypes.values[
                    random.nextInt(PreInternshipRequestTypes.values.length)]
              ],
              other: null,
              isApplicable: true,
            ),
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
          schoolBoardId: 'schoolBoardId',
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

  Future<void> _getTeachers({String? id, List<String>? fields}) async {
    if (!isConnected) return;

    // Send a get request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.get,
        field: id == null ? RequestFields.teachers : RequestFields.teacher,
        data: id == null ? null : {'id': id, 'fields': fields},
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _getStudents({String? id, List<String>? fields}) async {
    if (!isConnected) return;

    // Send a get request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.get,
        field: id == null ? RequestFields.students : RequestFields.student,
        data: id == null ? null : {'id': id, 'fields': fields},
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _getEnterprises({String? id, List<String>? fields}) async {
    if (!isConnected) return;

    // Send a get request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.get,
        field:
            id == null ? RequestFields.enterprises : RequestFields.enterprise,
        data: id == null ? null : {'id': id, 'fields': fields},
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _getInternships({String? id, List<String>? fields}) async {
    if (!isConnected) return;

    // Send a get request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.get,
        field:
            id == null ? RequestFields.internships : RequestFields.internship,
        data: id == null ? null : {'id': id, 'fields': fields},
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _changeTeacher() async {
    if (!isConnected || _teacherController.text.isEmpty) return;

    // Send a post request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.teacher,
        data: {
          'id': _dummyTeachers.keys.first,
          'first_name': _teacherController.text
        },
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _changeStudent() async {
    if (!isConnected || _studentController.text.isEmpty) return;

    // Send a post request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.student,
        data: {
          'id': _dummyStudents.keys.first,
          'first_name': _studentController.text
        },
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _changeEnterprise() async {
    if (!isConnected || _enterpriseController.text.isEmpty) return;

    // Send a post request to the server
    try {
      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.enterprise,
        data: {
          'id': _dummyEnterprises.keys.first,
          'name': _enterpriseController.text,
          'version': Enterprise.currentVersion,
        },
      ).serialize());
      _socket?.send(message);
      debugPrint('Message sent: $message');
    } catch (e) {
      debugPrint('Error: $e');
      return;
    }
  }

  Future<void> _changeInternship() async {
    if (!isConnected) return;

    // Send a post request to the server
    try {
      final internship = _dummyInternships[_dummyInternships.keys.toList()[0]]!
          .copyWith(
              studentId: _dummyStudents.keys
                  .toList()[_random.nextInt(_dummyStudents.length)]);

      final message = jsonEncode(CommunicationProtocol(
        requestType: RequestType.post,
        field: RequestFields.internship,
        data: {
          'id': internship.id,
          'student_id': internship.studentId,
          'version': Internship.currentVersion
        },
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
    return Text('$teacher, ${teacher.groups.join(', ')}\n'
        'Itineraries: ${teacher.itineraries}\n'
        'Phone: ${teacher.phone}, email: ${teacher.email}, address: ${teacher.address}\n'
        'groups: ${teacher.groups.join(', ')}\n\n');
  }
}

class StudentTile extends StatelessWidget {
  const StudentTile({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Text(student.toString());
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

class InternshipTile extends StatelessWidget {
  const InternshipTile({
    super.key,
    required this.internship,
  });

  final Internship internship;

  @override
  Widget build(BuildContext context) {
    return Text(internship.toString());
  }
}

String _getJwtToken() {
  // Create a fake JWT signed token to simulate a login.
  // TODO: At some point, this should be replaced with a real JWT token.
  return JWT({'app_secret': '1234567890'}).sign(SecretKey('secret passphrase'));
}
