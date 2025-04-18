import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/internships/internship.dart';
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
        subqueries: []);

    final map = <String, Internship>{};
    for (final internship in internships) {
      final id = internship['id'].toString();

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
          });
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
    '0': Internship(id: '0', studentId: '12345'),
    '1': Internship(id: '1', studentId: '54321'),
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
