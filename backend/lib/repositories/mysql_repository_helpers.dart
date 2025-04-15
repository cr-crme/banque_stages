import 'dart:convert';

import 'package:backend/utils/exceptions.dart';
import 'package:mysql1/mysql1.dart';

// coverage:ignore-start
Future<Results> tryQuery(MySqlConnection connection, String query,
    [List<Object?>? values]) async {
  try {
    return await connection.query(query, values);
  } on MySqlException catch (e) {
    throw DatabaseFailureException(
        'Database failure: ${e.message} (${e.errorNumber}). '
        'This should not happen, please contact the administrator of the database.');
  } catch (e) {
    throw DatabaseFailureException('Database failure: $e. '
        'This should not happen, please contact the administrator of the database.');
  }
}
// coverage:ignore-end

// coverage:ignore-start
Future<List<Map<String, dynamic>>> performSelectQuery({
  required MySqlConnection connection,
  required String tableName,
  String idName = 'id',
  String? id,
  List<MySqlTableAccessor>? sublists,
}) async {
  final results = await tryQuery(
      connection,
      craftSelectQuery(
          tableName: tableName, idName: idName, id: id, sublists: sublists));

  final List<Map<String, dynamic>> list = [];
  for (final row in results) {
    final Map<String, dynamic> map = row.fields;
    if (sublists == null || sublists.isEmpty) {
      list.add(map);
      continue;
    }
    for (final sublist in sublists) {
      final tableRow = map[sublist.tableName];
      if (tableRow == null) continue;
      map[sublist.tableName] = jsonDecode(tableRow);
    }
    list.add(map);
  }

  return list;
}
// coverage:ignore-end

String craftSelectQuery({
  required String tableName,
  String idName = 'id',
  String? id,
  List<MySqlTableAccessor>? sublists,
}) =>
    '''SELECT t.*${sublists == null || sublists.isEmpty ? '' : ','} 
      ${sublists?.map((e) => e._craft(mainTableName: tableName, tableElementAlias: 't')).join(',') ?? ''}
    FROM $tableName t
    ${id == null ? '' : 'WHERE t.$idName = "$id"'}''';

abstract class MySqlTableAccessor {
  String get tableName;
  String get tableIdName;

  String _craft(
      {required String mainTableName, required String tableElementAlias});

  static String _dispatchFieldsToFetch(
      {required List<String> fieldsToFetch,
      required String tableElementAlias}) {
    if (fieldsToFetch.isEmpty) throw 'Fields cannot be empty';

    String fieldsInMainList = '';
    for (final field in fieldsToFetch) {
      fieldsInMainList += '\'$field\', $tableElementAlias.$field, ';
    }
    fieldsInMainList =
        fieldsInMainList.substring(0, fieldsInMainList.length - 2);

    return fieldsInMainList;
  }
}

class MySqlReferencedTable implements MySqlTableAccessor {
  @override
  final String tableName;
  final String referenceIdName;
  @override
  final String tableIdName;
  final List<String> fieldsToFetch;

  MySqlReferencedTable({
    required this.tableName,
    this.referenceIdName = 'id',
    this.tableIdName = 'id',
    List<String>? fieldsToFetch,
  }) : fieldsToFetch = fieldsToFetch ?? ['*'];

  @override
  String _craft(
      {required String mainTableName, required String tableElementAlias}) {
    return '''(
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'st')}
            )
        )
        FROM $tableName st
        WHERE st.$referenceIdName = $tableElementAlias.$tableIdName
      ) AS $tableName''';
  }
}

class MySqlTable implements MySqlTableAccessor {
  @override
  final String tableName;
  final String referenceIdName;
  @override
  final String tableIdName;
  final List<String> fieldsToFetch;

  MySqlTable({
    required this.tableName,
    this.referenceIdName = 'id',
    this.tableIdName = 'id',
    required this.fieldsToFetch,
  });

  @override
  String _craft(
      {required String mainTableName, required String tableElementAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'sl')}
            )
        )
        FROM $tableName sl
        WHERE sl.$tableIdName = $tableElementAlias.$referenceIdName
      ), JSON_ARRAY()) AS $tableName''';
  }
}

// coverage:ignore-start
Future<Results> performInsertQuery({
  required MySqlConnection connection,
  required String tableName,
  required Map<String, dynamic> data,
}) async =>
    await tryQuery(connection,
        craftInsertQuery(tableName: tableName, data: data), [...data.values]);
// coverage:ignore-end

String craftInsertQuery({
  required String tableName,
  required Map<String, dynamic> data,
}) =>
    '''INSERT INTO $tableName (${data.keys.join(', ')})
       VALUES (${data.keys.map((e) => '?').join(', ')})''';

// coverage:ignore-start
Future<Results> performUpdateQuery({
  required MySqlConnection connection,
  required String tableName,
  String idName = 'id',
  required String id,
  required Map<String, dynamic> data,
}) async =>
    await tryQuery(
        connection,
        craftUpdateQuery(tableName: tableName, idName: idName, data: data),
        [...data.values, id]);
// coverage:ignore-end

String craftUpdateQuery({
  required String tableName,
  required String idName,
  required Map<String, dynamic> data,
}) =>
    '''UPDATE $tableName SET ${data.keys.join(' = ?, ')} = ?
       WHERE $idName = ?''';

// coverage:ignore-start
Future<Results> performDeleteQuery({
  required MySqlConnection connection,
  required String tableName,
  String idName = 'id',
  required String id,
}) async =>
    await tryQuery(connection,
        craftDeleteQuery(tableName: tableName, idName: idName), [id]);
// coverage:ignore-end

String craftDeleteQuery({
  required String tableName,
  String idName = 'id',
}) =>
    '''DELETE FROM $tableName WHERE $idName = ?''';
