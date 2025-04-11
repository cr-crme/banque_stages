import 'package:backend/repositories/enterprises_repository.dart';
import 'package:backend/repositories/teachers_repository.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/communication_protocol.dart';

String _getId(Map<String, dynamic>? data, {required String messageOnNull}) {
  final id = data?['id']?.toString();
  if (id == null || id.isEmpty) throw MissingFieldException(messageOnNull);
  return id;
}

class DatabaseManager {
  DatabaseManager(
      {required this.teacherDatabase, required this.enterpriseDatabase});

  final TeachersRepository teacherDatabase;
  final EnterprisesRepository enterpriseDatabase;

  Future<Map<String, dynamic>> get(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    switch (field) {
      case RequestFields.teachers:
        return await teacherDatabase.getAll();
      case RequestFields.teacher:
        return await teacherDatabase.getById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get a teacher'));
      case RequestFields.enterprises:
        return await enterpriseDatabase.getAll();
      case RequestFields.enterprise:
        return await enterpriseDatabase.getById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get an enterprise'));
    }
  }

  Future<void> put(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    if (data == null) {
      throw MissingDataException('Data is required to put something');
    }

    switch (field) {
      case RequestFields.teachers:
        return await teacherDatabase.putAll(data: data);
      case RequestFields.teacher:
        return await teacherDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a teacher'),
            data: data);
      case RequestFields.enterprises:
        return await enterpriseDatabase.putAll(data: data);
      case RequestFields.enterprise:
        return await enterpriseDatabase.putById(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put an enterprise'),
            data: data);
    }
  }
}
