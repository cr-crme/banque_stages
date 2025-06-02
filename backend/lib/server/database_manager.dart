import 'package:backend/repositories/admins_repository.dart';
import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/internships_repository.dart';
import 'package:backend/repositories/school_boards_repository.dart';
import 'package:backend/repositories/students_repository.dart';
import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/utils/database_user.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/communication_protocol.dart';
import 'package:mysql1/mysql1.dart';

String _getId(Map<String, dynamic>? data, {required String messageOnNull}) {
  final id = data?['id']?.toString();
  if (id == null || id.isEmpty) throw MissingFieldException(messageOnNull);
  return id;
}

class DatabaseManager {
  DatabaseManager({
    required MySqlConnection? connection,
    required this.schoolBoardsDatabase,
    required this.adminsDatabase,
    required this.teachersDatabase,
    required this.studentsDatabase,
    required this.enterprisesDatabase,
    required this.internshipsDatabase,
  }) : _connection = connection;

  final MySqlConnection? _connection;
  MySqlConnection get connection => _connection!;
  final SchoolBoardsRepository schoolBoardsDatabase;
  final AdminsRepository adminsDatabase;
  final TeachersRepository teachersDatabase;
  final StudentsRepository studentsDatabase;
  final EnterprisesRepository enterprisesDatabase;
  final InternshipsRepository internshipsDatabase;

  Future<Map<String, dynamic>> get(
    RequestFields field, {
    required Map<String, dynamic>? data,
    required DatabaseUser user,
  }) async {
    switch (field) {
      case RequestFields.schoolBoards:
        return await schoolBoardsDatabase.getAll(
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
      case RequestFields.schoolBoard:
        return await schoolBoardsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get a school board'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
      case RequestFields.admins:
        return await adminsDatabase.getAll(user: user);
      case RequestFields.admin:
        return await adminsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get an admin'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
      case RequestFields.teachers:
        return await teachersDatabase.getAll(
          user: user,
        );
      case RequestFields.teacher:
        return await teachersDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get a teacher'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
      case RequestFields.students:
        return await studentsDatabase.getAll(
          user: user,
        );
      case RequestFields.student:
        return await studentsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get a student'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
      case RequestFields.enterprises:
        return await enterprisesDatabase.getAll(
          user: user,
        );
      case RequestFields.enterprise:
        return await enterprisesDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get an enterprise'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
      case RequestFields.internships:
        return await internshipsDatabase.getAll(
          user: user,
        );
      case RequestFields.internship:
        return await internshipsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get an internship'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          user: user,
        );
    }
  }

  Future<List<String>?> put(
    RequestFields field, {
    required Map<String, dynamic>? data,
    required DatabaseUser user,
  }) async {
    if (data == null) {
      throw MissingDataException('Data is required to put something');
    }

    switch (field) {
      case RequestFields.schoolBoards:
        await schoolBoardsDatabase.putAll(
          data: data,
          user: user,
        );
        return null;
      case RequestFields.schoolBoard:
        return await schoolBoardsDatabase.putById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to put a school board'),
          data: data,
          user: user,
        );
      case RequestFields.admins:
        await adminsDatabase.putAll(
          data: data,
          user: user,
        );
        return null;
      case RequestFields.admin:
        return await adminsDatabase.putById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to put an admin'),
          data: data,
          user: user,
        );
      case RequestFields.teachers:
        await teachersDatabase.putAll(
          data: data,
          user: user,
        );
        return null;
      case RequestFields.teacher:
        return await teachersDatabase.putById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to put a teacher'),
          data: data,
          user: user,
        );
      case RequestFields.students:
        await studentsDatabase.putAll(
          data: data,
          user: user,
        );
        return null;
      case RequestFields.student:
        return await studentsDatabase.putById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to put a student'),
          data: data,
          user: user,
        );
      case RequestFields.enterprises:
        await enterprisesDatabase.putAll(
          data: data,
          user: user,
        );
        return null;
      case RequestFields.enterprise:
        return await enterprisesDatabase.putById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to put an enterprise'),
          data: data,
          user: user,
          internshipsRepository: internshipsDatabase,
        );
      case RequestFields.internships:
        await internshipsDatabase.putAll(
          data: data,
          user: user,
        );
        return null;
      case RequestFields.internship:
        return await internshipsDatabase.putById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to put an internship'),
          data: data,
          user: user,
        );
    }
  }

  Future<List<String>> delete(
    RequestFields field, {
    required Map<String, dynamic>? data,
    required DatabaseUser user,
  }) async {
    switch (field) {
      case RequestFields.schoolBoards:
        return await schoolBoardsDatabase.deleteAll(
          user: user,
        );
      case RequestFields.schoolBoard:
        return [
          await schoolBoardsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete a school board'),
            user: user,
          )
        ];
      case RequestFields.admins:
        return await adminsDatabase.deleteAll(
          user: user,
        );
      case RequestFields.admin:
        return [
          await adminsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete an admin'),
            user: user,
          )
        ];
      case RequestFields.teachers:
        return await teachersDatabase.deleteAll(
          user: user,
        );
      case RequestFields.teacher:
        return [
          await teachersDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete a teacher'),
            user: user,
          )
        ];
      case RequestFields.students:
        return await studentsDatabase.deleteAll(
          user: user,
        );
      case RequestFields.student:
        return [
          await studentsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete a student'),
            user: user,
          )
        ];
      case RequestFields.enterprises:
        return await enterprisesDatabase.deleteAll(
          user: user,
        );
      case RequestFields.enterprise:
        return [
          // TODO: The frontend don't know they should update their internships
          await enterprisesDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete an enterprise'),
            user: user,
            internshipsRepository: internshipsDatabase,
          )
        ];
      case RequestFields.internships:
        return await internshipsDatabase.deleteAll(
          user: user,
        );
      case RequestFields.internship:
        return [
          await internshipsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete an internship'),
            user: user,
          )
        ];
    }
  }
}
