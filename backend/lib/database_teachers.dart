import 'package:backend/database_interface_abstract.dart';
import 'package:backend/exceptions.dart';
import 'package:common/teacher.dart';
import 'package:mysql1/mysql1.dart';

abstract class DatabaseTeachers implements DatabaseInterfaceAbstract {
  @override
  Future<Map<String, dynamic>> getAll() async {
    final teachers = await _getAllTeachers();
    return teachers.map((key, value) => MapEntry(key, value.serialize()));
  }

  @override
  Future<Map<String, dynamic>> getById({required String id}) async {
    final teacher = await _getTeacherById(id: id);
    if (teacher == null) throw MissingDataException('Teacher not found');

    return teacher.serialize();
  }

  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Teachers must be created individually');

  @override
  Future<void> putById(
      {required String id, required Map<String, dynamic> data}) async {
    // Update if exists, insert if not
    final oldTeacher = await _getTeacherById(id: id);

    final newTeacher = oldTeacher?.copyWithData(data) ??
        Teacher.deserialize({'id': id}..addAll(data));

    await _putTeacher(teacher: newTeacher, isNew: oldTeacher == null);
  }

  Future<Map<String, Teacher>> _getAllTeachers();

  Future<Teacher?> _getTeacherById({required String id});

  Future<void> _putTeacher({required Teacher teacher, required bool isNew});
}

class MySqlDatabaseTeacher extends DatabaseTeachers {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlDatabaseTeacher({required this.connection});

  @override
  Future<Map<String, Teacher>> _getAllTeachers() async {
    final results = await connection.query('SELECT * FROM Teachers');
    return {
      for (var row in results)
        row[0].toString(): Teacher(
            id: row[0].toString(), name: row[1] as String, age: row[2] as int)
    };
  }

  @override
  Future<Teacher?> _getTeacherById({required String id}) async {
    final results =
        await connection.query('SELECT * FROM Teachers WHERE id = ?', [id]);
    if (results.isEmpty) return null;

    final row = results.first;
    return Teacher(
        id: row[0].toString(), name: row[1] as String, age: row[2] as int);
  }

  @override
  Future<void> _putTeacher(
      {required Teacher teacher, required bool isNew}) async {
    // Update if exists, insert if not
    if (isNew) {
      // Insert the teacher
      await connection.query(
          'INSERT INTO Teachers (id, Name, Age) VALUES (?, ?, ?)',
          [teacher.id, teacher.name, teacher.age]);
    } else {
      // Update the teacher
      await connection.query(
          'UPDATE Teachers SET Name = ?, Age = ? WHERE id = ?',
          [teacher.name, teacher.age, teacher.id]);
    }
  }

  // coverage:ignore-end
}

class DatabaseTeachersMock extends DatabaseTeachers {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Teacher(id: '0', name: 'John Doe', age: 60),
    '1': Teacher(id: '1', name: 'Jane Doe', age: 50),
  };

  @override
  Future<Map<String, Teacher>> _getAllTeachers() async => _dummyDatabase;

  @override
  Future<Teacher?> _getTeacherById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putTeacher(
          {required Teacher teacher, required bool isNew}) async =>
      _dummyDatabase[teacher.id] = teacher;
}
