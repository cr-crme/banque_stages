import 'package:common/communication_protocol.dart';
import 'package:mutex/mutex.dart';
import 'package:common/teacher.dart';

final _dummyTeachers = {
  '1': Teacher(name: 'John Doe', age: 60),
  '2': Teacher(name: 'Jane Doe', age: 50),
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
            return _dummyTeachers
                .map((key, value) => MapEntry(key, value.serialize()));
          }
        case RequestFields.teacher:
          {
            final id = data!['id']?.toString();
            if (id == null) {
              throw Exception('"id" is required to get a teacher');
            }
            if (id.isEmpty) throw Exception('"id" cannot be empty');
            if (!_dummyTeachers.containsKey(id)) {
              throw Exception('Teacher not found');
            }
            return _dummyTeachers[id]!.serialize()..addAll({'id': id});
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
            final id = data['id']?.toString();
            if (id == null) {
              throw Exception('ID is required to put a teacher');
            }
            if (_dummyTeachers.containsKey(id)) {
              _dummyTeachers[id]!.mergeDeserialized(data);
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
