import 'package:backend/database_teachers.dart';
import 'package:backend/exceptions.dart';
import 'package:common/exceptions.dart';
import 'package:test/test.dart';

DatabaseTeachers get _mockedDatabaseTeachers => DatabaseTeachersMock();

void main() {
  test('Get teachers from DatabaseTeachers', () async {
    final teachers = await _mockedDatabaseTeachers.getAll();
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['name'], 'John Doe');
    expect(teachers['0']['age'], 60);
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['name'], 'Jane Doe');
    expect(teachers['1']['age'], 50);
  });

  test('Set all teachers to DatabaseTeachers', () async {
    expect(
      () async => await _mockedDatabaseTeachers.putAll(data: {'1': 'John Doe'}),
      throwsA(predicate((e) =>
          e is InvalidRequestException &&
          e.toString() == 'Teachers must be created individually')),
    );
  });

  test('Get teacher from DatabaseTeachers', () async {
    final teacher = await _mockedDatabaseTeachers.getById(id: '0');
    expect(teacher, isA<Map<String, dynamic>>());
    expect(teacher['name'], 'John Doe');
    expect(teacher['age'], 60);
  });

  test('Get teacher from DatabaseTeachers with invalid id', () async {
    expect(
      () async => await _mockedDatabaseTeachers.getById(id: '2'),
      throwsA(predicate((e) =>
          e is MissingDataException && e.toString() == 'Teacher not found')),
    );
  });

  test('Set teacher to DatabaseTeachers with invalid data field', () async {
    expect(
      () async => await _mockedDatabaseTeachers.putById(
        id: '0',
        data: {'name': 'John Doe', 'age': 60, 'invalid_field': 'invalid'},
      ),
      throwsA(predicate((e) =>
          e is InvalidFieldException &&
          e.toString() == 'Invalid field data detected')),
    );
  });

  test('Set teacher to DatabaseTeachers', () async {
    final mockedDatabase = _mockedDatabaseTeachers;
    await mockedDatabase.putById(
      id: '0',
      data: {'name': 'John Smith', 'age': 45},
    );
    final updatedTeacher = await mockedDatabase.getById(id: '0');
    expect(updatedTeacher['name'], 'John Smith');
    expect(updatedTeacher['age'], 45);
  });

  test('Set new teacher to DatabaseTeachers', () async {
    final mockedDatabase = _mockedDatabaseTeachers;
    await mockedDatabase.putById(
      id: '2',
      data: {'name': 'John Smith', 'age': 45},
    );
    final newTeacher = await mockedDatabase.getById(id: '2');
    expect(newTeacher['name'], 'John Smith');
    expect(newTeacher['age'], 45);
  });
}
