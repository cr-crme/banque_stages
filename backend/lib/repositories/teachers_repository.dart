import 'package:backend/repositories/mysql_helpers.dart';
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
    final teachers = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'teachers',
        id: teacherId,
        subqueries: [
          MySqlSelectSubQuery(
            dataTableName: 'persons',
            fieldsToFetch: ['first_name', 'middle_name', 'last_name', 'email'],
          ),
          MySqlSelectSubQuery(
              dataTableName: 'phone_numbers',
              idNameToDataTable: 'entity_id',
              fieldsToFetch: ['id', 'phone_number']),
          MySqlSelectSubQuery(
              dataTableName: 'addresses',
              idNameToDataTable: 'entity_id',
              fieldsToFetch: [
                'id',
                'civic',
                'street',
                'apartment',
                'city',
                'postal_code'
              ]),
          MySqlSelectSubQuery(
            dataTableName: 'teaching_groups',
            idNameToDataTable: 'teacher_id',
            fieldsToFetch: ['group_name'],
          )
        ]);

    final map = <String, Teacher>{};
    for (final teacher in teachers) {
      final id = teacher['id'].toString();
      final person = (teacher['persons'] as List).first;
      final teachingGroups = teacher['teaching_groups'] as List?;
      final phoneNumbers = teacher['phone_numbers'] as List?;
      final addresses = teacher['addresses'] as List?;

      map[id] = Teacher(
        id: id,
        firstName: person['first_name'] as String,
        middleName: person['middle_name'] as String?,
        lastName: person['last_name'] as String,
        schoolId: teacher['school_id'] as String,
        groups: teachingGroups
                ?.map((map) => map['group_name'] as String)
                .toList() ??
            [],
        email: teacher['email'] as String?,
        phone: PhoneNumber.fromSerialized(phoneNumbers?.first as Map? ?? {}),
        address: Address.fromSerialized(addresses?.first as Map? ?? {}),
        dateBirth: null,
      );
    }
    return map;
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
    try {
      // Insert the teacher
      await MySqlHelpers.performInsertPerson(
          connection: connection, person: teacher);
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'teachers',
          data: {'id': teacher.id, 'school_id': teacher.schoolId});

      // Insert the teaching groups
      for (final group in teacher.groups) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'teaching_groups',
            data: {'teacher_id': teacher.id, 'group_name': group});
      }
    } catch (e) {
      try {
        // Try to delete the inserted data in case of error (everything is ON CASCADE DELETE)
        await MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'entities',
            idName: 'shared_id',
            id: teacher.id);
      } catch (e) {
        // Do nothing
      }
      rethrow;
    }
  }

  Future<void> _putExistingTeacher(Teacher teacher, Teacher previous) async {
    // Update the persons table if needed
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
    if (teacher.email != previous.email) {
      toUpdate['email'] = teacher.email;
    }
    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'persons',
          id: teacher.id,
          data: toUpdate);
    }

    // Update the teachers table if needed
    toUpdate.clear();
    if (teacher.schoolId != previous.schoolId) {
      toUpdate['school_id'] = teacher.schoolId;
    }
    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'teachers',
          id: teacher.id,
          data: toUpdate);
    }

    // Update teaching groups
    if (isNotListEqual(teacher.groups, previous.groups)) {
      await MySqlHelpers.performDeleteQuery(
          connection: connection, tableName: 'teaching_groups', id: teacher.id);
      for (final group in teacher.groups) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'teaching_groups',
            data: {'id': teacher.id, 'group_name': group});
      }
    }

    // Update the phone number
    if (teacher.phone != previous.phone) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'phone_numbers',
          id: teacher.phone.id,
          data: {'phone_number': teacher.phone.toString()});
    }
  }
  // coverage:ignore-end
}

class TeachersRepositoryMock extends TeachersRepository {
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
