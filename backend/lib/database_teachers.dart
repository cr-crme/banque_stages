import 'package:backend/database_interface_abstract.dart';
import 'package:backend/exceptions.dart';
import 'package:common/models/phone_number.dart';
import 'package:common/models/teacher.dart';
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
        Teacher.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

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
    try {
      final results = await connection.query('SELECT * FROM teachers');
      return {
        for (var row in results)
          row[0].toString(): Teacher(
            id: row[0].toString(),
            firstName: row[1] as String,
            middleName: row[2] as String?,
            lastName: row[3] as String,
            schoolId: row[4] as String,
            groups: (await connection.query(
                    'SELECT * FROM teaching_groups WHERE teacher_id = ?',
                    [row[0].toString()]))
                .map((e) => e[1].toString())
                .toList(),
            email: row[5] as String?,
            phone: PhoneNumber.fromString(row[6].toString()),
          )
      };
    } catch (_) {
      return {};
    }
  }

  @override
  Future<Teacher?> _getTeacherById({required String id}) async {
// SELECT
// t.id AS teacher_id,
// t.Name AS teacher_name,
// a.id AS address_id,
// a.street,
// a.city,
// a.zip_code,
// a.country
// FROM Teachers t
// JOIN AddressesTeachers at ON t.id = at.teacher_id
// JOIN Addresses a ON a.id = at.address_id
// WHERE t.id = ?;

    // TODO Make a single query?
    final results =
        await connection.query('SELECT * FROM teachers WHERE id = ?', [id]);
    if (results.isEmpty) return null;

    final row = results.first;
    final teacherId = row[0].toString();

    final phoneNumber = await connection.query(
        'SELECT * FROM phone_numbers_teachers WHERE teacher_id = ?',
        [teacherId]);
    final groups = await connection.query(
        'SELECT * FROM teaching_groups WHERE teacher_id = ?', [teacherId]);

    return Teacher(
      id: teacherId,
      firstName: row[1] as String,
      middleName: row[2] as String?,
      lastName: row[3] as String,
      schoolId: row[4] as String,
      groups: groups.map((e) => e[1].toString()).toList(),
      email: row[5] as String?,
      phone: PhoneNumber.fromString(phoneNumber.first.toString()),
    );
  }

  @override
  Future<void> _putTeacher(
      {required Teacher teacher, required bool isNew}) async {
    // Update if exists, insert if not
    if (isNew) {
      // Insert the teacher
      await connection.query(
          'INSERT INTO teachers (id, first_name, middle_name, last_name, school_id, email, phone) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            teacher.id,
            teacher.firstName,
            teacher.middleName,
            teacher.lastName,
            teacher.schoolId,
            teacher.email,
            teacher.phone.toString()
          ]);
      // Insert the groups
      for (var group in teacher.groups) {
        await connection.query(
            'INSERT INTO teaching_groups (teacher_id, group_id) VALUES (?, ?)',
            [teacher.id, group]);
      }
      // Insert the phone number
      await connection.query(
          'INSERT INTO phone_numbers_teachers (teacher_id, phone_number) VALUES (?, ?)',
          [teacher.id, teacher.phone.toString()]);
    } else {
      // Update the teacher
      await connection.query(
          'UPDATE teachers SET first_name = ?, middle_name = ?, last_name = ?, school_id = ?, email = ?, phone = ? WHERE id = ?',
          [
            teacher.firstName,
            teacher.middleName,
            teacher.lastName,
            teacher.schoolId,
            teacher.email,
            teacher.phone.toString(),
            teacher.id
          ]);
      // Update the groups
      await connection.query(
          'DELETE FROM teaching_groups WHERE teacher_id = ?', [teacher.id]);
      for (var group in teacher.groups) {
        await connection.query(
            'INSERT INTO teaching_groups (teacher_id, group_id) VALUES (?, ?)',
            [teacher.id, group]);
      }
      // Update the phone number
      await connection.query(
          'UPDATE phone_numbers_teachers SET phone_number = ? WHERE teacher_id = ?',
          [teacher.phone.toString(), teacher.id]);
    }
  }

  // coverage:ignore-end
}

class DatabaseTeachersMock extends DatabaseTeachers {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Teacher(
        id: '0',
        firstName: 'John',
        lastName: 'Doe',
        schoolId: '10',
        groups: ['100', '101'],
        phone: PhoneNumber.fromString('+1-234-567-8901'),
        email: 'john.doe@email.com'),
    '1': Teacher(
        id: '1',
        firstName: 'Jane',
        lastName: 'Doe',
        schoolId: '10',
        groups: ['100', '101'],
        phone: PhoneNumber.fromString('+1-234-567-8901'),
        email: 'john.doe@email.com'),
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
