import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/database_user.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/utils.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('StudentsRepository');

// AccessLevel in this repository is discarded as all operations are currently
// available to all users

abstract class StudentsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified) {
      _logger.severe(
          'User ${user.userId} does not have permission to get students');
      throw InvalidRequestException(
          'You do not have permission to get students');
    }

    final students = await _getAllStudents(user: user);
    return students
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById({
    required String id,
    List<String>? fields,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified) {
      _logger.severe(
          'User ${user.userId} does not have permission to get students');
      throw InvalidRequestException(
          'You do not have permission to get students');
    }

    final student = await _getStudentById(id: id, user: user);
    if (student == null) throw MissingDataException('Student not found');

    return student.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({
    required Map<String, dynamic> data,
    required DatabaseUser user,
  }) async =>
      throw InvalidRequestException('Students must be created individually');

  @override
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified || user.accessLevel < AccessLevel.admin) {
      _logger.severe(
          'User ${user.userId} does not have permission to put students');
      throw InvalidRequestException(
          'You do not have permission to put students');
    }

    // Update if exists, insert if not
    final previous = await _getStudentById(id: id, user: user);

    final newStudent = previous?.copyWithData(data) ??
        Student.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    try {
      await _putStudent(student: newStudent, previous: previous, user: user);
      return newStudent.getDifference(previous);
    } catch (e) {
      _logger.severe('Error while putting student $id: ${e.toString()}');
      return [];
    }
  }

  @override
  Future<List<String>> deleteAll({
    required DatabaseUser user,
  }) async {
    throw InvalidRequestException('Students must be deleted individually');
  }

  @override
  Future<String> deleteById({
    required String id,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified || user.accessLevel < AccessLevel.admin) {
      _logger.severe(
          'User ${user.userId} does not have permission to delete students');
      throw InvalidRequestException(
          'You do not have permission to delete students');
    }

    final removedId = await _deleteStudent(id: id, user: user);
    if (removedId == null) {
      throw DatabaseFailureException('Failed to delete student with id $id');
    }
    return removedId;
  }

  Future<Map<String, Student>> _getAllStudents({
    required DatabaseUser user,
  });

  Future<Student?> _getStudentById({
    required String id,
    required DatabaseUser user,
  });

  Future<void> _putStudent(
      {required Student student,
      required Student? previous,
      required DatabaseUser user});

  Future<String?> _deleteStudent({
    required String id,
    required DatabaseUser user,
  });
}

class MySqlStudentsRepository extends StudentsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlStudentsRepository({required this.connection});

  @override
  Future<Map<String, Student>> _getAllStudents({
    String? studentId,
    required DatabaseUser user,
  }) async {
    final students = await MySqlHelpers.performSelectQuery(
        connection: connection,
        user: user,
        tableName: 'students',
        filters: (studentId == null ? {} : {'id': studentId})
          ..addAll(user.accessLevel == AccessLevel.superAdmin
              ? {}
              : {'school_board_id': user.schoolBoardId ?? ''}),
        subqueries: [
          MySqlSelectSubQuery(
            dataTableName: 'persons',
            fieldsToFetch: [
              'first_name',
              'middle_name',
              'last_name',
              'date_birthday',
              'email'
            ],
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
          MySqlJoinSubQuery(
              dataTableName: 'persons',
              asName: 'contact',
              idNameToDataTable: 'contact_id',
              idNameToMainTable: 'student_id',
              relationTableName: 'student_contacts',
              fieldsToFetch: ['id']),
        ]);

    final map = <String, Student>{};
    for (final student in students) {
      final id = student['id'].toString();
      student['group'] = student['group_name'];

      final contactId =
          (student['contact'] as List?)?.map((e) => e['id']).firstOrNull;
      final contacts = contactId == null
          ? null
          : await MySqlHelpers.performSelectQuery(
              connection: connection,
              user: user,
              tableName: 'persons',
              filters: {
                  'id': contactId
                },
              subqueries: [
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
                      dataTableName: 'phone_numbers',
                      idNameToDataTable: 'entity_id',
                      fieldsToFetch: ['id', 'phone_number']),
                ]);
      student['contact'] = contacts?.firstOrNull ?? {};
      if (student['contact']['phone_numbers'] != null) {
        student['contact']['phone'] =
            (student['contact']['phone_numbers'] as List).first as Map;
      }
      if (student['contact']['addresses'] != null) {
        student['contact']['address'] =
            (student['contact']['addresses'] as List).firstOrNull as Map?;
      }

      student
          .addAll((student['persons'] as List).first as Map<String, dynamic>);
      student['date_birth'] = student['date_birthday'] == null
          ? null
          : DateTime.parse(student['date_birthday']).millisecondsSinceEpoch;

      student['phone'] =
          (student['phone_numbers'] as List?)?.firstOrNull as Map? ?? {};
      student['address'] =
          (student['addresses'] as List?)?.firstOrNull as Map? ?? {};

      map[id] = Student.fromSerialized(student);
    }
    return map;
  }

  @override
  Future<Student?> _getStudentById({
    required String id,
    required DatabaseUser user,
  }) async =>
      (await _getAllStudents(studentId: id, user: user))[id];

  Future<void> _insertToStudents(Student student) async {
    await MySqlHelpers.performInsertPerson(
        connection: connection, person: student);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'students',
        data: {
          'id': student.id.serialize(),
          'school_board_id': student.schoolBoardId.serialize(),
          'school_id': student.schoolId.serialize(),
          'version': Student.currentVersion.serialize(),
          'photo': student.photo.serialize(),
          'program': student.programSerialized,
          'group_name': student.group.serialize(),
          'contact_link': student.contactLink.serialize(),
        });
  }

  Future<void> _updateToStudents(
      Student student, Student previous, DatabaseUser user) async {
    final differences = student.getDifference(previous);

    if (differences.contains('school_board_id')) {
      _logger.severe('Cannot update school_board_id for the students');
      throw InvalidRequestException(
          'Cannot update school_board_id for the students');
    }
    if (differences.contains('school_id')) {
      if (user.accessLevel < AccessLevel.admin) {
        _logger.severe('Cannot update school_id for the students');
      } else {
        await MySqlHelpers.performUpdateQuery(
            connection: connection,
            tableName: 'students',
            filters: {'id': student.id},
            data: {'school_id': student.schoolId});
      }
    }

    // Update the persons table if needed
    await MySqlHelpers.performUpdatePerson(
        connection: connection, person: student, previous: previous);

    final toUpdate = <String, dynamic>{};
    if (student.photo != previous.photo) {
      toUpdate['photo'] = student.photo.serialize();
    }
    if (student.program != previous.program) {
      toUpdate['program'] = student.programSerialized;
    }
    if (student.group != previous.group) {
      toUpdate['group_name'] = student.group.serialize();
    }
    if (student.contactLink != previous.contactLink) {
      toUpdate['contact_link'] = student.contactLink.serialize();
    }
    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'students',
          filters: {'id': student.id},
          data: toUpdate);
    }
  }

  Future<void> _insertToContacts(Student student) async {
    await MySqlHelpers.performInsertPerson(
        connection: connection, person: student.contact);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'student_contacts',
        data: {'student_id': student.id, 'contact_id': student.contact.id});
  }

  Future<void> _updateToContacts({
    required Student student,
    required Student previous,
    required DatabaseUser user,
  }) async {
    final differences = student.getDifference(previous);
    if (differences.contains('contact')) {
      await MySqlHelpers.performUpdatePerson(
          connection: connection,
          person: student.contact,
          previous: previous.contact);
    }
  }

  @override
  Future<void> _putStudent({
    required Student student,
    required Student? previous,
    required DatabaseUser user,
  }) async {
    if (previous == null) {
      await _insertToStudents(student);
      await _insertToContacts(student);
    } else {
      await _updateToStudents(student, previous, user);
      await _updateToContacts(student: student, previous: previous, user: user);
    }
  }

  @override
  Future<String?> _deleteStudent({
    required String id,
    required DatabaseUser user,
  }) async {
    // Note: This will fail if the student was involved in an internship. The
    // data from the internship needs to be deleted first.
    try {
      final contacts = (await MySqlHelpers.performSelectQuery(
        connection: connection,
        user: user,
        tableName: 'student_contacts',
        filters: {'student_id': id},
      ));

      await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'student_contacts',
        filters: {'student_id': id},
      );

      for (final contact in contacts) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'entities',
          filters: {'shared_id': contact['contact_id']},
        );
      }

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
  // coverage:ignore-end
}

class StudentsRepositoryMock extends StudentsRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Student(
        id: '0',
        schoolBoardId: '0',
        schoolId: '0',
        firstName: 'John',
        middleName: null,
        lastName: 'Doe',
        phone: PhoneNumber.fromString('098-765-4321'),
        email: 'john.doe@email.com',
        dateBirth: null,
        address: Address.empty,
        program: Program.fms,
        group: 'A',
        contact: Person(
            id: '1',
            firstName: 'Jane',
            middleName: null,
            lastName: 'Doe',
            dateBirth: null,
            address: Address.empty,
            phone: PhoneNumber.fromString('123-456-7890'),
            email: 'jane.doe@quebec.qc'),
        contactLink: 'Mother'),
    '1': Student(
        id: '1',
        schoolBoardId: '0',
        schoolId: '0',
        firstName: 'Jane',
        middleName: null,
        lastName: 'Doe',
        phone: PhoneNumber.fromString('123-456-7890'),
        email: 'jane.doe@email.com',
        dateBirth: null,
        address: Address.empty,
        program: Program.fms,
        group: 'A',
        contact: Person(
            id: '0',
            firstName: 'John',
            middleName: null,
            lastName: 'Doe',
            dateBirth: null,
            address: Address.empty,
            phone: PhoneNumber.fromString('098-765-4321'),
            email: 'john.doe@quebec.qc'),
        contactLink: 'Father'),
  };

  @override
  Future<Map<String, Student>> _getAllStudents({
    required DatabaseUser user,
  }) async =>
      _dummyDatabase;

  @override
  Future<Student?> _getStudentById({
    required String id,
    required DatabaseUser user,
  }) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putStudent({
    required Student student,
    required Student? previous,
    required DatabaseUser user,
  }) async =>
      _dummyDatabase[student.id] = student;

  @override
  Future<String?> _deleteStudent({
    required String id,
    required DatabaseUser user,
  }) async {
    if (_dummyDatabase.containsKey(id)) {
      _dummyDatabase.remove(id);
      return id;
    }
    return null;
  }
}
