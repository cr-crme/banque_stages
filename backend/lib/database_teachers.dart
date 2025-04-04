import 'package:backend/exceptions.dart';
import 'package:common/teacher.dart';
import 'package:mutex/mutex.dart';

final _dummyTeachers = {
  '0': Teacher(name: 'John Doe', age: 60),
  '1': Teacher(name: 'Jane Doe', age: 50),
};

final _mutex = ReadWriteMutex();

Future<Map<String, dynamic>> getTeachers() async {
  return await _mutex.protectRead(() async =>
      _dummyTeachers.map((key, value) => MapEntry(key, value.serialize())));
}

Future<Map<String, dynamic>?> putTeachers(
    {required Map<String, dynamic> data}) async {
  throw InvalidRequestException('Teachers must be created individually');
}

Future<Map<String, dynamic>> getTeacher({required String id}) async {
  return await _mutex.protectRead(() async =>
      (_dummyTeachers[id]?.serialize()?..addAll({'id': id})) ??
      (throw MissingDataException('Teacher not found')));
}

Future<Map<String, dynamic>?> putTeacher(
    {required String id, required Map<String, dynamic> data}) async {
  if (_dummyTeachers.containsKey(id)) {
    _dummyTeachers[id]!.mergeDeserialized(data);
  } else {
    _dummyTeachers[id] = Teacher.deserialize(data);
  }
  return null;
}
