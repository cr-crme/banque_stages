import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/internships_repository.dart';
import 'package:backend/repositories/school_boards_repository.dart';
import 'package:backend/repositories/students_repository.dart';
import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/server/database_manager.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/utils.dart';
import 'package:test/test.dart';

SchoolBoardsRepository get _mockedDatabaseSchoolBoards =>
    SchoolBoardsRepositoryMock();
TeachersRepository get _mockedDatabaseTeachers => TeachersRepositoryMock();
StudentsRepository get _mockedDatabaseStudents => StudentsRepositoryMock();
EnterprisesRepository get _mockedDatabaseEnterprises =>
    EnterprisesRepositoryMock();
InternshipsRepository get _mockedDatabaseInternships =>
    InternshipsRepositoryMock();

void main() {
  test('Get teachers from DatabaseManagers', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    final teachers = await database.get(
      RequestFields.teachers,
      data: null,
      schoolBoardId: DevAuth.devMySchoolBoardId,
    );
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['first_name'], 'John');
    expect(teachers['0']['last_name'], 'Doe');
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['first_name'], 'Jane');
    expect(teachers['1']['last_name'], 'Doe');
  });

  test('Get teacher from DatabaseManagers', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    final teacher = await database.get(
      RequestFields.teacher,
      data: {'id': '0'},
      schoolBoardId: DevAuth.devMySchoolBoardId,
    );
    expect(teacher, isA<Map<String, dynamic>>());
    expect(teacher['first_name'], 'John');
    expect(teacher['last_name'], 'Doe');
  });

  test('Get teacher from DatabaseManagers with invalid id', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    expect(
      () async => await database.get(
        RequestFields.teacher,
        data: {'id': '2'},
        schoolBoardId: DevAuth.devMySchoolBoardId,
      ),
      throwsA(predicate((e) =>
          e is MissingDataException && e.toString() == 'Teacher not found')),
    );
  });

  test('Get teacher from DatabaseManagers without id', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    expect(
      () async => await database.get(
        RequestFields.teacher,
        data: null,
        schoolBoardId: DevAuth.devMySchoolBoardId,
      ),
      throwsA(predicate((e) =>
          e is MissingFieldException &&
          e.toString() == 'An "id" is required to get a teacher')),
    );
  });

  test('Put without data in DatabaseManagers', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    expect(
      () async => await database.put(
        RequestFields.teachers,
        data: null,
        schoolBoardId: DevAuth.devMySchoolBoardId,
      ),
      throwsA(predicate((e) =>
          e is MissingDataException &&
          e.toString() == 'Data is required to put something')),
    );
  });

  test('Set all teachers to DatabaseManagers', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    expect(
      () async => await database.put(
        RequestFields.teachers,
        data: {'0': 'John Doe'},
        schoolBoardId: DevAuth.devMySchoolBoardId,
      ),
      throwsA(predicate((e) =>
          e is InvalidRequestException &&
          e.toString() == 'Teachers must be created individually')),
    );
  });

  test('Set teacher to DatabaseManagers', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    await database.put(
      RequestFields.teacher,
      data: {'id': '0', 'first_name': 'John', 'last_name': 'Smith'},
      schoolBoardId: DevAuth.devMySchoolBoardId,
    );
    final updatedTeacher = await database.get(
      RequestFields.teacher,
      data: {'id': '0'},
      schoolBoardId: DevAuth.devMySchoolBoardId,
    );
    expect(updatedTeacher['first_name'], 'John');
    expect(updatedTeacher['last_name'], 'Smith');
  });

  test('Set new teacher to DatabaseManagers', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    await database.put(
      RequestFields.teacher,
      data: {'id': '2', 'first_name': 'Agent', 'last_name': 'Smith'},
      schoolBoardId: DevAuth.devMySchoolBoardId,
    );
    final newTeacher = await database.get(
      RequestFields.teacher,
      data: {'id': '2'},
      schoolBoardId: DevAuth.devMySchoolBoardId,
    );
    expect(newTeacher['first_name'], 'Agent');
    expect(newTeacher['last_name'], 'Smith');
  });

  test('Set teacher to DatabaseManagers without id', () async {
    final database = DatabaseManager(
      connection: null,
      schoolBoardsDatabase: _mockedDatabaseSchoolBoards,
      teachersDatabase: _mockedDatabaseTeachers,
      studentsDatabase: _mockedDatabaseStudents,
      enterprisesDatabase: _mockedDatabaseEnterprises,
      internshipsDatabase: _mockedDatabaseInternships,
    );
    expect(
      () async => await database.put(
        RequestFields.teacher,
        data: {'name': 'John Smith', 'age': 45},
        schoolBoardId: DevAuth.devMySchoolBoardId,
      ),
      throwsA(predicate((e) =>
          e is MissingFieldException &&
          e.toString() == 'An "id" is required to put a teacher')),
    );
  });
}
