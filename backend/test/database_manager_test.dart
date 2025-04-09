import 'package:backend/database_manager.dart';
import 'package:backend/database_teachers.dart';
import 'package:backend/exceptions.dart';
import 'package:common/communication_protocol.dart';
import 'package:test/test.dart';

DatabaseTeachers get _mockedDatabaseTeachers => DatabaseTeachersMock();

void main() {
  test('Get teachers from DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    final teachers = await database.get(RequestFields.teachers, data: null);
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['firstName'], 'John');
    expect(teachers['0']['lastName'], 'Doe');
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['firstName'], 'Jane');
    expect(teachers['1']['lastName'], 'Doe');
  });

  test('Get teacher from DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    final teacher =
        await database.get(RequestFields.teacher, data: {'id': '0'});
    expect(teacher, isA<Map<String, dynamic>>());
    expect(teacher['firstName'], 'John');
    expect(teacher['lastName'], 'Doe');
  });

  test('Get teacher from DatabaseManagers with invalid id', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    expect(
      () async => await database.get(RequestFields.teacher, data: {'id': '2'}),
      throwsA(predicate((e) =>
          e is MissingDataException && e.toString() == 'Teacher not found')),
    );
  });

  test('Get teacher from DatabaseManagers without id', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    expect(
      () async => await database.get(RequestFields.teacher, data: null),
      throwsA(predicate((e) =>
          e is MissingFieldException &&
          e.toString() == 'An "id" is required to get a teacher')),
    );
  });

  test('Put without data in DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    expect(
      () async => await database.put(RequestFields.teachers, data: null),
      throwsA(predicate((e) =>
          e is MissingDataException &&
          e.toString() == 'Data is required to put something')),
    );
  });

  test('Set all teachers to DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    expect(
      () async =>
          await database.put(RequestFields.teachers, data: {'0': 'John Doe'}),
      throwsA(predicate((e) =>
          e is InvalidRequestException &&
          e.toString() == 'Teachers must be created individually')),
    );
  });

  test('Set teacher to DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    await database.put(RequestFields.teacher,
        data: {'id': '0', 'firstName': 'John', 'lastName': 'Smith'});
    final updatedTeacher =
        await database.get(RequestFields.teacher, data: {'id': '0'});
    expect(updatedTeacher['firstName'], 'John');
    expect(updatedTeacher['lastName'], 'Smith');
  });

  test('Set new teacher to DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    await database.put(RequestFields.teacher,
        data: {'id': '2', 'firstName': 'Agent', 'lastName': 'Smith'});
    final newTeacher =
        await database.get(RequestFields.teacher, data: {'id': '2'});
    expect(newTeacher['firstName'], 'Agent');
    expect(newTeacher['lastName'], 'Smith');
  });

  test('Set teacher to DatabaseManagers without id', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    expect(
      () async => await database.put(RequestFields.teacher, data: {
        'name': 'John Smith',
        'age': 45,
      }),
      throwsA(predicate((e) =>
          e is MissingFieldException &&
          e.toString() == 'An "id" is required to put a teacher')),
    );
  });
}
