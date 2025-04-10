import 'package:backend/exceptions.dart';
import 'package:mysql1/mysql1.dart';

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

String craftQuery({
  required String tableName,
  String? id,
  List<MySqlTableAccessor>? sublists,
}) {
  String query = '''
    SELECT t.*, 
      ${sublists?.map((e) => e._craft(tableElementAlias: 't')).join(',') ?? ''}
    FROM $tableName t
    ${id == null ? '' : 'WHERE t.id="$id"'}''';

  return query;
}

abstract class MySqlTableAccessor {
  String _craft({required String tableElementAlias});
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
    if (fieldsToFetch.isEmpty) throw 'Fields cannot be empty';

    String fieldsInMainList = '';
    for (final field in fieldsToFetch) {
      fieldsInMainList += '\'$field\', mt.$field,';
    }
    fieldsInMainList =
        fieldsInMainList.substring(0, fieldsInMainList.length - 1);

    return '''(
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              $fieldsInMainList
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
    if (fieldsToFetch.isEmpty) throw 'Fields cannot be empty';

    String fieldsInMainList = '';
    for (final field in fieldsToFetch) {
      fieldsInMainList += '\'$field\', ml.$field,';
    }
    fieldsInMainList =
        fieldsInMainList.substring(0, fieldsInMainList.length - 1);

    return '''
      IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              $fieldsInMainList
            )
        )
        FROM $tableName ml
        WHERE ml.$tableId = $tableElementAlias.id
      ), JSON_ARRAY()) AS $tableName''';
  }
}
