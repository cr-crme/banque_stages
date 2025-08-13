import 'package:stagess_backend/repositories/teachers_repository.dart';
import 'package:stagess_backend/utils/database_user.dart';
import 'package:stagess_backend/utils/exceptions.dart';
import 'package:stagess_common/exceptions.dart';
import 'package:test/test.dart';

TeachersRepository get _mockedDatabaseTeachers => TeachersRepositoryMock();

void main() {
  test('Get teachers from DatabaseTeachers', () async {
    final teachers = await _mockedDatabaseTeachers.getAll(
      user: DatabaseUser.empty(),
    );
    expect(teachers.data, isA<Map<String, dynamic>>());
    expect(teachers.data!.length, 2);
    expect(teachers.data!['0'], isA<Map<String, dynamic>>());
    expect(teachers.data!['0']['first_name'], 'John');
    expect(teachers.data!['0']['last_name'], 'Doe');
    expect(teachers.data!['1'], isA<Map<String, dynamic>>());
    expect(teachers.data!['1']['first_name'], 'Jane');
    expect(teachers.data!['1']['last_name'], 'Doe');

    expect(teachers.updatedData, isNull);
    expect(teachers.deletedData, isNull);
  });

  test('Get teacher from DatabaseTeachers', () async {
    final teacher = await _mockedDatabaseTeachers.getById(
      id: '0',
      user: DatabaseUser.empty(),
    );
    expect(teacher.data, isA<Map<String, dynamic>>());
    expect(teacher.data!['first_name'], 'John');
    expect(teacher.data!['last_name'], 'Doe');

    expect(teacher.updatedData, isNull);
    expect(teacher.deletedData, isNull);
  });

  test('Get teacher from DatabaseTeachers with invalid id', () async {
    expect(
      () async => await _mockedDatabaseTeachers.getById(
        id: '2',
        user: DatabaseUser.empty(),
      ),
      throwsA(predicate((e) =>
          e is MissingDataException && e.toString() == 'Teacher not found')),
    );
  });

  test('Set teacher to DatabaseTeachers with invalid data field', () async {
    expect(
      () async => await _mockedDatabaseTeachers.putById(
        id: '0',
        data: {'name': 'John Doe', 'age': 60, 'invalid_field': 'invalid'},
        user: DatabaseUser.empty(),
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
      user: DatabaseUser.empty(),
    );
    final updatedTeacher = await mockedDatabase.getById(
      id: '0',
      user: DatabaseUser.empty(),
    );
    expect(updatedTeacher.data!['first_name'], 'John');
    expect(updatedTeacher.data!['last_name'], 'Smith');
  });

  test('Set new teacher to DatabaseTeachers', () async {
    final mockedDatabase = _mockedDatabaseTeachers;
    await mockedDatabase.putById(
      id: '2',
      data: {'first_name': 'Agent', 'last_name': 'Smith'},
      user: DatabaseUser.empty(),
    );
    final newTeacher = await mockedDatabase.getById(
      id: '2',
      user: DatabaseUser.empty(),
    );
    expect(newTeacher.data!['first_name'], 'Agent');
    expect(newTeacher.data!['last_name'], 'Smith');
  });
}
