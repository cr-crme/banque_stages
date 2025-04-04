import 'package:backend/database_teachers.dart';
import 'package:backend/exceptions.dart';
import 'package:common/communication_protocol.dart';

String _getId(Map<String, dynamic>? data, {required String messageOnNull}) {
  final id = data?['id']?.toString();
  if (id == null || id.isEmpty) throw MissingFieldException(messageOnNull);
  return id;
}

class DatabaseManager {
  DatabaseManager() {
    // TODO: Initialize the database connexion here
  }

  Future<Map<String, dynamic>> get(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    switch (field) {
      case RequestFields.teachers:
        return await getTeachers();
      case RequestFields.teacher:
        return await getTeacher(
            id: _getId(data,
                messageOnNull: 'An "id" is required to get a teacher'));
    }
  }

  Future<Map<String, dynamic>?> put(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    if (data == null) {
      throw MissingDataException('Data is required to put something');
    }

    switch (field) {
      case RequestFields.teachers:
        return await putTeachers(data: data);
      case RequestFields.teacher:
        return await putTeacher(
            id: _getId(data,
                messageOnNull: 'An "id" is required to put a teacher'),
            data: data);
    }
  }
}
