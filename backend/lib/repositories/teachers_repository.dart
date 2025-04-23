import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:mysql1/mysql1.dart';

abstract class TeachersRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({List<String>? fields}) async {
    final teachers = await _getAllTeachers();
    return teachers
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById(
      {required String id, List<String>? fields}) async {
    final teacher = await _getTeacherById(id: id);
    if (teacher == null) throw MissingDataException('Teacher not found');

    return teacher.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Teachers must be created individually');

  @override
  Future<List<String>> putById(
      {required String id, required Map<String, dynamic> data}) async {
    // Update if exists, insert if not
    final previous = await _getTeacherById(id: id);

    final newTeacher = previous?.copyWithData(data) ??
        Teacher.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putTeacher(teacher: newTeacher, previous: previous);
    return newTeacher.getDifference(previous);
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
          ),
          MySqlSelectSubQuery(
            dataTableName: 'teacher_itineraries',
            asName: 'itineraries',
            idNameToDataTable: 'teacher_id',
            fieldsToFetch: ['id', 'date'],
          ),
        ]);

    final map = <String, Teacher>{};
    for (final teacher in teachers) {
      final id = teacher['id'].toString();
      teacher
          .addAll((teacher['persons'] as List).first as Map<String, dynamic>);
      final teachingGroups = teacher['teaching_groups'] as List?;
      teacher['groups'] =
          teachingGroups?.map((map) => map['group_name'] as String).toList();

      teacher['phone'] =
          (teacher['phone_numbers'] as List?)?.firstOrNull as Map? ?? {};
      teacher['address'] =
          (teacher['addresses'] as List?)?.firstOrNull as Map? ?? {};

      if (teacher['itineraries'] != null) {
        final itineraries = teacher['itineraries'] as List;
        for (final itinerary in itineraries) {
          final waypoints = await MySqlHelpers.performSelectQuery(
              connection: connection,
              tableName: 'teacher_itinerary_waypoints',
              idName: 'itinerary_id',
              id: itinerary['id']);
          itinerary['waypoints'] = [
            for (final waypoint in waypoints)
              {
                'id': waypoint['step_index']?.toString(),
                'title': waypoint['title'],
                'subtitle': waypoint['subtitle'],
                'latitude': waypoint['latitude'],
                'longitude': waypoint['longitude'],
                'address': {
                  'civic': waypoint['address_civic'],
                  'street': waypoint['address_street'],
                  'apartment': waypoint['address_apartment'],
                  'city': waypoint['address_city'],
                  'postal_code': waypoint['address_postal_code']
                },
                'priority': waypoint['visiting_priority'],
              }
          ]..sort((a, b) => a['id'].compareTo(b['id']));
        }
      }

      map[id] = Teacher.fromSerialized(teacher);
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

      // Insert itineraries
      for (final itinerary in teacher.itineraries) {
        await _sendItineraries(connection, teacher, itinerary);
      }
    } catch (e) {
      try {
        // Try to delete the inserted data in case of error. Since they by
        // design cannot have already be involved in any internships,
        // we can safely delete them
        _deleteTeacher(teacher);
      } catch (e) {
        // Do nothing
      }
      rethrow;
    }
  }

  Future<void> _putExistingTeacher(Teacher teacher, Teacher previous) async {
    await MySqlHelpers.performUpdatePerson(
        connection: connection, person: teacher, previous: previous);

    // Update the teachers table if needed
    final toUpdate = <String, dynamic>{};
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
    if (areListsNotEqual(teacher.groups, previous.groups)) {
      await MySqlHelpers.performDeleteQuery(
          connection: connection, tableName: 'teaching_groups', id: teacher.id);
      for (final group in teacher.groups) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'teaching_groups',
            data: {'id': teacher.id, 'group_name': group});
      }
    }

    // Update itineraries
    for (final itinerary in teacher.itineraries) {
      // Check if the itinerary already exists
      final previousItinerary =
          previous.itineraries.firstWhereOrNull((e) => e.id == itinerary.id);

      if (previousItinerary == null || itinerary != previousItinerary) {
        if (previousItinerary != null) {
          // Delete the old itinerary if it exists
          await MySqlHelpers.performDeleteQuery(
              connection: connection,
              tableName: 'teacher_itineraries',
              idName: 'id',
              id: previousItinerary.id);
        }
        await _sendItineraries(connection, teacher, itinerary);
      }
    }
  }

  Future<void> _deleteTeacher(Teacher teacher) async {
    // Note, the deletion of the teacher will fail if they were involved in any
    // interships which therefore needs to be reassigned first

    // Delete the teacher from the database
    await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'entities',
        idName: 'shared_id',
        id: teacher.id);
  }
}

Future<void> _sendItineraries(
    MySqlConnection connection, Teacher teacher, Itinerary itinerary) async {
  final serialized = itinerary.serialize();
  await MySqlHelpers.performInsertQuery(
      connection: connection,
      tableName: 'teacher_itineraries',
      data: {
        'id': serialized['id'],
        'teacher_id': teacher.id,
        'date': serialized['date'],
      });

  for (int i = 0; i < serialized['waypoints'].length; i++) {
    final waypoint = serialized['waypoints'][i];
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'teacher_itinerary_waypoints',
        data: {
          'step_index': i,
          'itinerary_id': serialized['id'],
          'title': waypoint['title'],
          'subtitle': waypoint['subtitle'],
          'latitude': waypoint['latitude'],
          'longitude': waypoint['longitude'],
          'address_civic': waypoint['address']['civic'],
          'address_street': waypoint['address']['street'],
          'address_apartment': waypoint['address']['apartment'],
          'address_city': waypoint['address']['city'],
          'address_postal_code': waypoint['address']['postal_code'],
          'visiting_priority': waypoint['priority'],
        });
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
        address: Address.empty,
        itineraries: []),
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
        address: Address.empty,
        itineraries: []),
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
