import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/exceptions.dart';
import 'package:test/test.dart';

TeachersRepository get _mockedDatabaseTeachers => TeachersRepositoryMock();

void main() {
  test('Get teachers from DatabaseTeachers', () async {
    final teachers = await _mockedDatabaseTeachers.getAll();
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['first_name'], 'John');
    expect(teachers['0']['last_name'], 'Doe');
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['first_name'], 'Jane');
    expect(teachers['1']['last_name'], 'Doe');
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
    expect(teacher['first_name'], 'John');
    expect(teacher['last_name'], 'Doe');
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
      data: {'first_name': 'John', 'last_name': 'Smith'},
    );
    final updatedTeacher = await mockedDatabase.getById(id: '0');
    expect(updatedTeacher['first_name'], 'John');
    expect(updatedTeacher['last_name'], 'Smith');
  });

  test('Set new teacher to DatabaseTeachers', () async {
    final mockedDatabase = _mockedDatabaseTeachers;
    await mockedDatabase.putById(
      id: '2',
      data: {'first_name': 'Agent', 'last_name': 'Smith'},
    );
    final newTeacher = await mockedDatabase.getById(id: '2');
    expect(newTeacher['first_name'], 'Agent');
    expect(newTeacher['last_name'], 'Smith');
  });
}
