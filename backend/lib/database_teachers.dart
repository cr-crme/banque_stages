import 'dart:convert';

import 'package:backend/database_interface_abstract.dart';
import 'package:backend/exceptions.dart';
import 'package:backend/helpers.dart';
import 'package:backend/mysql_helpers.dart';
import 'package:common/models/address.dart';
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
    final previous = await _getTeacherById(id: id);

    final newTeacher = previous?.copyWithData(data) ??
        Teacher.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putTeacher(teacher: newTeacher, previous: previous);
  }

  Future<Map<String, Teacher>> _getAllTeachers();

  Future<Teacher?> _getTeacherById({required String id});

  Future<void> _putTeacher(
      {required Teacher teacher, required Teacher? previous});
}

class MySqlDatabaseTeacher extends DatabaseTeachers {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlDatabaseTeacher({required this.connection});

  @override
  Future<Map<String, Teacher>> _getAllTeachers({String? teacherId}) async {
    final results = await tryQuery(connection, '''
      SELECT t.*, 
      (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'id', p.id,
                'phone_number', p.phone_number
            )
        )
        FROM phone_numbers_teachers pt
        JOIN phone_numbers p ON p.id = pt.phone_number_id
        WHERE pt.teacher_id = t.id
      ) AS phone_numbers,
      IFNULL((
          SELECT JSON_ARRAYAGG(
              JSON_OBJECT('group_name', tg.group_name)
          )
          FROM teaching_groups tg
          WHERE tg.teacher_id = t.id
      ), JSON_ARRAY()) AS group_names
      FROM teachers t ${teacherId == null ? '' : 'WHERE t.id="$teacherId"'};
    ''');
    return {
      for (final teacher in results)
        teacher['id'].toString(): Teacher(
          id: teacher['id'].toString(),
          firstName: teacher['first_name'] as String,
          middleName: teacher['middle_name'] as String?,
          lastName: teacher['last_name'] as String,
          schoolId: teacher['school_id'] as String,
          groups: (jsonDecode(teacher['group_names']) as List?)
                  ?.map((map) => map['group_name'] as String)
                  .toList() ??
              [],
          email: teacher['email'] as String?,
          phone: PhoneNumber.fromString(
              (jsonDecode(teacher['phone_numbers']) as List?)
                      ?.first['phone_number'] as String? ??
                  ''),
          address: Address.empty,
          dateBirth: null,
        )
    };
  }

  @override
  Future<Teacher?> _getTeacherById({required String id}) async =>
      (await _getAllTeachers(teacherId: id))[id];

  @override
  Future<void> _putTeacher(
          {required Teacher teacher, required Teacher? previous}) async =>
      previous == null
          ? await _putNewTeacher(teacher)
          : await _putExistingTeacher(teacher, previous);

  Future<void> _putNewTeacher(Teacher teacher) async {
    // Insert the teacher
    await tryQuery(
        connection,
        'INSERT INTO teachers (id, first_name, middle_name, last_name, school_id, email) VALUES (?, ?, ?, ?, ?, ?)',
        [
          teacher.id,
          teacher.firstName,
          teacher.middleName,
          teacher.lastName,
          teacher.schoolId,
          teacher.email,
        ]);
    // Insert the groups
    for (final group in teacher.groups) {
      await tryQuery(
          connection,
          'INSERT INTO teaching_groups (teacher_id, group_name) VALUES (?, ?)',
          [teacher.id, group]);
    }

    // Insert the phone number
    await tryQuery(
        connection,
        'INSERT INTO phone_numbers (id, phone_number) VALUES (?, ?)',
        [teacher.phone.id, teacher.phone.toString()]);
    await tryQuery(
        connection,
        'INSERT INTO phone_numbers_teachers (teacher_id, phone_number_id) VALUES (?, ?)',
        [teacher.id, teacher.phone.id]);
  }

  Future<void> _putExistingTeacher(Teacher teacher, Teacher previous) async {
    String query = 'UPDATE teachers SET ';
    final List params = [];
    // TODO Is this useful to only update the fields that are different?
    if (teacher.firstName != previous.firstName) {
      query += 'first_name = ?, ';
      params.add(teacher.firstName);
    }
    if (teacher.middleName != previous.middleName) {
      query += 'middle_name = ?, ';
      params.add(teacher.middleName);
    }
    if (teacher.lastName != previous.lastName) {
      query += 'last_name = ?, ';
      params.add(teacher.lastName);
    }
    if (teacher.schoolId != previous.schoolId) {
      query += 'school_id = ?, ';
      params.add(teacher.schoolId);
    }
    if (teacher.email != previous.email) {
      query += 'email = ?, ';
      params.add(teacher.email);
    }

    // Update the teacher
    if (params.isNotEmpty) {
      params.add(teacher.id);
      await tryQuery(connection,
          '${query.substring(0, query.length - 2)} WHERE id = ?', params);
    }

    // Update teaching groups
    if (isNotListEqual(teacher.groups, previous.groups)) {
      await tryQuery(connection,
          'DELETE FROM teaching_groups WHERE teacher_id = ?', [teacher.id]);
      for (var group in teacher.groups) {
        await tryQuery(
            connection,
            'INSERT INTO teaching_groups (teacher_id, group_id) VALUES (?, ?)',
            [teacher.id, group]);
      }
    }

    // Update the phone number
    if (teacher.phone != previous.phone) {
      await tryQuery(
          connection,
          'UPDATE phone_numbers SET phone_number = ? WHERE teacher_id = ?',
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
        middleName: null,
        lastName: 'Doe',
        schoolId: '10',
        groups: ['100', '101'],
        phone: PhoneNumber.fromString('098-765-4321'),
        email: 'john.doe@email.com',
        dateBirth: null,
        address: Address.empty),
    '1': Teacher(
        id: '1',
        firstName: 'Jane',
        middleName: null,
        lastName: 'Doe',
        schoolId: '10',
        groups: ['100', '101'],
        phone: PhoneNumber.fromString('123-456-7890'),
        email: 'john.doe@email.com',
        dateBirth: null,
        address: Address.empty),
  };

  @override
  Future<Map<String, Teacher>> _getAllTeachers() async => _dummyDatabase;

  @override
  Future<Teacher?> _getTeacherById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putTeacher(
          {required Teacher teacher, required Teacher? previous}) async =>
      _dummyDatabase[teacher.id] = teacher;
}
