import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:mysql1/mysql1.dart';

abstract class SchoolBoardsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required String schoolBoardId,
  }) async {
    final schoolBoards = await _getAllSchoolBoards();
    return schoolBoards
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById({
    required String id,
    List<String>? fields,
    required String schoolBoardId,
  }) async {
    final schoolBoard = await _getSchoolBoardById(id: id);
    if (schoolBoard == null) {
      throw MissingDataException('School board not found');
    }

    return schoolBoard.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({
    required Map<String, dynamic> data,
    required String schoolBoardId,
  }) async =>
      throw InvalidRequestException(
          'School boards must be created individually');

  @override
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required String schoolBoardId,
  }) async {
    // Update if exists, insert if not
    final previous = await _getSchoolBoardById(id: id);

    final newSchoolBoard = previous?.copyWithData(data) ??
        SchoolBoard.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putSchoolBoard(schoolBoard: newSchoolBoard, previous: previous);
    return newSchoolBoard.getDifference(previous);
  }

  @override
  Future<List<String>> deleteAll({
    required String schoolBoardId,
  }) async {
    throw InvalidRequestException('School boards must be deleted individually');
  }

  @override
  Future<String> deleteById({
    required String id,
    required String schoolBoardId,
  }) async {
    final removedId = await _deleteSchoolBoard(id: id);
    if (removedId == null) throw MissingDataException('School board not found');
    return removedId;
  }

  Future<Map<String, SchoolBoard>> _getAllSchoolBoards();

  Future<SchoolBoard?> _getSchoolBoardById({required String id});

  Future<void> _putSchoolBoard(
      {required SchoolBoard schoolBoard, required SchoolBoard? previous});

  Future<String?> _deleteSchoolBoard({required String id});
}

class MySqlSchoolBoardsRepository extends SchoolBoardsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlSchoolBoardsRepository({required this.connection});

  @override
  Future<Map<String, SchoolBoard>> _getAllSchoolBoards(
      {String? schoolBoardId}) async {
    final schoolBoards = await MySqlHelpers.performSelectQuery(
      connection: connection,
      tableName: 'school_boards',
      filters: schoolBoardId == null ? null : {'id': schoolBoardId},
    );

    final map = <String, SchoolBoard>{};
    for (final schoolBoard in schoolBoards) {
      final id = schoolBoard['id'].toString();

      final schools = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'schools',
        filters: {'school_board_id': id},
      );

      for (final school in schools) {
        final schoolId = school['id'].toString();
        final address = await MySqlHelpers.performSelectQuery(
          connection: connection,
          tableName: 'addresses',
          filters: {'entity_id': schoolId},
        );
        school['address'] = address.first;
      }
      schoolBoard['schools'] = schools;

      map[id] = SchoolBoard.fromSerialized(schoolBoard);
    }
    return map;
  }

  @override
  Future<SchoolBoard?> _getSchoolBoardById({required String id}) async =>
      (await _getAllSchoolBoards(schoolBoardId: id))[id];

  Future<void> _insertToSchoolBoards(SchoolBoard schoolBoard) async {
    // Insert the school board
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'entities',
        data: {'shared_id': schoolBoard.id});
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'school_boards',
        data: {'id': schoolBoard.id, 'name': schoolBoard.name});
  }

  Future<void> _updateToSchoolBoards(
      SchoolBoard schoolBoard, SchoolBoard previous) async {
    final toUpdate = schoolBoard.getDifference(previous);

    if (toUpdate.contains('name')) {
      await MySqlHelpers.performUpdateQuery(
        connection: connection,
        tableName: 'school_boards',
        filters: {'id': schoolBoard.id},
        data: {'name': schoolBoard.name},
      );
    }
  }

  Future<void> _insertToSchools(School school, SchoolBoard schoolBoard) async {
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'entities',
        data: {'shared_id': school.id});
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'schools',
        data: {
          'id': school.id,
          'school_board_id': schoolBoard.id,
          'name': school.name,
        });

    await MySqlHelpers.performInsertAddress(
        connection: connection, address: school.address, entityId: school.id);
  }

  Future<void> _updateToSchools(School school, School previous) async {
    final toUpdate = school.getDifference(previous);

    if (toUpdate.contains('name')) {
      await MySqlHelpers.performUpdateQuery(
        connection: connection,
        tableName: 'schools',
        filters: {'id': school.id},
        data: {'name': school.name},
      );
    }
    if (toUpdate.contains('address')) {
      await MySqlHelpers.performUpdateAddress(
        connection: connection,
        address: school.address,
        previous: previous.address,
      );
    }
  }

  @override
  Future<void> _putSchoolBoard({
    required SchoolBoard schoolBoard,
    required SchoolBoard? previous,
  }) async {
    if (previous == null) {
      _insertToSchoolBoards(schoolBoard);
    } else {
      _updateToSchoolBoards(schoolBoard, previous);
    }

    // Insert the schools
    final toWait = <Future>[];
    for (final school in schoolBoard.schools) {
      final previousSchool =
          previous?.schools.firstWhereOrNull((e) => e.id == school.id);
      if (previousSchool == null) {
        toWait.add(_insertToSchools(school, schoolBoard));
      } else {
        toWait.add(_updateToSchools(school, previousSchool));
      }
    }
    await Future.wait(toWait);
  }

  @override
  Future<String?> _deleteSchoolBoard({required String id}) async {
    try {
      final schools = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'schools',
        filters: {'school_board_id': id},
      );
      for (final school in schools) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'entities',
          filters: {'shared_id': school['id']},
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
}

class SchoolBoardsRepositoryMock extends SchoolBoardsRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': SchoolBoard(id: '0', name: 'This one', schools: []),
    '1': SchoolBoard(id: '1', name: 'This second', schools: []),
  };

  @override
  Future<Map<String, SchoolBoard>> _getAllSchoolBoards() async =>
      _dummyDatabase;

  @override
  Future<SchoolBoard?> _getSchoolBoardById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putSchoolBoard(
          {required SchoolBoard schoolBoard,
          required SchoolBoard? previous}) async =>
      _dummyDatabase[schoolBoard.id] = schoolBoard;

  @override
  Future<String?> _deleteSchoolBoard({required String id}) async {
    if (_dummyDatabase.containsKey(id)) {
      _dummyDatabase.remove(id);
      return id;
    }
    return null;
  }
}
