import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/database_user.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('SchoolBoardsRepository');

abstract class SchoolBoardsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified) {
      _logger.severe(
          'User ${user.userId} does not have permission to get school boards');
      throw InvalidRequestException(
          'You do not have permission to get school boards');
    }

    final schoolBoards = await _getAllSchoolBoards(user: user);
    return schoolBoards
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
          'User ${user.userId} does not have permission to get school boards');
      throw InvalidRequestException(
          'You do not have permission to get school boards');
    }

    final schoolBoard = await _getSchoolBoardById(id: id, user: user);
    if (schoolBoard == null) {
      throw MissingDataException('School board not found');
    }

    return schoolBoard.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({
    required Map<String, dynamic> data,
    required DatabaseUser user,
  }) async =>
      throw InvalidRequestException(
          'School boards must be created individually');

  @override
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified || user.accessLevel < AccessLevel.superAdmin) {
      _logger.severe(
          'User ${user.userId} does not have permission to put school boards');
      throw InvalidRequestException(
          'You do not have permission to put school boards');
    }

    // Update if exists, insert if not
    final previous = await _getSchoolBoardById(id: id, user: user);

    final newSchoolBoard = previous?.copyWithData(data) ??
        SchoolBoard.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    try {
      await _putSchoolBoard(
          schoolBoard: newSchoolBoard, previous: previous, user: user);
      return newSchoolBoard.getDifference(previous);
    } catch (e) {
      _logger.severe('Error while putting school board: $e');
      return [];
    }
  }

  @override
  Future<List<String>> deleteAll({
    required DatabaseUser user,
  }) async {
    throw InvalidRequestException('School boards must be deleted individually');
  }

  @override
  Future<String> deleteById({
    required String id,
    required DatabaseUser user,
  }) async {
    if (user.isNotVerified || user.accessLevel < AccessLevel.superAdmin) {
      _logger.severe(
          'User ${user.userId} does not have permission to delete school boards');
      throw InvalidRequestException(
          'You do not have permission to delete school boards');
    }

    final removedId = await _deleteSchoolBoard(id: id, user: user);
    if (removedId == null) {
      throw DatabaseFailureException(
          'Failed to delete school board with id: $id');
    }
    return removedId;
  }

  Future<Map<String, SchoolBoard>> _getAllSchoolBoards({
    required DatabaseUser user,
  });

  Future<SchoolBoard?> _getSchoolBoardById({
    required String id,
    required DatabaseUser user,
  });

  Future<void> _putSchoolBoard({
    required SchoolBoard schoolBoard,
    required SchoolBoard? previous,
    required DatabaseUser user,
  });

  Future<String?> _deleteSchoolBoard({
    required String id,
    required DatabaseUser user,
  });
}

class MySqlSchoolBoardsRepository extends SchoolBoardsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlSchoolBoardsRepository({required this.connection});

  @override
  Future<Map<String, SchoolBoard>> _getAllSchoolBoards({
    String? schoolBoardId,
    required DatabaseUser user,
  }) async {
    if (user.accessLevel < AccessLevel.superAdmin) {
      // Only super admins can access all school boards
      schoolBoardId ??= user.schoolBoardId;
      if (schoolBoardId != user.schoolBoardId) {
        throw InvalidRequestException(
            'You must be a super admin to access the requested school board');
      }
    }

    final schoolBoards = await MySqlHelpers.performSelectQuery(
      connection: connection,
      user: user,
      tableName: 'school_boards',
      filters: schoolBoardId == null ? null : {'id': schoolBoardId},
    );

    final map = <String, SchoolBoard>{};
    for (final schoolBoard in schoolBoards) {
      final id = schoolBoard['id'].toString();

      final schools = await MySqlHelpers.performSelectQuery(
        connection: connection,
        user: user,
        tableName: 'schools',
        filters: {'school_board_id': id},
      );

      for (final school in schools) {
        final schoolId = school['id'].toString();
        final address = await MySqlHelpers.performSelectQuery(
          connection: connection,
          user: user,
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
  Future<SchoolBoard?> _getSchoolBoardById({
    required String id,
    required DatabaseUser user,
  }) async =>
      (await _getAllSchoolBoards(schoolBoardId: id, user: user))[id];

  Future<void> _insertToSchoolBoards(SchoolBoard schoolBoard,
      {required DatabaseUser user}) async {
    if (user.accessLevel < AccessLevel.superAdmin) {
      throw InvalidRequestException(
          'You must be a super admin to create a school board');
    }

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
    SchoolBoard schoolBoard,
    SchoolBoard previous, {
    required DatabaseUser user,
  }) async {
    final toUpdate = schoolBoard.getDifference(previous);
    if (toUpdate.isNotEmpty && user.accessLevel < AccessLevel.superAdmin) {
      throw InvalidRequestException(
          'You must be a super admin to update a school board');
    }

    if (toUpdate.contains('name')) {
      await MySqlHelpers.performUpdateQuery(
        connection: connection,
        tableName: 'school_boards',
        filters: {'id': schoolBoard.id},
        data: {'name': schoolBoard.name},
      );
    }
  }

  Future<void> _insertToSchools(School school, SchoolBoard schoolBoard,
      {required DatabaseUser user}) async {
    if (user.accessLevel < AccessLevel.admin) {
      throw InvalidRequestException('You must be a admin to create a school');
    }

    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'entities',
        data: {'shared_id': school.id});
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'schools',
        data: {
          'id': school.id.serialize(),
          'school_board_id': schoolBoard.id.serialize(),
          'name': school.name.serialize(),
        });

    await MySqlHelpers.performInsertAddress(
        connection: connection, address: school.address, entityId: school.id);
  }

  Future<void> _updateToSchools(School school, School previous,
      {required DatabaseUser user}) async {
    final toUpdate = school.getDifference(previous);
    if (toUpdate.isNotEmpty && user.accessLevel < AccessLevel.admin) {
      throw InvalidRequestException('You must be a admin to update a school');
    }

    if (toUpdate.contains('name')) {
      await MySqlHelpers.performUpdateQuery(
        connection: connection,
        tableName: 'schools',
        filters: {'id': school.id.serialize()},
        data: {'name': school.name.serialize()},
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
    required DatabaseUser user,
  }) async {
    if (previous == null) {
      await _insertToSchoolBoards(schoolBoard, user: user);
    } else {
      await _updateToSchoolBoards(schoolBoard, previous, user: user);
    }

    // Insert the schools
    final toWait = <Future>[];
    for (final school in schoolBoard.schools) {
      final previousSchool =
          previous?.schools.firstWhereOrNull((e) => e.id == school.id);
      if (previousSchool == null) {
        toWait.add(_insertToSchools(school, schoolBoard, user: user));
      } else {
        toWait.add(_updateToSchools(school, previousSchool, user: user));
      }
    }

    // Remove the schools that are not in the new list
    for (final school in previous?.schools ?? <School>[]) {
      if (!schoolBoard.schools.any((e) => e.id == school.id)) {
        toWait.add(_deleteFromSchools(school.id, user: user));
      }
    }

    await Future.wait(toWait);
  }

  Future<void> _deleteFromSchools(String schoolId,
      {required DatabaseUser user}) async {
    if (user.accessLevel < AccessLevel.superAdmin) {
      throw InvalidRequestException(
          'You must be a super admin to delete a school');
    }

    _logger.warning(
        'The school with id: $schoolId is being deleted by user: ${user.userId}');
    await MySqlHelpers.performDeleteQuery(
      connection: connection,
      tableName: 'entities',
      filters: {'shared_id': schoolId},
    );
  }

  @override
  Future<String?> _deleteSchoolBoard({
    required String id,
    required DatabaseUser user,
  }) async {
    if (user.accessLevel < AccessLevel.superAdmin) {
      throw InvalidRequestException(
          'You must be a super admin to delete a school board');
    }

    try {
      final schools = await MySqlHelpers.performSelectQuery(
        connection: connection,
        user: user,
        tableName: 'schools',
        filters: {'school_board_id': id},
      );
      for (final school in schools) {
        await _deleteFromSchools(school['id'].toString(), user: user);
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
  Future<Map<String, SchoolBoard>> _getAllSchoolBoards({
    required DatabaseUser user,
  }) async =>
      _dummyDatabase;

  @override
  Future<SchoolBoard?> _getSchoolBoardById({
    required String id,
    required DatabaseUser user,
  }) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putSchoolBoard({
    required SchoolBoard schoolBoard,
    required SchoolBoard? previous,
    required DatabaseUser user,
  }) async =>
      _dummyDatabase[schoolBoard.id] = schoolBoard;

  @override
  Future<String?> _deleteSchoolBoard({
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
