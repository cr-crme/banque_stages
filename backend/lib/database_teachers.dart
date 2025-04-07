import 'package:backend/database_interface_abstract.dart';
import 'package:backend/exceptions.dart';
import 'package:common/teacher.dart';
import 'package:mutex/mutex.dart';

abstract class DatabaseTeachers implements DatabaseInterfaceAbstract {
  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Teachers must be created individually');
}

class MySqlDatabaseTeacher extends DatabaseTeachers {
  // coverage:ignore-start
  @override
  Future<Map<String, dynamic>> getAll() async => throw UnimplementedError(
      'getAll() is not implemented in MySqlDatabaseTeacher');

  @override
  Future<Map<String, dynamic>> getById({required String id}) async =>
      throw UnimplementedError(
          'getById() is not implemented in MySqlDatabaseTeacher');

  @override
  Future<void> putById(
          {required String id, required Map<String, dynamic> data}) async =>
      throw UnimplementedError(
          'putById() is not implemented in MySqlDatabaseTeacher');
  // coverage:ignore-end
}

class DatabaseTeachersMock extends DatabaseTeachers {
  final _mutex = ReadWriteMutex();
  // Simulate a database with a map
  final _dummyTeachers = {
    '0': Teacher(id: '0', name: 'John Doe', age: 60),
    '1': Teacher(id: '1', name: 'Jane Doe', age: 50),
  };

  @override
  Future<Map<String, dynamic>> getAll() async => await _getTeachersFromDatase();

  @override
  Future<Map<String, dynamic>> getById({required String id}) async =>
      await _getTeachersFromDatase(id: id);

  @override
  Future<void> putById(
          {required String id, required Map<String, dynamic> data}) async =>
      await _putTeacherToDatabase(id: id, data: data);

  Future<Map<String, dynamic>> _getTeachersFromDatase({String? id}) async {
    // TODO: Change this to a real call to the database
    return await _mutex.protectRead(() async {
      if (id == null) {
        // Return all teachers
        return _dummyTeachers
            .map((key, value) => MapEntry(key, value.serialize()));
      } else {
        // Return a specific teacher
        if (!_dummyTeachers.containsKey(id)) {
          throw MissingDataException('Teacher not found');
        }
        return _dummyTeachers[id]!.serialize();
      }
    });
  }

  Future<void> _putTeacherToDatabase(
      {required String id, required Map<String, dynamic> data}) async {
    // TODO: Change this to a real call to the database
    return await _mutex.protectWrite(() async {
      final teacher = _dummyTeachers.containsKey(id)
          ? _dummyTeachers[id]!.copyWithData(data)
          : Teacher.deserialize(data..addAll({'id': id}));
      _dummyTeachers[teacher.id] = teacher;
    });
  }
}
