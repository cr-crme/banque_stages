import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/utils.dart';
import 'package:mysql1/mysql1.dart';

abstract class InternshipsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll() async {
    final internships = await _getAllInternships();
    return internships.map((key, value) => MapEntry(key, value.serialize()));
  }

  @override
  Future<Map<String, dynamic>> getById({required String id}) async {
    final internship = await _getInternshipById(id: id);
    if (internship == null) throw MissingDataException('Internship not found');

    return internship.serialize();
  }

  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Internships must be created individually');

  @override
  Future<void> putById(
      {required String id, required Map<String, dynamic> data}) async {
    // Update if exists, insert if not
    final previous = await _getInternshipById(id: id);

    final newInternship = previous?.copyWithData(data) ??
        Internship.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putInternship(internship: newInternship, previous: previous);
  }

  Future<Map<String, Internship>> _getAllInternships();

  Future<Internship?> _getInternshipById({required String id});

  Future<void> _putInternship(
      {required Internship internship, required Internship? previous});
}

class MySqlInternshipsRepository extends InternshipsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlInternshipsRepository({required this.connection});

  @override
  Future<Map<String, Internship>> _getAllInternships(
      {String? internshipId}) async {
    final internships = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'internships',
        id: internshipId,
        subqueries: [
          MySqlSelectSubQuery(
            dataTableName: 'internships_supervising_teachers',
            asName: 'supervising_teachers',
            fieldsToFetch: ['teacher_id', 'is_signatory_teacher'],
            idNameToDataTable: 'internship_id',
          ),
          MySqlSelectSubQuery(
            dataTableName: 'internships_extra_specializations',
            asName: 'extra_specializations',
            fieldsToFetch: ['specialization_id'],
            idNameToDataTable: 'internship_id',
          ),
        ]);

    final map = <String, Internship>{};
    for (final internship in internships) {
      final id = internship['id'].toString();

      internship['signatory_teacher_id'] =
          (internship['supervising_teachers'] as List?)?.firstWhereOrNull(
              (e) => e['is_signatory_teacher'] as int == 1)?['teacher_id'];
      if (internship['signatory_teacher_id'] == null) {
        throw MissingDataException('Internship $id has no signatory teacher');
      }
      internship['extra_supervising_teacher_ids'] =
          (internship['supervising_teachers'] as List?)
                  ?.map((e) => e['teacher_id'].toString())
                  .toList() ??
              [];

      internship['extra_specialization_ids'] =
          (internship['extra_specializations'] as List?)
                  ?.map((e) => e['specialization_id'].toString())
                  .toList() ??
              [];

      map[id] = Internship.fromSerialized(internship);
    }
    return map;
  }

  @override
  Future<Internship?> _getInternshipById({required String id}) async =>
      (await _getAllInternships(internshipId: id))[id];

  @override
  Future<void> _putInternship(
          {required Internship internship,
          required Internship? previous}) async =>
      previous == null
          ? await _putNewInternship(internship)
          : await _putExistingInternship(internship, previous);

  Future<void> _putNewInternship(Internship internship) async {
    try {
      // Insert the internship
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'internships',
          data: {
            'id': internship.id,
            'student_id': internship.studentId,
            'enterprise_id': internship.enterpriseId,
            'job_id': internship.jobId,
            'expected_duration': internship.expectedDuration,
          });

      // Insert the signatory teacher
      for (final teacherId in internship.supervisingTeacherIds) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internships_supervising_teachers',
            data: {
              'internship_id': internship.id,
              'teacher_id': teacherId,
              'is_signatory_teacher': teacherId == internship.signatoryTeacherId
            });

        // Insert the extra specializations
        for (final specializationId in internship.extraSpecializationIds) {
          await MySqlHelpers.performInsertQuery(
              connection: connection,
              tableName: 'internships_extra_specializations',
              data: {
                'internship_id': internship.id,
                'specialization_id': specializationId
              });
        }
      }
    } catch (e) {
      try {
        // Try to delete the inserted data in case of error (everything is ON CASCADE DELETE)
        await MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'internships',
            id: internship.id);
      } catch (e) {
        // Do nothing
      }
      rethrow;
    }
  }

  Future<void> _putExistingInternship(
      Internship internship, Internship previous) async {
    if (internship != previous) {
      // TODO: Implement updating enterprise
      throw 'Not implemented yet';
    }
  }
}

class InternshipsRepositoryMock extends InternshipsRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Internship(
        id: '0',
        studentId: '12345',
        signatoryTeacherId: '67890',
        extraSupervisingTeacherIds: [],
        enterpriseId: '12345',
        jobId: '67890',
        extraSpecializationIds: ['12345'],
        expectedDuration: 10),
    '1': Internship(
        id: '1',
        studentId: '54321',
        signatoryTeacherId: '09876',
        extraSupervisingTeacherIds: ['54321'],
        enterpriseId: '54321',
        jobId: '09876',
        extraSpecializationIds: ['54321', '09876'],
        expectedDuration: 20),
  };

  @override
  Future<Map<String, Internship>> _getAllInternships() async => _dummyDatabase;

  @override
  Future<Internship?> _getInternshipById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putInternship(
          {required Internship internship,
          required Internship? previous}) async =>
      _dummyDatabase[internship.id] = internship;
}
