import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/internships_repository.dart';
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
    required this.teachersDatabase,
    required this.studentsDatabase,
    required this.enterprisesDatabase,
    required this.internshipsDatabase,
  });

  // TODO: Add a SchoolBoardRepository that will be used to limit teachers/students/enterprises
  final TeachersRepository teachersDatabase;
  final StudentsRepository studentsDatabase;
  final EnterprisesRepository enterprisesDatabase;
  final InternshipsRepository internshipsDatabase;

  Future<Map<String, dynamic>> get(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    switch (field) {
      case RequestFields.teachers:
        return await teachersDatabase.getAll();
      case RequestFields.teacher:
        return await teachersDatabase.getById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get a teacher'),
            fields: (data?['fields'] as List?)?.cast<String>());
      case RequestFields.students:
        return await studentsDatabase.getAll();
      case RequestFields.student:
        return await studentsDatabase.getById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get a student'),
            fields: (data?['fields'] as List?)?.cast<String>());
      case RequestFields.enterprises:
        return await enterprisesDatabase.getAll();
      case RequestFields.enterprise:
        return await enterprisesDatabase.getById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get an enterprise'),
            fields: (data?['fields'] as List?)?.cast<String>());
      case RequestFields.internships:
        return await internshipsDatabase.getAll();
      case RequestFields.internship:
        return await internshipsDatabase.getById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get an internship'),
            fields: (data?['fields'] as List?)?.cast<String>());
    }
  }

  Future<List<String>?> put(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    if (data == null) {
      throw MissingDataException('Data is required to put something');
    }

    switch (field) {
      case RequestFields.teachers:
        await teachersDatabase.putAll(data: data);
        return null;
      case RequestFields.teacher:
        return await teachersDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a teacher'),
            data: data);
      case RequestFields.students:
        await studentsDatabase.putAll(data: data);
        return null;
      case RequestFields.student:
        return await studentsDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a student'),
            data: data);
      case RequestFields.enterprises:
        await enterprisesDatabase.putAll(data: data);
        return null;
      case RequestFields.enterprise:
        return await enterprisesDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put an enterprise'),
            data: data);
      case RequestFields.internships:
        await internshipsDatabase.putAll(data: data);
        return null;
      case RequestFields.internship:
        return await internshipsDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put an internship'),
            data: data);
    }
  }
}
