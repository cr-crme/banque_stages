import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/utils.dart';
import 'package:mysql1/mysql1.dart';

abstract class StudentsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({List<String>? fields}) async {
    final students = await _getAllStudents();
    return students
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById(
      {required String id, List<String>? fields}) async {
    final student = await _getStudentById(id: id);
    if (student == null) throw MissingDataException('Student not found');

    return student.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Students must be created individually');

  @override
  Future<List<String>> putById(
      {required String id, required Map<String, dynamic> data}) async {
    // Update if exists, insert if not
    final previous = await _getStudentById(id: id);

    final newStudent = previous?.copyWithData(data) ??
        Student.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putStudent(student: newStudent, previous: previous);
    return newStudent.getDifference(previous);
  }

  @override
  Future<List<String>> deleteAll() async {
    throw InvalidRequestException('Students must be deleted individually');
  }

  @override
  Future<String> deleteById({required String id}) async {
    final removedId = await _deleteStudent(id: id);
    if (removedId == null) throw MissingDataException('Student not found');
    return removedId;
  }

  Future<Map<String, Student>> _getAllStudents();

  Future<Student?> _getStudentById({required String id});

  Future<void> _putStudent(
      {required Student student, required Student? previous});

  Future<String?> _deleteStudent({required String id});
}

class MySqlStudentsRepository extends StudentsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlStudentsRepository({required this.connection});

  @override
  Future<Map<String, Student>> _getAllStudents({String? studentId}) async {
    final students = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'students',
        id: studentId,
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
              tableName: 'persons',
              id: contactId,
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
                ]);
      student['contact'] = contacts?.firstOrNull ?? {};

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
  Future<Student?> _getStudentById({required String id}) async =>
      (await _getAllStudents(studentId: id))[id];

  @override
  Future<void> _putStudent(
          {required Student student, required Student? previous}) async =>
      previous == null
          ? await _putNewStudent(student)
          : await _putExistingStudent(student, previous);

  Future<void> _putNewStudent(Student student) async {
    try {
      final serialized = student.serialize();

      // Insert the student
      await MySqlHelpers.performInsertPerson(
          connection: connection, person: student);
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'students',
          data: {
            'id': serialized['id'],
            'version': serialized['version'],
            'photo': serialized['photo'],
            'program': serialized['program'],
            'group_name': serialized['group'],
            'contact_link': serialized['contact_link'],
          });

      // Insert the contact
      await MySqlHelpers.performInsertPerson(
          connection: connection, person: student.contact);
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'student_contacts',
          data: {'student_id': student.id, 'contact_id': student.contact.id});
    } catch (e) {
      try {
        // Try to delete the inserted data in case of error
        await _deleteStudent(id: student.id);
      } catch (e) {
        // Do nothing
      }
      rethrow;
    }
  }

  Future<void> _putExistingStudent(Student student, Student previous) async {
    // Update the persons table if needed
    await MySqlHelpers.performUpdatePerson(
        connection: connection, person: student, previous: previous);

    // Update the students table if needed
    final toUpdate = <String, dynamic>{};
    if (student.photo != previous.photo) {
      toUpdate['photo'] = student.photo;
    }
    if (student.program != previous.program) {
      toUpdate['program'] = student.program;
    }
    if (student.group != previous.group) {
      toUpdate['group_name'] = student.group;
    }
    if (student.contactLink != previous.contactLink) {
      toUpdate['contact_link'] = student.contactLink;
    }
    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'students',
          id: student.id,
          data: toUpdate);
    }

    // Update student contact if needed
    if (student.contact != previous.contact) {
      await MySqlHelpers.performUpdatePerson(
          connection: connection,
          person: student.contact,
          previous: previous.contact);
    }
  }

  @override
  Future<String?> _deleteStudent({required String id}) async {
    // Note: This will fail if the student was involved in an internship. The
    // data from the internship needs to be deleted first.
    try {
      final contacts = (await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'student_contacts',
        idName: 'student_id',
        id: id,
      ));

      await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'student_contacts',
          idName: 'student_id',
          id: id);

      for (final contact in contacts) {
        await MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'entities',
            idName: 'shared_id',
            id: contact['contact_id']);
      }

      await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'entities',
          idName: 'shared_id',
          id: id);
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
  Future<Map<String, Student>> _getAllStudents() async => _dummyDatabase;

  @override
  Future<Student?> _getStudentById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putStudent(
          {required Student student, required Student? previous}) async =>
      _dummyDatabase[student.id] = student;

  @override
  Future<String?> _deleteStudent({required String id}) async {
    if (_dummyDatabase.containsKey(id)) {
      _dummyDatabase.remove(id);
      return id;
    }
    return null;
  }
}
