import 'dart:convert';

import 'package:backend/utils/exceptions.dart';
import 'package:common/models/address.dart';
import 'package:common/models/person.dart';
import 'package:common/models/phone_number.dart';
import 'package:mysql1/mysql1.dart';

class MySqlHelpers {
// coverage:ignore-start
  static Future<Results> tryQuery(MySqlConnection connection, String query,
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
  static Future<List<Map<String, dynamic>>> performSelectQuery({
    required MySqlConnection connection,
    required String tableName,
    String idName = 'id',
    String? id,
    List<MySqlTableAccessor>? subqueries,
  }) async {
    final results = await tryQuery(
        connection,
        MySqlHelpers.craftSelectQuery(
            tableName: tableName,
            idName: idName,
            id: id,
            sublists: subqueries));

    final List<Map<String, dynamic>> list = [];
    for (final row in results) {
      final Map<String, dynamic> map = row.fields;
      if (subqueries == null || subqueries.isEmpty) {
        list.add(map);
        continue;
      }
      for (final sublist in subqueries) {
        final tableRow = map[sublist.tableName];
        if (tableRow == null) continue;
        map[sublist.tableName] = jsonDecode(tableRow);
      }
      list.add(map);
    }

    return list;
  }
// coverage:ignore-end

  static String craftSelectQuery({
    required String tableName,
    String idName = 'id',
    String? id,
    List<MySqlTableAccessor>? sublists,
  }) =>
      '''SELECT t.*${sublists == null || sublists.isEmpty ? '' : ','} 
      ${sublists?.map((e) => e._craft(mainTableAlias: 't')).join(',') ?? ''}
    FROM $tableName t
    ${id == null ? '' : 'WHERE t.$idName = "$id"'}''';

// coverage:ignore-start
  static Future<Results> performInsertQuery({
    required MySqlConnection connection,
    required String tableName,
    required Map<String, dynamic> data,
  }) async =>
      await tryQuery(connection,
          craftInsertQuery(tableName: tableName, data: data), [...data.values]);
// coverage:ignore-end

  static String craftInsertQuery({
    required String tableName,
    required Map<String, dynamic> data,
  }) =>
      '''INSERT INTO $tableName (${data.keys.join(', ')})
       VALUES (${data.keys.map((e) => '?').join(', ')})''';

// coverage:ignore-start
  static Future<Results> performUpdateQuery({
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

  static String craftUpdateQuery({
    required String tableName,
    required String idName,
    required Map<String, dynamic> data,
  }) =>
      '''UPDATE $tableName SET ${data.keys.join(' = ?, ')} = ?
       WHERE $idName = ?''';

// coverage:ignore-start
  static Future<Results> performDeleteQuery({
    required MySqlConnection connection,
    required String tableName,
    String idName = 'id',
    required String id,
  }) async =>
      await tryQuery(connection,
          craftDeleteQuery(tableName: tableName, idName: idName), [id]);
// coverage:ignore-end

  static String craftDeleteQuery({
    required String tableName,
    String idName = 'id',
  }) =>
      '''DELETE FROM $tableName WHERE $idName = ?''';

// coverage:ignore-start
  ///
  /// Specific helpers
  static Future<void> performInsertPerson(
      {required MySqlConnection connection, required Person person}) async {
    await performInsertQuery(
        connection: connection,
        tableName: 'entities',
        data: {'shared_id': person.id});
    await performInsertQuery(
        connection: connection,
        tableName: 'persons',
        data: {
          'id': person.id,
          'first_name': person.firstName,
          'middle_name': person.middleName,
          'last_name': person.lastName,
          'email': person.email,
        });
    await performInsertPhoneNumber(
        connection: connection, phoneNumber: person.phone, entityId: person.id);
    await performInsertAddress(
        connection: connection, address: person.address, entityId: person.id);
  }

  static Future<void> performInsertPhoneNumber(
      {required MySqlConnection connection,
      required PhoneNumber phoneNumber,
      required String entityId}) async {
    await performInsertQuery(
        connection: connection,
        tableName: 'phone_numbers',
        data: {
          'id': phoneNumber.id,
          'entity_id': entityId,
          'phone_number': phoneNumber.toString()
        });
  }

  static Future<void> performInsertAddress(
      {required MySqlConnection connection,
      required Address address,
      required String entityId}) async {
    await performInsertQuery(
        connection: connection,
        tableName: 'addresses',
        data: {
          'id': address.id,
          'entity_id': entityId,
          'civic': address.civicNumber,
          'street': address.street,
          'apartment': address.apartment,
          'city': address.city,
          'postal_code': address.postalCode
        });
  }
// coverage:ignore-end
}

abstract class MySqlTableAccessor {
  String get tableName;
  String get tableIdName;

  String _craft({required String mainTableAlias});

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

class MySqlJoinSubQuery implements MySqlTableAccessor {
  // Data table
  final String dataTableName;
  final String asName;
  final String dataTableIdName;
  @override
  String get tableName => asName;
  @override
  String get tableIdName => dataTableIdName;

  // Relation table
  final String relationTableName;
  final String idNameToDataTable;
  final String idNameToMainTable;

  // Main table
  final String mainTableIdName;
  final List<String> fieldsToFetch;

  MySqlJoinSubQuery({
    required this.dataTableName,
    String? asName,
    this.dataTableIdName = 'id',
    required this.relationTableName,
    required this.idNameToDataTable,
    required this.idNameToMainTable,
    this.mainTableIdName = 'id',
    required this.fieldsToFetch,
  }) : asName = asName ?? dataTableName;

  @override
  String _craft({required String mainTableAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'st')}
            )
        )
        FROM $relationTableName idt
        JOIN $dataTableName st ON idt.$idNameToDataTable = st.$dataTableIdName
        WHERE idt.$idNameToMainTable = $mainTableAlias.$mainTableIdName
      ), JSON_ARRAY()) AS $tableName''';
  }
}

class MySqlSelectSubQuery implements MySqlTableAccessor {
  final String dataTableName;
  final String asName;
  @override
  String get tableName => asName;

  final String idNameToDataTable;
  final String idNameToMainTable;
  @override
  String get tableIdName => idNameToDataTable;

  final List<String> fieldsToFetch;

  MySqlSelectSubQuery({
    required this.dataTableName,
    String? asName,
    this.idNameToDataTable = 'id',
    this.idNameToMainTable = 'id',
    required this.fieldsToFetch,
  }) : asName = asName ?? dataTableName;

  @override
  String _craft({required String mainTableAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'st')}
            )
        )
        FROM $dataTableName st
        WHERE st.$idNameToDataTable = $mainTableAlias.$idNameToMainTable
      ), JSON_ARRAY()) AS $tableName''';
  }
}
