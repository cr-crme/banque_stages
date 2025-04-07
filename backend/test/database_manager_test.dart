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
    expect(teachers['0']['name'], 'John Doe');
    expect(teachers['0']['age'], 60);
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['name'], 'Jane Doe');
    expect(teachers['1']['age'], 50);
  });

  test('Get teacher from DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    final teacher =
        await database.get(RequestFields.teacher, data: {'id': '0'});
    expect(teacher, isA<Map<String, dynamic>>());
    expect(teacher['name'], 'John Doe');
    expect(teacher['age'], 60);
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
        data: {'id': '0', 'name': 'John Smith', 'age': 45});
    final updatedTeacher =
        await database.get(RequestFields.teacher, data: {'id': '0'});
    expect(updatedTeacher['name'], 'John Smith');
    expect(updatedTeacher['age'], 45);
  });

  test('Set new teacher to DatabaseManagers', () async {
    final database = DatabaseManager(teacherDatabase: _mockedDatabaseTeachers);
    await database.put(RequestFields.teacher,
        data: {'id': '2', 'name': 'John Smith', 'age': 45});
    final newTeacher =
        await database.get(RequestFields.teacher, data: {'id': '2'});
    expect(newTeacher['name'], 'John Smith');
    expect(newTeacher['age'], 45);
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
