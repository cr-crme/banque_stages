import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/exceptions.dart';
import 'package:test/test.dart';

TeachersRepository get _mockedDatabaseTeachers => DatabaseTeachersMock();

void main() {
  test('Get teachers from DatabaseTeachers', () async {
    final teachers = await _mockedDatabaseTeachers.getAll();
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['firstName'], 'John');
    expect(teachers['0']['lastName'], 'Doe');
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['firstName'], 'Jane');
    expect(teachers['1']['lastName'], 'Doe');
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
    expect(teacher['firstName'], 'John');
    expect(teacher['lastName'], 'Doe');
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
      data: {'firstName': 'John', 'lastName': 'Smith'},
    );
    final updatedTeacher = await mockedDatabase.getById(id: '0');
    expect(updatedTeacher['firstName'], 'John');
    expect(updatedTeacher['lastName'], 'Smith');
  });

  test('Set new teacher to DatabaseTeachers', () async {
    final mockedDatabase = _mockedDatabaseTeachers;
    await mockedDatabase.putById(
      id: '2',
      data: {'firstName': 'Agent', 'lastName': 'Smith'},
    );
    final newTeacher = await mockedDatabase.getById(id: '2');
    expect(newTeacher['firstName'], 'Agent');
    expect(newTeacher['lastName'], 'Smith');
  });
}
