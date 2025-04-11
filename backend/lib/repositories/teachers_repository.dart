import 'dart:convert';

import 'package:backend/repositories/mysql_repository_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:backend/utils/helpers.dart';
import 'package:common/models/address.dart';
import 'package:common/models/phone_number.dart';
import 'package:common/models/teacher.dart';
import 'package:mysql1/mysql1.dart';

abstract class TeachersRepository implements RepositoryAbstract {
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

class MySqlTeachersRepository extends TeachersRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlTeachersRepository({required this.connection});

  @override
  Future<Map<String, Teacher>> _getAllTeachers({String? teacherId}) async {
    final results = await performSelectQuery(
        connection: connection,
        tableName: 'teachers',
        elementId: teacherId,
        sublists: [
          MySqlNormalizedTable(
            mainTableName: 'phone_numbers',
            subtableName: 'phone_numbers_teachers',
            fieldsToFetch: ['id', 'phone_number'],
            tableId: 'id',
            subTableId: 'phone_number_id',
            foreignId: 'teacher_id',
          ),
          MySqlNormalizedTable(
            mainTableName: 'addresses',
            subtableName: 'addresses_teachers',
            fieldsToFetch: [
              'id',
              'civic',
              'street',
              'appartment',
              'city',
              'postal_code'
            ],
            tableId: 'id',
            subTableId: 'address_id',
            foreignId: 'teacher_id',
          ),
          MySqlTable(
            tableName: 'teaching_groups',
            fieldsToFetch: ['group_name'],
            tableId: 'teacher_id',
          )
        ]);

    return {
      for (final teacher in results)
        teacher['id'].toString(): Teacher(
          id: teacher['id'].toString(),
          firstName: teacher['first_name'] as String,
          middleName: teacher['middle_name'] as String?,
          lastName: teacher['last_name'] as String,
          schoolId: teacher['school_id'] as String,
          groups: (jsonDecode(teacher['teaching_groups']) as List?)
                  ?.map((map) => map['group_name'] as String)
                  .toList() ??
              [],
          email: teacher['email'] as String?,
          phone: PhoneNumber.fromSerialized(
              (jsonDecode(teacher['phone_numbers']) as List?)?.first as Map? ??
                  {}),
          address: Address.fromSerialized(
              (jsonDecode(teacher['addresses']) as List?)?.first as Map? ?? {}),
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
    await performInsertQuery(
        connection: connection,
        tableName: 'teachers',
        data: {
          'id': teacher.id,
          'first_name': teacher.firstName,
          'middle_name': teacher.middleName,
          'last_name': teacher.lastName,
          'school_id': teacher.schoolId,
          'email': teacher.email
        });
    // Insert the groups
    for (final group in teacher.groups) {
      await performInsertQuery(
          connection: connection,
          tableName: 'teaching_groups',
          data: {'teacher_id': teacher.id, 'group_name': group});
    }

    // Insert the phone number
    await performInsertNormalizedQuery(
        connection: connection,
        tableName: 'phone_numbers',
        data: {
          'id': teacher.phone.id,
          'phone_number': teacher.phone.toString()
        },
        normalizedTableName: 'phone_numbers_teachers',
        normalizedKeys: {
          'teacher_id': teacher.id,
          'phone_number_id': teacher.phone.id
        });

    // Insert the address
    await performInsertNormalizedQuery(
        connection: connection,
        tableName: 'addresses',
        data: {
          'id': teacher.address.id,
          'civic': teacher.address.civicNumber,
          'street': teacher.address.street,
          'appartment': teacher.address.appartment,
          'city': teacher.address.city,
          'postal_code': teacher.address.postalCode
        },
        normalizedTableName: 'addresses_teachers',
        normalizedKeys: {
          'teacher_id': teacher.id,
          'address_id': teacher.address.id
        });
  }

  Future<void> _putExistingTeacher(Teacher teacher, Teacher previous) async {
    final toUpdate = <String, dynamic>{};
    if (teacher.firstName != previous.firstName) {
      toUpdate['first_name'] = teacher.firstName;
    }
    if (teacher.middleName != previous.middleName) {
      toUpdate['middle_name'] = teacher.middleName;
    }
    if (teacher.lastName != previous.lastName) {
      toUpdate['last_name'] = teacher.lastName;
    }
    if (teacher.schoolId != previous.schoolId) {
      toUpdate['school_id'] = teacher.schoolId;
    }
    if (teacher.email != previous.email) {
      toUpdate['email'] = teacher.email;
    }

    // Update the teacher
    if (toUpdate.isNotEmpty) {
      await performUpdateQuery(
          connection: connection,
          tableName: 'teachers',
          id: MapEntry('id', teacher.id),
          data: toUpdate);
    }

    // Update teaching groups
    if (isNotListEqual(teacher.groups, previous.groups)) {
      await performDeleteQuery(
          connection: connection,
          tableName: 'teaching_groups',
          id: MapEntry('teacher_id', teacher.id));
      for (final group in teacher.groups) {
        await performInsertQuery(
            connection: connection,
            tableName: 'teaching_groups',
            data: {'teacher_id': teacher.id, 'group_name': group});
      }
    }

    // Update the phone number
    if (teacher.phone != previous.phone) {
      await performUpdateQuery(
          connection: connection,
          tableName: 'phone_numbers',
          id: MapEntry('teacher_id', teacher.id),
          data: {'phone_number': teacher.phone.toString()});
    }
  }
  // coverage:ignore-end
}

class DatabaseTeachersMock extends TeachersRepository {
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
