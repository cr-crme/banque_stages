import 'package:common/communication_protocol.dart';
import 'package:mutex/mutex.dart';

final _dummyTeachers = {
  '1': {'name': 'John Doe'},
  '2': {'name': 'Jane Smith'}
};

class DatabaseManager {
  final _mutex = ReadWriteMutex();

  DatabaseManager() {
    // TODO: Initialize the database connexion here
  }

  Future<Map<String, dynamic>> get(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    return await _mutex.protectRead(() async {
      //throw 'Test';
      switch (field) {
        case RequestFields.teachers:
          {
            return _dummyTeachers;
          }
        case RequestFields.teacher:
          {
            final id = data!['id'];
            if (id == null) {
              throw Exception('"id" is required to get a teacher');
            }
            if (id is! String) throw Exception('"id" must be a string');
            if (id.isEmpty) throw Exception('"id" cannot be empty');
            if (!_dummyTeachers.containsKey(id)) {
              throw Exception('Teacher not found');
            }
            return _dummyTeachers[id]!;
          }
      }
    });
  }

  Future<Map<String, dynamic>?> put(RequestFields field,
      {required Map<String, dynamic>? data}) async {
    if (data == null) {
      throw Exception('Data is required to put a teacher');
    }

    return await _mutex.protectWrite(() async {
      switch (field) {
        case RequestFields.teacher:
          {
            final id = data['id'];
            if (id == null) {
              throw Exception('ID is required to put a teacher');
            }
            if (_dummyTeachers.containsKey(id)) {
              _dummyTeachers[id] = data['data'];
              return null;
            } else {
              throw Exception('Teacher not found');
            }
          }
        case RequestFields.teachers:
          // Invalid request type for the server
          throw Exception('Invalid request type for the server');
      }
    });
  }
}
