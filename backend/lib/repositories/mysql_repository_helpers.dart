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
    '''SELECT t.*${sublists == null || sublists.isEmpty ? '' : ','} 
      ${sublists?.map((e) => e._craft(mainTableName: tableName, tableElementAlias: 't')).join(',') ?? ''}
    FROM $tableName t
    ${elementId == null ? '' : 'WHERE t.id="$elementId"'}''';

abstract class MySqlTableAccessor {
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
  final String tableName;
  final List<String> fieldsToFetch;

  MySqlReferencedTable({
    required this.tableName,
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
        WHERE st.id = $tableElementAlias.id
      ) AS $tableName''';
  }
}

class MySqlTable implements MySqlTableAccessor {
  final String tableName;
  final List<String> fieldsToFetch;

  MySqlTable({
    required this.tableName,
    required this.fieldsToFetch,
  });

  @override
  String _craft(
      {required String mainTableName, required String tableElementAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'ml')}
            )
        )
        FROM $tableName ml
        WHERE ml.id = $tableElementAlias.id
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
