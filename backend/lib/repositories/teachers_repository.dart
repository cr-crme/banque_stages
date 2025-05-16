import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('TeachersRepository');

abstract class TeachersRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required String schoolBoardId,
  }) async {
    final teachers = await _getAllTeachers(schoolBoardId: schoolBoardId);
    return teachers
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById({
    required String id,
    List<String>? fields,
    required String schoolBoardId,
  }) async {
    final teacher = await _getTeacherById(id: id, schoolBoardId: schoolBoardId);
    if (teacher == null) throw MissingDataException('Teacher not found');

    return teacher.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({
    required Map<String, dynamic> data,
    required String schoolBoardId,
  }) async =>
      throw InvalidRequestException('Teachers must be created individually');

  @override
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required String schoolBoardId,
  }) async {
    // Update if exists, insert if not
    final previous =
        await _getTeacherById(id: id, schoolBoardId: schoolBoardId);

    final newTeacher = previous?.copyWithData(data) ??
        Teacher.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    try {
      await _putTeacher(teacher: newTeacher, previous: previous);
      return newTeacher.getDifference(previous);
    } catch (e) {
      _logger.severe('Error while putting teacher: $e');
      return [];
    }
  }

  @override
  Future<List<String>> deleteAll({
    required String schoolBoardId,
  }) async {
    throw InvalidRequestException('Teachers must be deleted individually');
  }

  @override
  Future<String> deleteById({
    required String id,
    required String schoolBoardId,
  }) async {
    final removedId = await _deleteTeacher(id: id);
    if (removedId == null) throw MissingDataException('Teacher not found');
    return removedId;
  }

  Future<Map<String, Teacher>> _getAllTeachers({required String schoolBoardId});

  Future<Teacher?> _getTeacherById(
      {required String id, required String schoolBoardId});

  Future<void> _putTeacher(
      {required Teacher teacher, required Teacher? previous});

  Future<String?> _deleteTeacher({required String id});
}

class MySqlTeachersRepository extends TeachersRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlTeachersRepository({required this.connection});

  @override
  Future<Map<String, Teacher>> _getAllTeachers(
      {String? teacherId, required String schoolBoardId}) async {
    final teachers = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'teachers',
        filters: (teacherId == null ? {} : {'id': teacherId})
          ..addAll({
            'school_board_id': schoolBoardId,
          }),
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
            filters: {'itinerary_id': itinerary['id']},
          );
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
  Future<Teacher?> _getTeacherById(
          {required String id, required String schoolBoardId}) async =>
      (await _getAllTeachers(teacherId: id, schoolBoardId: schoolBoardId))[id];

  Future<void> _insertToTeachers(Teacher teacher) async {
    await MySqlHelpers.performInsertPerson(
        connection: connection, person: teacher);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'teachers',
        data: {
          'id': teacher.id,
          'school_board_id': teacher.schoolBoardId,
          'school_id': teacher.schoolId
        });
  }

  Future<void> _updateToTeachers(Teacher teacher, Teacher previous) async {
    final differences = teacher.getDifference(previous);

    if (differences.contains('school_board_id')) {
      _logger.severe('Cannot update school_board_id for the teachers');
      throw InvalidRequestException(
          'Cannot update school_board_id for the teachers');
    }
    if (differences.contains('school_id')) {
      _logger.severe('Cannot update school_id for the teachers');
      throw InvalidRequestException('Cannot update school_id for the teachers');
    }

    // Update the persons table if needed
    await MySqlHelpers.performUpdatePerson(
        connection: connection, person: teacher, previous: previous);
  }

  Future<void> _insertToGroups(Teacher teacher) async {
    final toWait = <Future>[];
    for (final group in teacher.groups) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'teaching_groups',
          data: {'teacher_id': teacher.id, 'group_name': group}));
    }
    await Future.wait(toWait);
  }

  Future<void> _updateToGroups(Teacher teacher, Teacher previous) async {
    final differences = teacher.getDifference(previous);
    if (!differences.contains('groups')) return;

    // This is a bit tricky to update the groups, so we delete the old ones
    // and reinsert the new ones
    await MySqlHelpers.performDeleteQuery(
      connection: connection,
      tableName: 'teaching_groups',
      filters: {'teacher_id': teacher.id},
    );
    await _insertToGroups(teacher);
  }

  Future<void> _insertToItineraries(Teacher teacher) async {
    for (final itinerary in teacher.itineraries) {
      await _sendItineraries(connection, teacher, itinerary);
    }
  }

  Future<void> _updateToItineraries(Teacher teacher, Teacher previous) async {
    final differences = teacher.getDifference(previous);
    if (!differences.contains('itineraries')) return;

    // Update itineraries
    final toWaitDeleted = <Future>[];
    final toWait = <Future>[];
    for (final itinerary in teacher.itineraries) {
      // Check if the itinerary already exists and/or has changed
      final previousItinerary =
          previous.itineraries.firstWhereOrNull((e) => e.id == itinerary.id);
      if (previousItinerary != null && itinerary == previousItinerary) continue;

      // This is a bit tricky to update the itineraries, so we delete the old
      // ones and reinsert the new ones
      if (previousItinerary != null) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'teacher_itineraries',
          filters: {'id': previousItinerary.id},
        ));
      }
      toWait.add(_sendItineraries(connection, teacher, itinerary));
    }

    await Future.wait(toWaitDeleted);
    await Future.wait(toWait);
  }

  @override
  Future<void> _putTeacher(
      {required Teacher teacher, required Teacher? previous}) async {
    if (previous == null) {
      await _insertToTeachers(teacher);
    } else {
      await _updateToTeachers(teacher, previous);
    }

    final toWait = <Future>[];
    if (previous == null) {
      toWait.add(_insertToGroups(teacher));
      toWait.add(_insertToItineraries(teacher));
    } else {
      toWait.add(_updateToGroups(teacher, previous));
      toWait.add(_updateToItineraries(teacher, previous));
    }
    await Future.wait(toWait);
  }

  @override
  Future<String?> _deleteTeacher({required String id}) async {
    // Note, the deletion of the teacher will fail if they were involved in any
    // internships which therefore needs to be reassigned first

    // Delete the teacher from the database
    try {
      await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'entities',
        filters: {'shared_id': id},
      );
      return id;
    } catch (e) {
      return null;
    }
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
        schoolBoardId: '10',
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
        schoolBoardId: '10',
        schoolId: '10',
        groups: ['100', '101'],
        phone: PhoneNumber.fromString('123-456-7890'),
        email: 'john.doe@email.com',
        dateBirth: null,
        address: Address.empty,
        itineraries: []),
  };

  @override
  Future<Map<String, Teacher>> _getAllTeachers(
          {required String schoolBoardId}) async =>
      _dummyDatabase;

  @override
  Future<Teacher?> _getTeacherById(
          {required String id, required String schoolBoardId}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putTeacher(
          {required Teacher teacher, required Teacher? previous}) async =>
      _dummyDatabase[teacher.id] = teacher;

  @override
  Future<String?> _deleteTeacher({required String id}) async {
    if (_dummyDatabase.containsKey(id)) {
      _dummyDatabase.remove(id);
      return id;
    }
    return null;
  }
}
