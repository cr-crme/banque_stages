import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/internships_repository.dart';
import 'package:backend/repositories/school_boards_repository.dart';
import 'package:backend/repositories/students_repository.dart';
import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/communication_protocol.dart';

String _getId(Map<String, dynamic>? data, {required String messageOnNull}) {
  final id = data?['id']?.toString();
  if (id == null || id.isEmpty) throw MissingFieldException(messageOnNull);
  return id;
}

class DatabaseManager {
  DatabaseManager({
    required this.schoolBoardsDatabase,
    required this.teachersDatabase,
    required this.studentsDatabase,
    required this.enterprisesDatabase,
    required this.internshipsDatabase,
  });

  final SchoolBoardsRepository schoolBoardsDatabase;
  final TeachersRepository teachersDatabase;
  final StudentsRepository studentsDatabase;
  final EnterprisesRepository enterprisesDatabase;
  final InternshipsRepository internshipsDatabase;

  Future<Map<String, dynamic>> get(
    RequestFields field, {
    required Map<String, dynamic>? data,
    required String schoolBoardId,
  }) async {
    switch (field) {
      case RequestFields.schoolBoards:
        return await schoolBoardsDatabase.getAll(
          fields: (data?['fields'] as List?)?.cast<String>(),
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.schoolBoard:
        return await schoolBoardsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get a school board'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.teachers:
        return await teachersDatabase.getAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.teacher:
        return await teachersDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get a teacher'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.students:
        return await studentsDatabase.getAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.student:
        return await studentsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get a student'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.enterprises:
        return await enterprisesDatabase.getAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.enterprise:
        return await enterprisesDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get an enterprise'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.internships:
        return await internshipsDatabase.getAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.internship:
        return await internshipsDatabase.getById(
          id: _getId(data,
              messageOnNull: 'An "id" is required to get an internship'),
          fields: (data?['fields'] as List?)?.cast<String>(),
          schoolBoardId: schoolBoardId,
        );
    }
  }

  Future<List<String>?> put(RequestFields field,
      {required Map<String, dynamic>? data,
      required String schoolBoardId}) async {
    if (data == null) {
      throw MissingDataException('Data is required to put something');
    }

    switch (field) {
      case RequestFields.schoolBoards:
        await schoolBoardsDatabase.putAll(
            data: data, schoolBoardId: schoolBoardId);
        return null;
      case RequestFields.schoolBoard:
        return await schoolBoardsDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a school board'),
            data: data,
            schoolBoardId: schoolBoardId);
      case RequestFields.teachers:
        await teachersDatabase.putAll(data: data, schoolBoardId: schoolBoardId);
        return null;
      case RequestFields.teacher:
        return await teachersDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a teacher'),
            data: data,
            schoolBoardId: schoolBoardId);
      case RequestFields.students:
        await studentsDatabase.putAll(data: data, schoolBoardId: schoolBoardId);
        return null;
      case RequestFields.student:
        return await studentsDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a student'),
            data: data,
            schoolBoardId: schoolBoardId);
      case RequestFields.enterprises:
        await enterprisesDatabase.putAll(
            data: data, schoolBoardId: schoolBoardId);
        return null;
      case RequestFields.enterprise:
        return await enterprisesDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put an enterprise'),
            data: data,
            schoolBoardId: schoolBoardId,
            internshipsRepository: internshipsDatabase);
      case RequestFields.internships:
        await internshipsDatabase.putAll(
            data: data, schoolBoardId: schoolBoardId);
        return null;
      case RequestFields.internship:
        return await internshipsDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put an internship'),
            data: data,
            schoolBoardId: schoolBoardId);
    }
  }

  Future<List<String>> delete(
    RequestFields field, {
    required Map<String, dynamic>? data,
    required String schoolBoardId,
  }) async {
    switch (field) {
      case RequestFields.schoolBoards:
        return await schoolBoardsDatabase.deleteAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.schoolBoard:
        return [
          await schoolBoardsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete a school board'),
            schoolBoardId: schoolBoardId,
          )
        ];
      case RequestFields.teachers:
        return await teachersDatabase.deleteAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.teacher:
        return [
          await teachersDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete a teacher'),
            schoolBoardId: schoolBoardId,
          )
        ];
      case RequestFields.students:
        return await studentsDatabase.deleteAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.student:
        return [
          await studentsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete a student'),
            schoolBoardId: schoolBoardId,
          )
        ];
      case RequestFields.enterprises:
        return await enterprisesDatabase.deleteAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.enterprise:
        return [
          // TODO: The frontend don't know they should update their internships
          await enterprisesDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete an enterprise'),
            schoolBoardId: schoolBoardId,
            internshipsRepository: internshipsDatabase,
          )
        ];
      case RequestFields.internships:
        return await internshipsDatabase.deleteAll(
          schoolBoardId: schoolBoardId,
        );
      case RequestFields.internship:
        return [
          await internshipsDatabase.deleteById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to delete an internship'),
            schoolBoardId: schoolBoardId,
          )
        ];
    }
  }
}
