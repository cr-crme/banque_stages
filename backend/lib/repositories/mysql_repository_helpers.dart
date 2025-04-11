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
Future<Results> performSelectQuery({
  required MySqlConnection connection,
  required String tableName,
  String? elementId,
  List<MySqlTableAccessor>? sublists,
}) async =>
    await tryQuery(
        connection,
        craftSelectQuery(
            tableName: tableName, elementId: elementId, sublists: sublists));
// coverage:ignore-end

String craftSelectQuery({
  required String tableName,
  String? elementId,
  List<MySqlTableAccessor>? sublists,
}) =>
    '''SELECT t.*, 
      ${sublists?.map((e) => e._craft(tableElementAlias: 't')).join(',') ?? ''}
    FROM $tableName t
    ${elementId == null ? '' : 'WHERE t.id="$elementId"'}''';

abstract class MySqlTableAccessor {
  String _craft({required String tableElementAlias});

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

class MySqlNormalizedTable implements MySqlTableAccessor {
  final String mainTableName;
  final String subtableName;
  final List<String> fieldsToFetch;
  final String tableId;
  final String subTableId;
  final String foreignId;

  MySqlNormalizedTable({
    required this.mainTableName,
    required this.subtableName,
    required this.fieldsToFetch,
    required this.tableId,
    required this.subTableId,
    required this.foreignId,
  });

  @override
  String _craft({required String tableElementAlias}) {
    return '''(
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'mt')}
            )
        )
        FROM $subtableName st
        JOIN $mainTableName mt ON mt.$tableId = st.$subTableId
        WHERE st.$foreignId = $tableElementAlias.$tableId
      ) AS $mainTableName''';
  }
}

class MySqlTable implements MySqlTableAccessor {
  final String tableName;
  final List<String> fieldsToFetch;
  final String tableId;

  MySqlTable({
    required this.tableName,
    required this.fieldsToFetch,
    required this.tableId,
  });

  @override
  String _craft({required String tableElementAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'ml')}
            )
        )
        FROM $tableName ml
        WHERE ml.$tableId = $tableElementAlias.id
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

Future<void> performInsertNormalizedQuery({
  required MySqlConnection connection,
  required String tableName,
  required Map<String, dynamic> data,
  required String normalizedTableName,
  required Map<String, dynamic> normalizedKeys,
}) async {
  await tryQuery(connection, craftInsertQuery(tableName: tableName, data: data),
      [...data.values]);

  await tryQuery(
      connection,
      craftInsertQuery(tableName: normalizedTableName, data: normalizedKeys),
      [...normalizedKeys.values]);
}
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
  required MapEntry<String, String> id,
  required Map<String, dynamic> data,
}) async =>
    await tryQuery(
        connection,
        craftUpdateQuery(tableName: tableName, id: id, data: data),
        [...data.values, id.value]);
// coverage:ignore-end

String craftUpdateQuery({
  required String tableName,
  required MapEntry<String, String> id,
  required Map<String, dynamic> data,
}) =>
    '''UPDATE $tableName SET ${data.keys.join(' = ?, ')} = ?
       WHERE ${id.key} = ?''';

// coverage:ignore-start
Future<Results> performDeleteQuery({
  required MySqlConnection connection,
  required String tableName,
  required MapEntry<String, String> id,
}) async =>
    await tryQuery(
        connection, craftDeleteQuery(tableName: tableName, id: id), [id.value]);
// coverage:ignore-end

String craftDeleteQuery({
  required String tableName,
  required MapEntry<String, String> id,
}) =>
    '''DELETE FROM $tableName WHERE ${id.key} = ?''';
